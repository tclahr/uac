# Changelog

All notable changes to this project will be documented in this file.

## DEVELOPMENT VERSION

### Highlights

### Artifacts

- `files/applications/ai_agents/amp.yaml`: Adds collection of Amp session data, config, and credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/claude_code.yaml`: Adds collection of Claude Code session logs, config, and credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/claude_desktop.yaml`: Adds collection of Claude Desktop transcripts, config, credentials, storage, skill/plugin definitions, and app logs [macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/codebuff.yaml`: Adds collection of Codebuff chat logs, config, and credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/codex.yaml`: Adds collection of OpenAI Codex CLI session logs, config, and auth [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/copilot.yaml`: Adds collection of GitHub Copilot CLI OTEL usage logs, config, and host token/config store [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/cursor.yaml`: Adds collection of Cursor global data, IDE settings, workspace state, history, and logs [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/droid.yaml`: Adds collection of Droid session settings, config, and auth [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/gemini.yaml`: Adds collection of Gemini CLI chat logs, config, and OAuth credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/goose.yaml`: Adds collection of Goose session database and config [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/hermes.yaml`: Adds collection of Hermes Agent state database and config [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/kilo.yaml`: Adds collection of Kilo session database and config [linux, macos].
- `files/applications/ai_agents/kimi.yaml`: Adds collection of Kimi session wire logs, config, and credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/kiro.yaml`: Adds collection of Kiro global config, MCP, agents, steering, prompts, skills, sessions, and CLI/IDE data [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/openclaw.yaml`: Adds collection of OpenClaw session logs, config, and auth [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/opencode.yaml`: Adds collection of OpenCode session data, config, and credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/pi_agent.yaml`: Adds collection of pi-agent session logs, config, and credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
- `files/applications/ai_agents/qwen.yaml`: Adds collection of Qwen Code chat logs, config, and OAuth credentials [linux, macos]. (by [walkingawire](https://github.com/walkingawire))
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

### Removed Artifacts

- `live_response/process/ps.yaml`:
  - `ps auxwwwf`, `ps -deaf` and `ps -efl` commands were removed.
  - `date` command was removed. The exact date and time when `ps` was executed can be checked in the `uac.log` file.

### Fixed

- Fixed `xargs` backslash escape issue. (#458)

### Tools
