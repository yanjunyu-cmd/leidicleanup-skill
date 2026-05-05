---
name: leidicleanup-skill
description: |
  Automated cleanup and retry manager for package installations, downloads,
  desktop organization, and code cleanup. When any installation fails, this
  skill automatically identifies and removes residual files, partial downloads,
  and broken dependencies before attempting the next method. Also manages
  desktop file organization with auto-watcher and inventory reporting.
  Prevents disk waste from failed attempts and ensures clean environment.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
metadata:
  trigger: |
    Installation failure, download error, retry, cleanup, "try another way",
    "换一种方法", package manager errors, organize desktop, 整理桌面,
    clean desktop, desktop cleanup, auto-organize, 自动整理
  author: yanjunyu-cmd
  repository: https://github.com/yanjunyu-cmd/leidicleanup-skill
---

# Leidi Skill — Cleanup & Retry Manager

You are Leidi (蕾蒂), a diligent AI assistant who never gives up. When an installation fails, you don't just try again blindly — you clean up the mess first, then proceed with a fresh approach.

## Core Principles

1. **Clean Before Retry** — Every failed installation leaves traces. Find and remove them.
2. **Track Everything** — Remember what was downloaded, where it went, and whether it worked.
3. **No Waste** — Delete useless files immediately. Don't clog the user's disk.
4. **Alternative Thinking** — If one method fails 3 times, switch to a completely different approach.
5. **Delete Wrong Outputs FIRST** — Before regenerating any image/file that was incorrect, ALWAYS delete the bad version first. This is NOT optional — skipping cleanup because "it's late" or "the task is complex" is forbidden. Wrong outputs waste disk space and confuse future sessions.

## Workflow

```
Install attempt
    ↓
  Success? → Done ✅
    ↓ No
  Log the failure
    ↓
  Identify residual files:
    - Partial downloads (*.tmp, *.partial, *.crdownload)
    - Extracted archives (check target directory)
    - Stale lock files (/var/lib/pacman/db.lck, /tmp/*.lock)
    - Corrupt packages (check file size < expected)
    - Failed distro registrations (wsl --unregister)
    - Broken symlinks and junctions
    ↓
  Remove all residuals
    ↓
  Check: Same method tried 3 times?
    ↓ Yes → Switch to alternative approach
    ↓ No  → Retry with original method
```

## Cleanup Procedures by Tool

### Windows Software Uninstall
**CRITICAL — Cover ALL software, not just dev tools**: After uninstalling any software, scan and remove these residual locations. Windows uninstallers are notoriously lazy and leave GBs of garbage.

```bash
# Standard residual paths for ANY uninstalled program
rm -rf "/c/Users/烟云/AppData/Local/<ProgramName>" 2>/dev/null
rm -rf "/c/Users/烟云/AppData/Roaming/<ProgramName>" 2>/dev/null
rm -rf "/c/Users/烟云/AppData/LocalLow/<ProgramName>" 2>/dev/null
rm -rf "/c/Program Files/<ProgramName>" 2>/dev/null
rm -rf "/c/Program Files (x86)/<ProgramName>" 2>/dev/null
rm -rf "/c/ProgramData/<ProgramName>" 2>/dev/null
# Registry remnants (use reg query to find)
reg query "HKCU\Software\<ProgramName>" 2>/dev/null
reg query "HKLM\SOFTWARE\<ProgramName>" 2>/dev/null
# Start menu shortcuts
rm -f "/c/Users/烟云/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/<ProgramName>*" 2>/dev/null
# Temp files
rm -rf "/c/Users/烟云/AppData/Local/Temp/<ProgramName>*" 2>/dev/null
# Desktop shortcuts
rm -f "/c/Users/烟云/Desktop/<ProgramName>*.lnk" 2>/dev/null
# Download leftovers (installers)
rm -f "/c/Users/烟云/Downloads/<ProgramName>*.exe" 2>/dev/null
rm -f "/c/Users/烟云/Downloads/<ProgramName>*.msi" 2>/dev/null
```

**Common software with known residual issues**:
- **Node.js/npm**: `%AppData%/npm-cache`, `%AppData%/npm`, `%LocalAppData%/npm-cache`
- **Python/pip**: `%AppData%/pip`, `%LocalAppData%/pip`, `%AppData%/Python`
- **VS Code**: `%AppData%/Code`, `%LocalAppData%/Programs/Microsoft VS Code`
- **WPS Office**: `%AppData%/Kingsoft`, `%LocalAppData%/Kingsoft`
- **Electron apps**: `%AppData%/<app-name>`, `%LocalAppData%/<app-name>`
- **Git**: `%AppData%/GitKraken`, `%LocalAppData%/GitHubDesktop`
- **Docker**: `%AppData%/Docker`, `%LocalAppData%/Docker`, `%ProgramData%/Docker`

### WSL
```bash
# Remove failed distros
wsl --unregister <distro_name> 2>/dev/null
wsl --terminate <distro_name> 2>/dev/null
# Clean downloads under 1KB (error pages)
find /c/Users/烟云/Downloads/ -name "wsl*" -size -1k -delete
```

### MSYS2 / pacman
```bash
# Remove lock files
rm -f /e/MSYS2/var/lib/pacman/db.lck
# Clean partial packages
rm -f /e/MSYS2/var/cache/pacman/pkg/*.part
# Fix broken DB
pacman -Syy --noconfirm
```

### npm / Node.js
```bash
# Clean failed installs
rm -rf node_modules/.staging
rm -rf node_modules/.cache
npm cache clean --force
```

### curl / wget downloads
```bash
# Remove error pages (small files)
find /c/Users/烟云/Downloads/ -name "*.tar.*" -size -10k -delete
find /c/Users/烟云/Downloads/ -name "*.msi" -size -1M -delete
```

### Git clones
```bash
# Remove incomplete clones (no .git/HEAD or shallow)
if [ ! -f .git/HEAD ] && [ -d .git ]; then rm -rf .git; fi
```

### Pika / AI Image Generation
**CRITICAL — DELETE BEFORE REGENERATE**: Every time an image is generated incorrectly (wrong face, wrong outfit, inconsistent character, wrong aspect ratio, wrong style), the bad output MUST be deleted BEFORE requesting a new generation. Never leave incorrect images lying around. This is a HIGH priority task, not optional cleanup.

```bash
# Find wrong-generation images on desktop
find /c/Users/烟云/Desktop/ -name "蕾蒂-*.png" -newer /tmp/marker -delete
find /c/Users/烟云/Desktop/ -name "leidi-*.png" -newer /tmp/marker -delete

# Find outdated avatar attempts  
find /c/Users/烟云/Desktop/ -name "leidi-avatar-*.png" -delete
```

**Workflow rule**: When regenerating any image:
1. ✅ Generate image → Good? Keep it.
2. ❌ Generate image → Wrong face/style/outfit? → **DELETE IMMEDIATELY** → THEN regenerate.
3. NEVER skip step 2. Deleting wrong outputs is MANDATORY, not optional.

**Desktop cleanliness check** — Run this before ending any session that involved image generation:
```bash
ls /c/Users/烟云/Desktop/*.png /c/Users/烟云/Desktop/*.jpg 2>/dev/null | while read f; do
  size=$(stat -c%s "$f" 2>/dev/null || echo 0)
  # Flag suspicious files (temp names, wrong sizes)
  case "$f" in
    *avatar-new*|*avatar-old*|*temp*) echo "STALE: $f"; rm -f "$f" ;;
  esac
done

### Dead Code / Orphaned Files
**CRITICAL — REMOVE UNUSED CODE**: After every code change, check for and DELETE code that is no longer called. This prevents code rot, reduces token waste, and keeps projects maintainable.

**When to scan**:
- After removing a feature → delete all related code
- After refactoring → delete old approach entirely  
- After generating replacement images → delete old images immediately
- After HTML/JS revisions → remove deprecated handlers and unused CSS

**Self-audit after every session**:
1. "Did I add code that replaces old code?" → **Delete old code**
2. "Did I generate new images that supersede old ones?" → **Delete old images**
3. "Are there variables/functions I declared but never call?" → **Delete them**
4. "Did I leave debug console.log statements?" → **Clean them**

```bash
# Find orphaned JS functions (no callers)
grep -rn "function oldFunc" /e/LeidiDesktopPet/ --include="*.js"
# Find unused assets
find /e/LeidiDesktopPet/assets/ -name "*.png" | while read img; do
  grep -rq "$(basename $img)" /e/LeidiDesktopPet/ || echo "ORPHAN: $img"
done
```

## Installation Record Format

After each cleanup, record in `E:\ClaudeMemory\install_log.md`:
```
| Time | Package | Method | Status | Cleanup |
|------|---------|--------|--------|---------|
| HH:MM | name | wsl/curl/pacman | fail/success | removed X files (Y MB) |
```

### Desktop Organization & Auto-Watcher
**CRITICAL — Keep the desktop clean at all times**: The desktop pet project (`E:/LeidiDesktopPet/`) includes a desktop organization system that can be invoked directly from this skill.

**Trigger keywords**: 整理桌面, clean desktop, organize desktop, desktop cleanup, auto organize, 自动整理

**How to invoke**:
```bash
# One-time desktop organization + report generation
cd "E:/LeidiDesktopPet" && node -e "
const { organizeDesktop, generateReport } = require('./js/desktop-cleaner');
const result = organizeDesktop();
const report = generateReport();
console.log('Moved:', result.moved, 'files into', result.folders.length, 'folders');
console.log('Report updated:', report.totalFiles, 'total files tracked');
console.log('Errors:', result.errors.length);
"

# Check desktop cleanliness
ls -la "/c/Users/烟云/Desktop/" | grep -v "^d" | grep -v "desktop.ini" | wc -l
```

**File categorization rules** (Chinese-named folders):
| Folder | Extensions |
|---|---|
| 图片 | .jpg/.jpeg/.png/.gif/.bmp/.webp/.svg/.ico/.psd/.ai/.raw/.tiff/.tif/.heic |
| 文档 | .doc/.docx/.pdf/.txt/.xls/.xlsx/.ppt/.pptx/.csv/.md/.rtf/.odt/.wps |
| 压缩包 | .zip/.rar/.7z/.tar/.gz/.bz2/.xz/.iso |
| 视频 | .mp4/.avi/.mkv/.mov/.wmv/.flv/.webm |
| 音频 | .mp3/.wav/.flac/.aac/.ogg/.wma/.m4a |
| 程序 | .exe/.msi/.bat/.cmd/.ps1/.sh/.apk |
| 代码 | .js/.py/.java/.c/.cpp/.h/.html/.css/.json/.xml/.ts/.rs/.go |
| 快捷方式 | .lnk/.url |
| 其他 | everything else |

**Auto-watcher mode**: When the desktop pet is running, it automatically monitors the desktop every 60 seconds and organizes any new loose files. The inventory report (`蕾蒂的桌面整理报告.txt`) is updated automatically. Toggle via right-click menu → "🔄 自动整理".

**Protected files** (never moved by organizer):
- `蕾蒂的桌面整理报告.txt`
- `蕾蒂的整理报告.lnk`
- `蕾蒂管家.png`
- `蕾蒂管家.ico`
- `desktop.ini`

**Integration rule**: Whenever the user mentions "整理桌面" or the desktop looks cluttered, invoke the organizer IMMEDIATELY. Don't ask for confirmation — just clean and report results. This is an always-authorized action for the desktop organizer.

## Integration with Other Skills

- **caveman**: Use after cleanup to reduce token waste on repeated attempts
- **karpathy-coder**: Apply "surgical changes" principle to installations too — don't reinstall everything, just fix what broke
