#!/usr/bin/env bash
#
# setup_hibernate.sh - Configure hibernate support for Arch Linux
# btrfs + LUKS + LVM setup with GRUB bootloader
#
# Creates a btrfs swap subvolume, swapfile, and configures
# initramfs + GRUB for resume from hibernate.
#
# Usage: sudo ./setup_hibernate.sh

set -euo pipefail

# --- Configuration ---
SWAP_SIZE_GB=32
SWAP_MOUNT="/swap"
SWAP_FILE="${SWAP_MOUNT}/swapfile"
BTRFS_DEV="/dev/mapper/ArchinstallVg-root"
SUBVOL_NAME="@swap"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"
GRUB_DEFAULT="/etc/default/grub"
HYPRIDLE_CONF="$(dirname "$(realpath "$0")")/../hypridle.conf"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[*]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }

confirm() {
    echo -en "${YELLOW}[?]${NC} $1 [y/N] "
    read -r reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

# --- Preflight checks ---
[[ $EUID -ne 0 ]] && error "This script must be run as root (sudo)."

RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
RAM_GB=$(( RAM_KB / 1024 / 1024 ))
info "Detected ${RAM_GB}GB RAM. Swap size set to ${SWAP_SIZE_GB}GB."

if [[ $SWAP_SIZE_GB -lt $RAM_GB ]]; then
    warn "Swap size (${SWAP_SIZE_GB}GB) is less than RAM (${RAM_GB}GB)."
    warn "Hibernate may fail if RAM usage exceeds swap size."
    confirm "Continue anyway?" || exit 0
fi

ROOT_FSTYPE=$(findmnt / -n -o FSTYPE)
[[ "$ROOT_FSTYPE" != "btrfs" ]] && error "Root filesystem is ${ROOT_FSTYPE}, expected btrfs."

info "System checks passed."
echo ""
echo "This script will:"
echo "  1. Create btrfs subvolume /${SUBVOL_NAME}"
echo "  2. Create ${SWAP_SIZE_GB}GB swapfile at ${SWAP_FILE}"
echo "  3. Add fstab entry for the swap mount"
echo "  4. Add 'resume' hook to mkinitcpio and regenerate initramfs"
echo "  5. Add resume kernel parameters to GRUB"
echo "  6. Add systemd drop-ins to disable zram before hibernate"
echo "  7. Update hypridle.conf to use suspend-then-hibernate"
echo ""
confirm "Proceed with hibernate setup?" || exit 0

# --- Step 1: Create btrfs swap subvolume ---
info "Step 1: Creating btrfs swap subvolume..."

TMPMNT=$(mktemp -d)
mount "${BTRFS_DEV}" "${TMPMNT}" -o subvolid=5

if btrfs subvolume show "${TMPMNT}/${SUBVOL_NAME}" &>/dev/null; then
    warn "Subvolume /${SUBVOL_NAME} already exists, skipping creation."
else
    btrfs subvolume create "${TMPMNT}/${SUBVOL_NAME}"
    info "Created subvolume /${SUBVOL_NAME}."
fi

umount "${TMPMNT}"
rmdir "${TMPMNT}"

# --- Step 2: Mount the swap subvolume ---
info "Step 2: Mounting swap subvolume..."

mkdir -p "${SWAP_MOUNT}"

if mountpoint -q "${SWAP_MOUNT}"; then
    warn "${SWAP_MOUNT} is already mounted, skipping."
else
    # Add fstab entry if not present
    if ! grep -q "${SWAP_MOUNT}" /etc/fstab; then
        echo "" >> /etc/fstab
        echo "# Swap subvolume for hibernate" >> /etc/fstab
        echo "${BTRFS_DEV}  ${SWAP_MOUNT}  btrfs  subvol=${SUBVOL_NAME},nodatacow,compress=no  0  0" >> /etc/fstab
        info "Added fstab entry."
    else
        warn "fstab entry for ${SWAP_MOUNT} already exists, skipping."
    fi

    mount "${SWAP_MOUNT}"
    info "Mounted ${SWAP_MOUNT}."
fi

# --- Step 3: Create swapfile ---
info "Step 3: Creating ${SWAP_SIZE_GB}GB swapfile (this will take a moment)..."

if [[ -f "${SWAP_FILE}" ]]; then
    EXISTING_SIZE=$(stat -c%s "${SWAP_FILE}" 2>/dev/null || echo 0)
    EXPECTED_SIZE=$(( SWAP_SIZE_GB * 1073741824 ))
    if [[ "$EXISTING_SIZE" -eq "$EXPECTED_SIZE" ]]; then
        warn "Swapfile already exists with correct size, skipping creation."
    else
        warn "Swapfile exists but size differs (${EXISTING_SIZE} vs ${EXPECTED_SIZE})."
        confirm "Recreate swapfile?" || error "Cannot proceed with wrong-sized swapfile."
        swapoff "${SWAP_FILE}" 2>/dev/null || true
        rm -f "${SWAP_FILE}"
        chattr +C "${SWAP_MOUNT}"
        dd if=/dev/zero of="${SWAP_FILE}" bs=1G count="${SWAP_SIZE_GB}" status=progress
    fi
else
    chattr +C "${SWAP_MOUNT}"
    dd if=/dev/zero of="${SWAP_FILE}" bs=1G count="${SWAP_SIZE_GB}" status=progress
fi

chmod 600 "${SWAP_FILE}"

if ! swapon --show | grep -q "${SWAP_FILE}"; then
    mkswap "${SWAP_FILE}"
    swapon "${SWAP_FILE}"
    info "Swapfile created and activated."
else
    warn "Swapfile already active."
fi

# Add swapfile to fstab so it activates on boot
if ! grep -q "${SWAP_FILE}" /etc/fstab; then
    echo "${SWAP_FILE}  none  swap  defaults  0  0" >> /etc/fstab
    info "Added swapfile fstab entry for boot activation."
else
    warn "Swapfile fstab entry already exists, skipping."
fi

# --- Step 4: Get resume offset ---
info "Step 4: Getting resume offset..."

RESUME_OFFSET=$(btrfs inspect-internal map-swapfile -r "${SWAP_FILE}")
info "Resume offset: ${RESUME_OFFSET}"

# --- Step 5: Update mkinitcpio ---
info "Step 5: Updating mkinitcpio hooks..."

CURRENT_HOOKS=$(grep "^HOOKS=" "${MKINITCPIO_CONF}")

if echo "$CURRENT_HOOKS" | grep -q "resume"; then
    warn "'resume' hook already present in mkinitcpio, skipping."
else
    # Insert 'resume' after 'lvm2'
    BACKUP="${MKINITCPIO_CONF}.bak.$(date +%s)"
    cp "${MKINITCPIO_CONF}" "${BACKUP}"
    info "Backed up mkinitcpio.conf to ${BACKUP}"

    sed -i 's/\(lvm2\)/\1 resume/' "${MKINITCPIO_CONF}"
    info "Added 'resume' hook after 'lvm2'."

    info "Regenerating initramfs..."
    mkinitcpio -P
    info "Initramfs regenerated."
fi

# --- Step 6: Update GRUB ---
info "Step 6: Updating GRUB kernel parameters..."

BACKUP="${GRUB_DEFAULT}.bak.$(date +%s)"
cp "${GRUB_DEFAULT}" "${BACKUP}"
info "Backed up grub default to ${BACKUP}"

CURRENT_CMDLINE=$(grep "^GRUB_CMDLINE_LINUX_DEFAULT=" "${GRUB_DEFAULT}")

if echo "$CURRENT_CMDLINE" | grep -q "resume="; then
    warn "resume parameter already in GRUB config."
    warn "Current: ${CURRENT_CMDLINE}"
    warn "Please verify resume_offset=${RESUME_OFFSET} is correct."
else
    # Append resume parameters before the closing quote
    sed -i "s|^\(GRUB_CMDLINE_LINUX_DEFAULT=\".*\)\"|\1 resume=${BTRFS_DEV} resume_offset=${RESUME_OFFSET}\"|" "${GRUB_DEFAULT}"
    info "Added resume parameters to GRUB."

    info "Regenerating GRUB config..."
    grub-mkconfig -o /boot/grub/grub.cfg
    info "GRUB config regenerated."
fi

# --- Step 7: Disable zram before hibernate ---
info "Step 7: Creating systemd drop-ins to disable zram before hibernate..."

HIBERNATE_DROPIN="/etc/systemd/system/systemd-hibernate.service.d"
STH_DROPIN="/etc/systemd/system/systemd-suspend-then-hibernate.service.d"
DROPIN_CONTENT="[Service]
ExecStartPre=-/usr/bin/swapoff /dev/zram0"

for dir in "${HIBERNATE_DROPIN}" "${STH_DROPIN}"; do
    if [[ -f "${dir}/disable-zram.conf" ]]; then
        warn "Drop-in ${dir}/disable-zram.conf already exists, skipping."
    else
        mkdir -p "${dir}"
        echo "${DROPIN_CONTENT}" > "${dir}/disable-zram.conf"
        info "Created ${dir}/disable-zram.conf"
    fi
done

systemctl daemon-reload
info "Systemd drop-ins created. zram will be disabled before hibernate."

# --- Step 8: Update hypridle.conf ---
info "Step 8: Updating hypridle.conf..."

if [[ -f "${HYPRIDLE_CONF}" ]]; then
    if grep -q "systemctl suspend" "${HYPRIDLE_CONF}"; then
        sed -i 's|systemctl suspend.*|systemctl suspend-then-hibernate  # suspend first, hibernate after delay|' "${HYPRIDLE_CONF}"
        info "Updated hypridle.conf: suspend -> suspend-then-hibernate"
    else
        warn "No 'systemctl suspend' found in hypridle.conf, skipping."
    fi
else
    warn "hypridle.conf not found at ${HYPRIDLE_CONF}, skipping."
fi

# --- Done ---
echo ""
info "========================================="
info "  Hibernate setup complete!"
info "========================================="
echo ""
info "Summary:"
info "  Swap subvolume: /${SUBVOL_NAME}"
info "  Swapfile: ${SWAP_FILE} (${SWAP_SIZE_GB}GB)"
info "  Resume device: ${BTRFS_DEV}"
info "  Resume offset: ${RESUME_OFFSET}"
echo ""
warn "A reboot is required for initramfs and GRUB changes to take effect."
echo ""
confirm "Reboot now?" && systemctl reboot || info "Remember to reboot before testing hibernate."
