#!/bin/bash
set -e

echo ">> [Fixer] STARTING DUAL-ENTRY REPAIR..."

# 1. Get UUIDs (Brute Force from Disk)
#    We grep raw output to avoid any parsing errors
RAW_BLKID=$(blkid)
ROOT_UUID=$(echo "$RAW_BLKID" | grep "nvme0n1p2" | grep -oP 'UUID="\K[^"]+')
ROOT_PARTUUID=$(echo "$RAW_BLKID" | grep "nvme0n1p2" | grep -oP 'PARTUUID="\K[^"]+')

echo "   Filesystem UUID: $ROOT_UUID"
echo "   Partition UUID:  $ROOT_PARTUUID"

if [ -z "$ROOT_UUID" ]; then
    echo "CRITICAL ERROR: Could not find UUIDs."
    exit 1
fi

# 2. Verify Kernel Exists (Sanity Check)
if [ ! -f "/boot/vmlinuz-linux" ]; then
    echo "WARNING: Kernel not found at /boot/vmlinuz-linux inside chroot."
    echo "This script might not fix the issue if the kernel is missing."
fi

# 3. Rewrite Limine Config Completely
#    We create TWO entries. One will work.
CONF="/boot/efi/EFI/arch-limine/limine.conf"

echo "   Rewriting $CONF..."

cat > "$CONF" <<EOF
timeout: 10

/Arch Linux (Subvol Path)
    protocol: linux
    path: uuid($ROOT_UUID):/@/boot/vmlinuz-linux
    module_path: uuid($ROOT_UUID):/@/boot/initramfs-linux.img
    cmdline: root=PARTUUID=$ROOT_PARTUUID zswap.enabled=0 rootflags=subvol=@ rw rootfstype=btrfs

/Arch Linux (Direct Path)
    protocol: linux
    path: uuid($ROOT_UUID):/boot/vmlinuz-linux
    module_path: uuid($ROOT_UUID):/boot/initramfs-linux.img
    cmdline: root=PARTUUID=$ROOT_PARTUUID zswap.enabled=0 rootflags=subvol=@ rw rootfstype=btrfs
EOF

echo "   Success: Config regenerated with 2 boot options."
echo ">> SETUP COMPLETE."