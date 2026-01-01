# Snapper & Btrfs: Manual Setup Guide

## 1. The Initial Setup

### **Problem:**

Snapper fails to run `create-config` on a "Flat Layout" because it tries to
create a folder that already exists (your mounted `@snapshots` subvolume).

### **The Fix:**

1. Unmount the existing subvolume:

   ```bash
   sudo umount /.snapshots
   ```

2. Remove the directory to clear the path:

   ```bash
   sudo rmdir /.snapshots
   ```

3. Generate the config (Snapper creates a new nested subvolume):

   ```bash
   sudo snapper -c root create-config / # We will edit this config later
   ```

4. Delete the unwanted subvolume Snapper just made:

   ```bash
   sudo btrfs subvolume delete /.snapshots
   ```

5. Re-create the empty directory:

   ```bash
   sudo mkdir /.snapshots
   ```

6. Remount your correct subvolume from `/etc/fstab`:

   ```bash
   sudo mount -a
   ```

---

## 2. Configuration: "Manual Mode"

**Goal:** Stop automatic hourly backups but allow manual control.

**File:** `/etc/snapper/configs/root`

| Setting           | Value   | Effect                                                              |
| ----------------- | ------- | ------------------------------------------------------------------- |
| `TIMELINE_CREATE` | `"no"`  | **Disables** the hourly robot. No more spam.                        |
| `NUMBER_CLEANUP`  | `"yes"` | **Enables** auto-deletion if you have too many manual snapshots.    |
| `NUMBER_LIMIT`    | `"50"`  | Keeps the last 50 snapshots. Oldest are deleted if you exceed this. |

**Important Note on Updates:**

- Your config file controls _time-based_ snapshots.
- It does **not** control _package manager_ snapshots.
- If you install `snap-pac`, you will still get snapshots every time you run
  `pacman`, regardless of the settings above.

---

## 3. The "Gotchas"

### A. Snapshots are NOT Recursive

- A snapshot of `/` (root) **does not** include `/home`.
- If you rollback your system, your personal files stay untouched (which is good).
- **Fix:** You must create a separate config for home if you want to back up files:

  ```bash
  sudo snapper -c home create-config /home
  ```

---

## 4. Cheat Sheet: Manual Commands

**Create a Snapshot:**

```bash
sudo snapper -c root create --description "Before messing with configs"
```

**Undo Changes (Revert files):**

```bash
# Undoes changes between snapshot 5 and NOW (snapshot 0)
sudo snapper -c root undochange 5..0
```

**Delete a Snapshot:**

```bash
sudo snapper -c root delete 5
```

## Theming

Run the following to copy the qt6 configs to root

```bash
sudo mkdir -p /root/.config
sudo ln -sf /home/$USER/.config/qt6ct /root/.config/qt6ct
```
