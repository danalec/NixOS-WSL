use anyhow::{anyhow, Context};
use nix::errno::Errno;
use nix::mount::{mount, MsFlags};
use nix::sys::wait::{waitid, Id, WaitPidFlag};
use nix::unistd::Pid;
use std::env;
use std::fs::{create_dir_all, metadata, remove_dir_all, remove_file, OpenOptions};
use std::os::unix::io::{FromRawFd, IntoRawFd};
use std::os::unix::process::CommandExt;
use std::path::Path;
use std::process::{Command, Stdio};
use nix::unistd::dup;

fn unscrew_dev_shm() -> anyhow::Result<()> {
    log::trace!("Unscrewing /dev/shm...");

    let dev_shm = Path::new("/dev/shm");

    if dev_shm.is_symlink() {
        remove_file(dev_shm).context("When removing /dev/shm symlink")?;
    } else if dev_shm.is_dir() {
        remove_dir_all(dev_shm).context("When removing old /dev/shm")?;
    }

    create_dir_all("/dev/shm").context("When creating new /dev/shm")?;
    mount(
        Some("/run/shm"),
        "/dev/shm",
        None::<&str>,
        MsFlags::MS_MOVE,
        None::<&str>,
    )
    .context("When relocating /dev/shm")?;
    mount(
        Some("/dev/shm"),
        "/run/shm",
        None::<&str>,
        MsFlags::MS_BIND,
        None::<&str>,
    )
    .context("When bind mounting /run/shm to /dev/shm")?;

    Ok(())
}

fn real_main() -> anyhow::Result<()> {
    if metadata("/dev/shm")
        .context("When checking /dev/shm")?
        .is_symlink()
    {
        unscrew_dev_shm()?;
    } else {
        log::trace!("/dev/shm is not a symlink, leaving as-is...");
    };

    log::trace!("Remounting / shared...");
    remount_root_shared()?;

    log::trace!("Remounting /nix/store read-only...");
    remount_nix_store_readonly()?;

    log::trace!("Running activation script...");

    let kmsg_fd = OpenOptions::new()
        .write(true)
        .open("/dev/kmsg")
        .context("When opening /dev/kmsg")?
        .into_raw_fd();
    // Duplicate the fd so stdout and stderr don't share and double-close the same descriptor
    let kmsg_fd_err = dup(kmsg_fd).context("When duplicating /dev/kmsg fd")?;

    let child = Command::new("/nix/var/nix/profiles/system/activate")
        .env("LANG", "C.UTF-8")
        // SAFETY: we just opened this
        .stdout(unsafe { Stdio::from_raw_fd(kmsg_fd) })
        .stderr(unsafe { Stdio::from_raw_fd(kmsg_fd_err) })
        .spawn()
        .context("When activating")?;

    let pid = Pid::from_raw(child.id() as i32);

    // If the child catches SIGCHLD, `waitid` will wait for it to exit, then return ECHILD.
    // Why? Because POSIX is terrible.
    match child.wait() {
        Ok(status) => {
            check_activation_exit(status.code())?;
        }
        Err(_) => {
            let result = waitid(Id::Pid(pid), WaitPidFlag::WEXITED);
            interpret_waitid_result(result)?;
        }
    }

    log::trace!("Spawning real systemd...");

    // if things go right, we will never return from here
    Err(
        Command::new("/nix/var/nix/profiles/system/systemd/lib/systemd/systemd")
            .arg0(env::args_os().next().expect("arg0 missing"))
            .arg("--log-target=kmsg") // log to dmesg
            .args(env::args_os().skip(1))
            .exec()
            .into(),
    )
}

fn remount_root_shared() -> anyhow::Result<()> {
    mount(
        None::<&str>,
        "/",
        None::<&str>,
        MsFlags::MS_REC | MsFlags::MS_SHARED,
        None::<&str>,
    )
    .context("When remounting /")?;
    Ok(())
}

fn remount_nix_store_readonly() -> anyhow::Result<()> {
    mount(
        Some("/nix/store"),
        "/nix/store",
        None::<&str>,
        MsFlags::MS_BIND,
        None::<&str>,
    )
    .context("When bind mounting /nix/store")?;

    mount(
        Some("/nix/store"),
        "/nix/store",
        None::<&str>,
        MsFlags::MS_BIND | MsFlags::MS_REMOUNT | MsFlags::MS_RDONLY,
        None::<&str>,
    )
    .context("When remounting /nix/store read-only")?;
    Ok(())
}

fn interpret_waitid_result(result: Result<(), Errno>) -> anyhow::Result<()> {
    match result {
        Ok(_) | Err(Errno::ECHILD) => Ok(()),
        Err(e) => Err(e).context("When waiting"),
    }
}

fn check_activation_exit(code: Option<i32>) -> anyhow::Result<()> {
    match code {
        Some(0) => Ok(()),
        Some(c) => Err(anyhow!("Activation exited with status {}", c)),
        None => Err(anyhow!("Activation terminated by signal")),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use nix::errno::Errno;

    #[test]
    fn waitid_ok_is_ok() {
        assert!(interpret_waitid_result(Ok(())).is_ok());
    }

    #[test]
    fn waitid_echild_is_ok() {
        assert!(interpret_waitid_result(Err(Errno::ECHILD)).is_ok());
    }

    #[test]
    fn waitid_other_error_is_err() {
        assert!(interpret_waitid_result(Err(Errno::EINVAL)).is_err());
    }

    #[test]
    fn activation_exit_zero_is_ok() {
        assert!(check_activation_exit(Some(0)).is_ok());
    }

    #[test]
    fn activation_exit_nonzero_is_err() {
        assert!(check_activation_exit(Some(1)).is_err());
    }

    #[test]
    fn activation_exit_none_is_err() {
        assert!(check_activation_exit(None).is_err());
    }
}

#[cfg(all(test, target_os = "linux"))]
mod integration {
    use super::*;

    fn is_root() -> bool { nix::unistd::geteuid().is_root() }
    fn is_wsl() -> bool {
        std::env::var("WSL_INTEROP").is_ok() ||
        std::fs::read_to_string("/proc/sys/kernel/osrelease").map(|s| s.contains("microsoft")).unwrap_or(false)
    }

    #[test]
    fn remounts_execute_or_skip() {
        if !is_root() || !is_wsl() {
            return;
        }
        assert!(remount_root_shared().is_ok());
        assert!(remount_nix_store_readonly().is_ok());
    }
}

fn main() {
    env::set_var("RUST_BACKTRACE", "1");
    kernlog::init().expect("Failed to set up logger...");
    if let Err(e) = real_main() {
        log::error!("Error: {:?}", e);
    }
}
