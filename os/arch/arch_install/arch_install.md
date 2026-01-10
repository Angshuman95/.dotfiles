# Install arch with LUKS and LVM

<!-- markdownlint-disable MD013 -->
<!-- markdownlint-disable MD014 -->

## Connect to Internet

### Using `iwctl`

- From [archwiki](https://wiki.archlinux.org/title/Iwd), here are the steps -

```bash
$ iwctl     # for launching prompt
```

```bash
[iwd]# help    # for available commands
```

```bash
[iwd]# device list  # list all Wi-Fi devices
```

- A device is a station now -

```bash
[iwd]# station <name> scan   # <name> is like wlan0
```

- The above command shows no output.

```bash
[iwd]# station <name> get-networks  # to get a list of available networks
```

```bash
[iwd]# station <name> connect SSID  # To connect to a network
```

- The above command asks for the password. Providing the correct password
  shows nothing. Else it will ask again.

- Check with `ping www.google.com` if internet is connected after exiting
  from the `iwctl` prompt.

## Partition the disk

- Our intention here is to use LUKS with SWAP Partition. So we will keep
  - 1 GB for boot (`/boot`)
  - Remaining for LUKS Container
    - Inside this - LVM Partition
      - SWAP of RAM size
      - BTRFS for root `/`

- We are NOT taking care of DUAL BOOT here.

- Use `cfdisk` to partition the disk.

```bash
# Verify your drive name (likely nvme0n1)
lsblk

# Use the name of the device as /dev/nvme0n1 and not the partition like
# /dev/nvme0n1p1
cfdisk /dev/nvme0n1
```

- Delete all existing partitions.

- New -> 1G -> Type: EFI System.

- New -> Remaining Size -> Type: Linux LVM.

- Write -> Yes -> Quit.

> [!NOTE]
> Type here is a flag. Other than that it has no meaning.

## Create a LUKS container

```bash
# Format the encryption container - This asks for the password
cryptsetup luksFormat /dev/nvme0n1p2  # NB - We are encrypting the partition 2
```

```bash
# Open the container (we'll call it 'cryptlvm')
cryptsetup open /dev/nvme0n1p2 cryptlvm
```

## Create LVM layout

```bash
# 1. Create Physical Volume PV
# Note a PV is a hard drive, SSD, or partition
pvcreate /dev/mapper/cryptlvm

# 2. Create Volume Group (Let's call it 'ArchVG')
# Note - several PVs can be added to form a VG - which is a storage pool
vgcreate ArchVG /dev/mapper/cryptlvm

# 3. Create Swap LV (32GB as requested)
lvcreate -L 32G -n swap ArchVG

# 4. Create Root LV (All remaining space)
lvcreate -l 100%FREE -n root ArchVG
```

## Format the Volumes

```bash
# Format Boot
mkfs.vfat -F32 /dev/nvme0n1p1

# Format Swap
mkswap /dev/ArchVG/swap

# Format Root (Btrfs)
mkfs.btrfs /dev/ArchVG/root
```

## Create btrfs subvolumes

- Mount the raw btrfs root temporarily

```bash
mount /dev/ArchVG/root /mnt
```

- Create the subvolumes

```bash
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg
```

- Unmount it so we can remount them properly with options

```bash
umount /mnt
```

## Mount the partitions with options

```bash
# 1. Mount the Root subvolume (@) to /mnt
mount -o compress=zstd:1,noatime,subvol=@ /dev/ArchVG/root /mnt

# 2. Create mount points
mkdir -p /mnt/{boot,home,.snapshots,var/log,var/cache/pacman/pkg}

# 3. Mount additional subvolumes
mount -o compress=zstd:1,noatime,subvol=@home /dev/ArchVG/root /mnt/home
mount -o compress=zstd:1,noatime,subvol=@snapshots /dev/ArchVG/root /mnt/.snapshots
mount -o compress=zstd:1,noatime,subvol=@log /dev/ArchVG/root /mnt/var/log
mount -o compress=zstd:1,noatime,subvol=@pkg /dev/ArchVG/root /mnt/var/cache/pacman/pkg

# 4. Mount Boot Partition
mount /dev/nvme0n1p1 /mnt/boot

# 5. Activate Swap
swapon /dev/ArchVG/swap
```

## Install base system

```bash
pacstrap -K /mnt base linux linux-lts linux-firmware lvm2 btrfs-progs \
    amd-ucode efibootmgr networkmanager neovim zram-generator git base-devel
```

## Generate Fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

## Chroot into the installation

```bash
arch-chroot /mnt
```

## Add the HOOKS

- Open the `/etc/mkinitcpio.conf`

- HOOKS section should look like

```conf
HOOKS=(base udev modconf keyboard keymap consolefont block encrypt lvm2 resume filesystems fsck)
```

- Remove: autodetect (optional, but safer to remove for now).

- Add: encrypt and lvm2 between block and filesystems.

## Generate the `initramfs`

```bash
mkinitcpio -P
```

## Install systemd-boot

```bash
bootctl install
```

- Add boot entries

```bash
# 1. Capture the UUID of your encrypted partition (p2)
UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)

# 2. Create the LTS Boot Entry
cat <<EOF > /boot/loader/entries/arch-lts.conf
title   Arch Linux LTS
linux   /vmlinuz-linux-lts
initrd  /amd-ucode.img
initrd  /initramfs-linux-lts.img
options cryptdevice=UUID=${UUID}:cryptlvm root=/dev/ArchVG/root rootflags=subvol=@ rw resume=/dev/ArchVG/swap
EOF

# 3. Create the Standard Kernel Entry (Backup)
cat <<EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options cryptdevice=UUID=${UUID}:cryptlvm root=/dev/ArchVG/root rootflags=subvol=@ rw resume=/dev/ArchVG/swap
EOF
```

- Configure the loader to make `arch` the default
  - `/boot/loader/loader.conf`

```conf
default  arch.conf
timeout  3
console-mode max
editor   no
```

## Configure ZRAM

- Open the file `/etc/systemd/zram-generator.conf`. This should be the contents:

```toml
[zram0]
zram-size = min(ram / 2, 4096)
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
```

## Password for root user

- Run `passwd`. This asks for a password.

```bash
passwd
```

### Create a new user

- Run the following to create a new user and add to wheel group.

```bash
useradd -m -G wheel -s /bin/bash yourusername
```

Here -

```text
-m: Creates the home directory (/home/yourusername).

-G wheel: Adds the user to the wheel group (required for sudo access).

-s /bin/bash: Sets the default shell.
```

- Set Password for new user

```bash
passwd yourusername
```

### Sudo access for new user

- By default, the `wheel` group is locked. We need to unlock it so that members
  can use `sudo`.

```bash
EDITOR=nvim visudo      # Open the sudo configuration file
```

- Scroll down and find the line -

```txt
# %wheel ALL=(ALL:ALL) ALL
```

- Uncomment it and save the file.

## Set Hostname

```bash
echo "archlinux" > /etc/hostname
```

## Time and Date

- Inside chroot link the timezone file manually -

```bash
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
```

- Generate `/etc/adjtime`

```bash
hwclock --systohc
```

- Once logged in back set automatic timezone sync over internet. Arch uses
  systemd-timesyncd by default to sync your clock over the internet.

```bash
timedatectl set-ntp true
```

## Locale

- Edit the `/etc/locale.gen` file. Uncomment the followin:

```txt
en_IN UTF-8
en_US.UTF-8 UTF-8
```

- Run to generate the locales -

```bash
locale-gen
```

- Ensure that `/etc/locale.conf` looks like the following. So that system knows
  which locale to use where.

```conf
LANG=en_US.UTF-8
LC_TIME=en_IN.UTF-8
LC_MONETARY=en_IN.UTF-8
LC_PAPER=en_IN.UTF-8
LC_MEASUREMENT=en_IN.UTF-8
```

## Enable networkmanager

```bash
systemctl enable NetworkManager
```

## Exit and reboot

- `exit` leaves the chroot.

- Unmount everything

```bash
umount -R /mnt
```

- `reboot` to reboot.
