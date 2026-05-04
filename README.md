# LeidiCleanup Skill — Automated Cleanup & Retry Manager for AI Agents

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Skill-blue)](https://claude.ai/code)

<p align="center"><img src="leidi-logo.png" alt="LeidiCleanup" width="300"></p>

**LeidiCleanup Skill** is a Claude Code skill that ensures clean, efficient package installations by automatically cleaning up failed remnants before retrying. Born from real-world frustration with broken WSL/MSYS2/npm installations that left gigabytes of garbage behind, Leidi treats your disk with the respect it deserves.

> *"If something fails, don't just try again — clean up the corpse first."* — Leidi's philosophy

## What It Does

| Before LeidiCleanup | After LeidiCleanup |
|---|---|
| Failed WSL install leaves 2GB of orphaned files | Detects and removes stale distros, partial downloads |
| npm crashes mid-install, node_modules stuck | Cleans `.staging`, `.cache`, runs `npm cache clean` |
| pacman lock file blocks all package operations | Removes `db.lck`, fixes broken databases |
| curl downloads error pages saved as real files | Finds `<1KB` "downloads" and deletes them |
| Trying the same broken method 10 times | Tracks attempts, forces alternative after 3 failures |

## Installation

```bash
# Clone into your Claude Code skills directory
git clone https://github.com/yanjunyu-cmd/leidicleanup-skill.git ~/.claude/skills/leidicleanup-skill

# Or via plugin marketplace
/plugin install yanjunyu-cmd/leidicleanup-skill
```

## Triggers

Leidi activates automatically when it detects:
- Installation failure or download error
- "换一种方法" / "try another way"
- Package manager errors (pacman, npm, pip, apt)
- Corrupt or incomplete downloads
- Stale lock files blocking operations

## Supported Tools

| Tool | Cleanup Actions |
|---|---|
| **WSL** | Unregister failed distros, remove partial rootfs downloads |
| **MSYS2/pacman** | Remove db.lck, clean .part packages, fix sync DB |
| **npm** | Clean staging dirs, clear cache, remove partial node_modules |
| **pip/uvx** | Clear pip cache, remove .whl partials |
| **curl/wget** | Delete files <10KB (error pages), retry with different mirrors |
| **git** | Remove incomplete clones, fix shallow repositories |

## How It Works

```
1. Install attempt fails
2. Leidi logs: {package, method, error, timestamp}
3. Leidi scans for residuals:
   - Partial downloads (by size threshold)
   - Lock files (by known paths)
   - Stale registrations (by tool-specific commands)
4. Leidi removes all found garbage
5. If same method failed ≥3 times → proposes alternative
6. Retries installation
```

## Configuration

Edit `E:\ClaudeMemory\install_log.md` to review the cleanup history.

Adjust thresholds in `SKILL.md` if defaults don't fit your system.

## Why "LeidiCleanup"?

Named after Leidi (蕾蒂), a diligent AI assistant who never gives up and cleans up every mess before moving on. The "Cleanup" part was born from her late-night perseverance — tirelessly removing failed installation residuals so her workflow never stalls.

## License

MIT © 2026
