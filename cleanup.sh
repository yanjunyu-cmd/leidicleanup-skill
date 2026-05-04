#!/bin/bash
# Leidi Cleanup Script v1.0
# Auto-detect and remove failed installation residuals
# Part of leidi-skill: https://github.com/yanjunyu-cmd/leidi-skill

set -e

DOWNLOAD_DIR="/c/Users/烟云/Downloads"
TEMP_DIR="/c/Users/烟云/AppData/Local/Temp"
E_DISK="/e"
C_DISK="/c/Users/烟云"
FREED=0

log() { echo "[Leidi] $1"; }
freed() { FREED=$((FREED + $1)); }

# 1. Remove error-page "downloads" (tiny files that should be big)
log "Scanning for fake downloads (error pages)..."
for f in "$DOWNLOAD_DIR"/*.tar.* "$DOWNLOAD_DIR"/*.msi "$DOWNLOAD_DIR"/*.exe "$DOWNLOAD_DIR"/*.zip; do
  if [ -f "$f" ]; then
    size=$(stat -c%s "$f" 2>/dev/null || echo 0)
    if [ "$size" -lt 10240 ]; then
      log "  Removing fake download: $(basename $f) (${size} bytes)"
      rm -f "$f"
      freed "$size"
    fi
  fi
done

# 2. Clean WSL residuals
log "Checking WSL residuals..."
wsl --unregister Ubuntu-24.04 2>/dev/null && log "  Unregistered stale Ubuntu-24.04" || true
wsl --unregister Ubuntu 2>/dev/null && log "  Unregistered stale Ubuntu" || true

# 3. Clean npm cache and staging
log "Cleaning npm residuals..."
rm -rf "$C_DISK/Desktop/node_modules/.staging" 2>/dev/null || true
rm -rf "$C_DISK/Desktop/thesis_work" 2>/dev/null && log "  Removed thesis work dir" || true

# 4. Clean MSYS2 lock files
if [ -d "$E_DISK/MSYS2" ]; then
  log "Cleaning MSYS2 residuals..."
  rm -f "$E_DISK/MSYS2/var/lib/pacman/db.lck" 2>/dev/null && log "  Removed pacman lock" || true
  rm -f "$E_DISK/MSYS2/var/cache/pacman/pkg/"*.part 2>/dev/null && log "  Removed partial packages" || true
fi

# 5. Clean temp files
log "Cleaning temp files..."
rm -f "$TEMP_DIR/claude/"*"/tasks/"*.output 2>/dev/null || true

# 6. Clean broken symlinks
log "Checking for broken links..."
find "$C_DISK/.claude" -type l ! -exec test -e {} \; -delete 2>/dev/null || true

echo ""
log "=== CLEANUP COMPLETE ==="
log "Freed approximately $FREED bytes of disk space"
