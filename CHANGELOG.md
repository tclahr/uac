# Changelog

All notable changes to this project will be documented in this file.

## 3.4.0 (2026-09-08)

### Highlights

- New AI tool artifacts — collect forensic artifacts from modern AI-assisted development environments.

### Artifacts

- `files/applications/ai_tools/amp.yaml`: Adds collection of Amp session data, config, and credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/claude_code.yaml`: Adds collection of Claude Code session logs, config, and credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/claude_code.yaml`: Updated to also collect pre-edit file history, tool results, auto-memory, plans, shell snapshots, hook scripts and IDE lock files [linux, macos]. (by [ecapuano](https://github.com/ecapuano))
- `files/applications/ai_tools/claude_desktop.yaml`: Adds collection of Claude Desktop transcripts, config, credentials, storage, skill/plugin definitions, and app logs [macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/codebuff.yaml`: Adds collection of Codebuff chat logs, config, and credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/codex.yaml`: Adds collection of OpenAI Codex CLI session logs, config, and auth [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/codex.yaml`: Updated to also collect state, thread-history and log SQLite databases with WAL/SHM sidecars, legacy sqlite databases, AGENTS.md, rules, shell snapshots and installation_id; excludes tmp and cache trees [linux, macos]. (by [ecapuano](https://github.com/ecapuano))
- `files/applications/ai_tools/copilot.yaml`: Adds collection of GitHub Copilot CLI OTEL usage logs, config, and host token/config store [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/copilot.yaml`: Updated to also collect session workspace metadata, plans and checkpoints, the session store database with WAL/SHM sidecars and logs; adds VS Code Copilot Chat conversation transcripts, agent-mode edit snapshots and extension session store [linux, macos]. (by [ecapuano](https://github.com/ecapuano))
- `files/applications/ai_tools/cursor.yaml`: Adds collection of Cursor global data, IDE settings, workspace state, history, and logs [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/droid.yaml`: Adds collection of Droid session settings, config, and auth [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/gemini.yaml`: Adds collection of Gemini CLI chat logs, config, and OAuth credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/gemini.yaml`: Updated to also collect custom commands and policies (TOML), GEMINI.md and memory files, and per-project root markers; excludes downloaded binaries, shadow git checkpoints and the browser profile [linux, macos]. (by [ecapuano](https://github.com/ecapuano))
- `files/applications/ai_tools/goose.yaml`: Adds collection of Goose session database and config [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/hermes.yaml`: Adds collection of Hermes Agent state database and config [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/kilo.yaml`: Adds collection of Kilo session database and config [linux, macos].
- `files/applications/ai_tools/kimi.yaml`: Adds collection of Kimi session wire logs, config, and credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/kiro.yaml`: Adds collection of Kiro global config, MCP, agents, steering, prompts, skills, sessions, and CLI/IDE data [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/openclaw.yaml`: Adds collection of OpenClaw session logs, config, and auth [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/opencode.yaml`: Adds collection of OpenCode session data, config, and credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/opencode.yaml`: Updated to also collect SQLite WAL/SHM sidecars, logs, JSONC config, agent and command definitions and the state directory; excludes node_modules, cloned repos and snapshots [linux, macos]. (by [ecapuano](https://github.com/ecapuano))
- `files/applications/ai_tools/pi_agent.yaml`: Adds collection of pi-agent session logs, config, and credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_tools/qwen.yaml`: Adds collection of Qwen Code chat logs, config, and OAuth credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/system/macos_privilegedhelpertools.yaml`: Added collection of macOS PrivilegedHelperTools, which may be used for persistence [macos]. (by [F9mc](https://github.com/F9mc))
- `files/system/trash.yaml`: Added collection of the entire Trash directory contents [freebsd, linux, macos, netbsd, openbsd]. (by [F9mc](https://github.com/F9mc))
- `live_response/containers/docker.yaml`: Updated to extend docker artifacts collection on macos [macos]. (by [sudesh0sudesh](https://github.com/sudesh0sudesh))
- `live_response/network/netstat.yaml`: Updated to include `netstat -Aan` [aix].
- `live_response/network/rmsock.yaml`: Identify process ownership for TCP network connections. Used to associate PIDs with network activity on AIX systems where lsof is unavailable [aix].
- `live_response/process/fstat.yaml`: Updated to include `fstat -n` [freebsd, netbsd, netscaler, openbsd].
- `live_response/process/ps.yaml`:
  - Updated to include `ps -eo user,pid,ppid,pcpu,pmem,tty,stat,lstart,args` [freebsd, linux, macos, netbsd, netscaler, openbsd].
  - Updated to include `ps -eo user,pid,ppid,pcpu,pmem,tty,stat,etime,args` [aix, freebsd, linux, macos, netbsd, netscaler, openbsd].
  - Updated to include `ps -eo user,pid,ppid,pcpu,pmem,tty,s,etime,args` [solaris].
- `memory_dump/avml.yaml`: Adjusted to work with the new `avml` command-line arguments [linux].

### Removed Artifacts

- `live_response/process/ps.yaml`:
  - `ps auxwwwf`, `ps -deaf` and `ps -efl` commands were removed.
  - `date` command was removed. The exact date and time when `ps` was executed can be checked in the `uac.log` file.

### Fixed

- Fixed `xargs` backslash escape issue. (#458)

### Tools

- Updated `avml` to v0.20.0 and moved it to the `bin/linux/x86_64` directory, as it is a specific binary for x86 64-bit CPUs.
