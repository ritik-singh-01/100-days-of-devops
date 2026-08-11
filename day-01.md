# Day 01 — enabled virtualisation, fixed a production incident, built an isolated lab

**Date:** 2026-08-11 · **Where:** a real Ubuntu 26.04 server, plus a new isolated VM on it

## What I did

**1. Checked and enabled hardware virtualisation**
```bash
egrep -c '(vmx|svm)' /proc/cpuinfo    # was 0 — virtualisation disabled in BIOS
sudo kvm-ok                           # confirmed: "CPU does not support KVM extensions"
```
Enabled Intel VT-x in the BIOS, rebooted, verified:
```bash
egrep -c '(vmx|svm)' /proc/cpuinfo    # now 24 (2 flags x 12 cores)
sudo kvm-ok                           # "KVM acceleration can be used"
systemd-detect-virt                   # none — confirmed still bare metal
```

**2. Found and fixed a real incident from the reboot**

After the reboot, `apache2.service` came up failed:
```bash
systemctl --failed
sudo journalctl -u apache2 -b --no-pager | tail -40
```
Error: `(98)Address already in use: AH00072: make_sock: could not bind to address 0.0.0.0:80`

Root-caused it step by step:
```bash
sudo apache2ctl configtest             # Syntax OK — config itself was fine
sudo ss -tulnp | grep ':80 '           # nginx already held the port, 13 workers
sudo apache2ctl -S                     # Apache only had the default, untouched vhost
ls -la /etc/apache2/sites-enabled/     # just 000-default.conf, nothing configured
history | grep -i apache               # no record of anyone ever using it
```
Conclusion: Apache was an unused default install losing a boot-order race against nginx —
not an incident, just dead weight the reboot exposed. **Confirmed with the other person on this
server before touching anything** (it's shared infrastructure).

```bash
sudo systemctl disable --now apache2
sudo systemctl reset-failed apache2    # disable ≠ clears an existing failed state — different things
systemctl is-enabled apache2           # disabled
systemctl is-active apache2            # inactive
```

**3. Built an isolated lab so I never touch production again for practice**

Installed KVM/libvirt, created a VM (`lab-ubuntu`) on the isolated `192.168.122.0/24` network —
completely separate from the host's production Docker networks and LAN:
```bash
sudo apt install -y qemu-system-x86 libvirt-daemon-system libvirt-clients bridge-utils virtinst cloud-image-utils
sudo virt-install --name lab-ubuntu --memory 6144 --vcpus 4 \
  --disk /var/lib/libvirt/images/lab-ubuntu.qcow2,bus=virtio \
  --disk /var/lib/libvirt/images/lab-ubuntu-seed.iso,device=cdrom \
  --osinfo detect=on,require=false --network network=default,model=virtio \
  --graphics none --import --noautoconsole
```
Connected through the host as a bastion:
```bash
ssh -J ritik@ashwani-8755 ritik@192.168.122.57
```
Verified isolation before doing anything else:
```bash
whoami ; hostname          # ritik / lab-ubuntu
ip addr show | grep 192.168.122
```
Took a snapshot as a permanent undo button:
```bash
sudo virsh snapshot-create-as lab-ubuntu clean-install --atomic
```

**4. Linux fundamentals, inside the isolated VM**
```bash
pwd ; ls -la
mkdir -p practice/day1 && cd practice/day1
echo "hello" > a.txt ; echo "world" >> a.txt ; cat a.txt
cp a.txt b.txt ; mv b.txt c.txt ; rm c.txt

mkdir -p ~/practice/exercise && cd ~/practice/exercise
echo "all good" > log1.txt
echo "error: disk full" > log2.txt
echo "error: timeout" > log3.txt
grep -l error *.txt              # -l = list only matching FILENAMES
grep -l error *.txt | xargs rm   # pipe those filenames into rm
ls -la                           # only log1.txt remains
```

## What each thing taught me

| Thing | What I learned |
|---|---|
| `kvm-ok` | Checking a CPU flag isn't enough — `kvm-ok` is the authoritative "can this actually run" check |
| The Apache incident | A failed service after a reboot isn't automatically a real problem — trace it before assuming |
| `disable` vs `reset-failed` | `disable` only stops it starting on the *next* boot. It doesn't clear the *current* failed state — two separate things I'd have assumed were one |
| `ss -tulnp` | Shows exactly who owns a port and how many processes are bound to it |
| `-J` (ProxyJump) | One SSH command can tunnel through a bastion host to a private-network VM in a single step |
| `grep -l \| xargs rm` | Find things → act on them. Apparently this exact shape reappears constantly — AWS resources, Kubernetes pods, log lines |

## What broke

Tried `ssh ritik@192.168.122.57` directly from my Mac first — timed out. That subnet only exists
*inside* the host; it has no route from outside. Needed `ssh -J` to tunnel through the host as a
bastion. Also hit `Whoami` (capital W) not found — Linux is case-sensitive everywhere, no exceptions.

## What I still don't understand

- Why `disable --now` didn't also clear the failed state the way I assumed "now" would
- What `--osinfo detect=on,require=false` is actually doing differently from a named `--os-variant`
- Whether I should be worried the CPU showed as the real model name instead of "QEMU Virtual CPU" —
  turned out to be host-passthrough, which is the *better* mode, but I didn't know that going in

