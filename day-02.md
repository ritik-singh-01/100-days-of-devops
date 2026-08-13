# Day 02 — Exploring the Linux filesystem hierarchy

**Where:** inside the isolated `lab-ubuntu` VM (192.168.122.11), on the office's `ashwani-8755` KVM host.

**Note:** the official Day 2 curriculum in `01-START-HERE.md` §7 is `chmod`, `chown`, `ps aux`, `top`,
`kill`, `df -h`, `du -sh`, `free -h`, and a first shell script. I didn't get to those today — instead I
spent the session walking the root filesystem and doing basic file ops. Logging what actually happened.

## Real command history (from `history`)

    sudo virsh autostart lab-ubuntu
    exit
    ls
    ls -la
    cd ~
    ls
    ls -lah
    cd .ssh
    ls -ls
    pwd
    cd home
    cd ..
    ls
    exit
    pwd
    ls
    touch abc.txt
    touch abc{1..10}.txt
    mkdir test
    ls -l
    rmdir test
    mkdir test
    cd test
    touch ab.txt
    pwd
    cd ..
    rmdir test          # failed — directory not empty
    rm -rf test
    cal
    sudo apt install ncal
    cal
    cd bin
    cd home
    pwd
    date
    help
    man
    man ls
    mkdir test
    mkdir test.txt
    cd .
    cd ..
    cd ritik
    cd
    cd ~
    cd --                # typo for `cd -`, didn't work as intended
    cd /
    cd bin
    cd /sbin
    cd boot
    cd dev
    cd etc
    cd tmp
    cd lib
    cd mnt
    cd media
    cd /opt
    cd proc
    cd 135               # typo, no such PID
    cd 1

## What I actually saw

**`ls -l /` (root directory):**

    bin -> usr/bin
    bin.usr-is-merged
    boot
    dev
    etc
    home
    lib -> usr/lib
    lib.usr-is-merged
    lib64 -> usr/lib64
    lost+found
    media
    mnt
    opt
    proc
    root
    run
    sbin -> usr/sbin
    sbin.usr-is-merged
    snap
    srv
    sys
    tmp
    usr
    var

`bin`, `lib`, `lib64`, `sbin` are all symlinks into `/usr/...` — this is the "usr-merge" Ubuntu now ships
by default. `lost+found` is for `fsck` to dump orphaned blocks into after a filesystem check.

**`/bin`** — hundreds of everyday commands (`ls`, `cp`, `mv`, `top`, `tmux`, `python3`, `git`...). This is
where the commands I type every day actually live.

**`/sbin`** — system administration binaries: `iptables`, `fdisk`, `mkfs.ext4`, `useradd`, `shutdown`,
`reboot`. Things a normal user wouldn't run day to day, only root.

**`/boot`** — the kernel and bootloader files:

    System.map-6.8.0-136-generic
    config-6.8.0-136-generic
    efi
    grub
    initrd.img / initrd.img-6.8.0-136-generic / initrd.img.old
    vmlinuz / vmlinuz-6.8.0-136-generic / vmlinuz.old

**`/dev`** — device files: `tty0`–`tty63`, `sda`/`vda`-style disks, `null`, `random`, `urandom`, `kvm`,
`loop0`–`loop7`. Every piece of hardware (real or virtual) shows up here as a file.

**`/etc`** — system configuration: `passwd`, `shadow`, `hosts`, `hostname`, `fstab`, `netplan`, `ssh`,
`sudoers`, `crontab`, `cloud` (cloud-init's own config lives here — same tool that gave me the login
trouble earlier this week).

**`/tmp`** — mostly empty except systemd's private runtime sockets
(`systemd-private-...-resolved.service-...` etc). Confirmed this is *not* where anything important should
be stored — matches what I learned the hard way rebuilding this VM.

**`/lib`** — shared libraries and kernel modules (`git-core`, `cloud-init`, `linux-tools-6.8.0-136`,
`ufw`, `sysstat`).

**`/mnt`, `/media`, `/opt`** — all empty on a fresh install. `/mnt` and `/media` are conventional mount
points (temporary vs removable media), `/opt` is for manually-installed third-party software — none of
that applies here yet.

**`/proc`** — not a real filesystem on disk, it's the kernel exposing live system state as files:
numbered directories per running process (`/proc/1`, `/proc/2646`, ...) plus `meminfo`, `cpuinfo`,
`uptime`, `mounts`. `cd 135` failed with `No such file or directory` — no process with PID 135 was
running at that moment, so there was no directory to enter.

**`/proc/1` (the `init`/PID 1 process):**

    ls: cannot read symlink 'cwd': Permission denied
    ls: cannot read symlink 'root': Permission denied
    ls: cannot read symlink 'exe': Permission denied

PID 1 is owned by root; a normal user can list most of its `/proc/1/` entries but can't follow the `cwd`,
`root`, or `exe` symlinks into another user's process internals. Same permission model as everywhere else
on Linux, just applied to a process instead of a file.

## Screenshots

- `screenshots/Screenshot 2026-08-13 at 9.50.18 PM.png` — `ls -l /`, root directory listing
- `screenshots/Screenshot 2026-08-13 at 9.50.38 PM.png` — `/bin` contents
- `screenshots/Screenshot 2026-08-13 at 9.50.49 PM.png` — `/sbin` contents
- `screenshots/Screenshot 2026-08-13 at 9.51.02 PM.png` — `/sbin` continued
- `screenshots/Screenshot 2026-08-13 at 9.51.13 PM.png` — `/boot`, `/dev`, `/etc`, `/tmp`, `/lib`
- `screenshots/Screenshot 2026-08-13 at 9.51.29 PM.png` — `/mnt`, `/media`, `/opt`, `/proc`
- `screenshots/Screenshot 2026-08-13 at 9.51.51 PM.png` — `/proc/1`, permission-denied on `cwd`/`root`/`exe`

## What broke

- `rmdir test` failed after `cd test && touch ab.txt && cd ..` — `rmdir` only removes *empty* directories.
  Had to use `rm -rf test` instead once it had a file in it.
- `cd 135` — typo for a PID that didn't exist. `cd: 135: No such file or directory`.
- `cd --` — typo, doesn't do what `cd -` (jump to previous directory) does. Still owe myself that one.

## What I still don't understand

- Why some `/proc/1` entries are readable (`limits`, `status`, `cmdline`) but `cwd`/`root`/`exe` aren't —
  need to look at the actual permission bits on those symlinks specifically.

## Still to finish — the actual Day 2 curriculum

- `chmod`, `chown`
- `ps aux`, `top`, `kill`
- `df -h`, `du -sh *`, `free -h`
- write a 3-line shell script (print date + disk usage), `chmod +x` it, run it
- break something on purpose: fill a file with junk via `dd` until disk is full, find it, delete it
- say out loud: "How would I find out why a server is slow?"
- also still owed from Day 1: `cd -`, `grep -c bash /etc/passwd`, both `find` commands, `man ls`/`ls --help`
  read-through, and the recorded "What is Linux" answer
