# Day 01 — Linux fundamentals

**Where:** inside the isolated `lab-ubuntu` VM.

## 1. Where am I, and who am I?

    whoami ; hostname ; pwd ; uname -a ; cat /etc/os-release

    ritik
    lab-ubuntu
    /home/ritik
    Linux lab-ubuntu 6.8.0-136-generic #136-Ubuntu SMP PREEMPT_DYNAMIC Wed Jul 1 21:53:05 UTC 2026 x86_64
    PRETTY_NAME="Ubuntu 24.04.4 LTS"
    VERSION_CODENAME=noble

## 2. Looking around

    ls
    ls -la

    (empty — just .bash_logout, .bashrc, .cache, .profile, .ssh)

    ls -lah /etc

    (full /etc listing, ~200 entries — standard Ubuntu contents)

    cd /var/log
    cd ..
    cd ~

**Not done yet:** `cd -`

## 3. Making and moving things

    mkdir -p /practice/day1

    mkdir: cannot create directory '/practice': Permission denied

    mkdir -p practice/day1
    cd practice/day1
    echo "hello" > a.txt
    echo "world" >> a.txt
    cat a.txt

    hello
    world

    cp a.txt b.txt
    mv b.txt c.txt
    ls -la

    a.txt, c.txt

    rm c.txt
    ls -la

    only a.txt remains

## 4. Reading files properly

    cat /etc/passwd

    (33 lines total — root, standard system accounts, ritik:x:1000:1000::/home/ritik:/bin/bash)

    less /etc/passwd
    head -5 /etc/passwd

    root:x:0:0:root:/root:/bin/bash
    daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
    bin:x:2:2:bin:/bin:/usr/sbin/nologin
    sys:x:3:3:sys:/dev:/usr/sbin/nologin
    sync:x:4:65534:sync:/bin:/bin/sync

    tail -5 /etc/passwd

    tcpdump:x:107:108::/nonexistent:/usr/sbin/nologin
    landscape:x:108:109::/var/lib/landscape:/usr/sbin/nologin
    fwupd-refresh:x:990:990:Firmware update daemon:/var/lib/fwupd:/usr/sbin/nologin
    polkitd:x:989:989:User for polkitd:/:/usr/sbin/nologin
    ritik:x:1000:1000::/home/ritik:/bin/bash

    wc -l /etc/passwd

    33 /etc/passwd

## 5. Finding things

    grep root /etc/passwd

    root:x:0:0:root:/root:/bin/bash

    grep -i ROOT /etc/passwd

    root:x:0:0:root:/root:/bin/bash

**Cut off, not confirmed:** `grep -r bash /etc/ 2>/dev/null` — output was incomplete in my terminal
scrollback. Need to re-run and record the real result.

**Not done yet:** `grep -c bash /etc/passwd`, `find /etc -name "*.conf"`, `find /etc -name "*.conf" -type f`,
`find / -name "hosts" 2>/dev/null`

## 6. The exercise that ties it together

    mkdir -p ~/practice/exercise && cd ~/practice/exercise
    echo "all good" > log1.txt
    echo "error: disk full" > log2.txt
    echo "error: timeout" > log3.txt
    grep -l error *.txt
    grep -l error *.txt | xargs rm
    ls -la

    only log1.txt remains

## 7. Get unstuck without Google

**Not done yet:** `man ls`, `ls --help`

## What broke

`mkdir -p /practice/day1` — permission denied, `/` is root-owned. Used a relative path
inside my own home directory instead.

## What I still don't understand

- Why `/` is locked for a normal user but `/home/ritik` isn't — need to look at the actual
  permission bits properly
- What the real `grep -r bash /etc/` output actually shows — need to re-run it

## Still to finish before Day 1 is actually done

- `cd -`
- `grep -c bash /etc/passwd`
- both `find` commands
- `man ls` and `ls --help`
- say "What is Linux, and why do servers use it?" out loud, recorded
