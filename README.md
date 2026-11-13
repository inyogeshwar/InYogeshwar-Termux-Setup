# InYogeshwar-Termux-Setup

**Android + Termux only.** A menu-driven setup helper for AI coding CLIs and a colorful terminal environment.

> Status: MVP / experimental. This is not a promise that every desktop CLI supports Android.

## Features

- Install All Compatible Tools or choose tools individually
- Essential Termux packages: Git, curl, Node.js/npm, Python, editors and utilities
- AI CLI install attempts with explicit Android compatibility warnings
- Update, repair/diagnostics and uninstall menu
- Zsh + Powerlevel10k setup
- Logs at `~/.local/state/inyogeshwar-termux-setup/setup.log`
- Existing `.zshrc` is backed up before the setup block is appended
- OpenCode's own TUI settings are not modified

## Quick start

In Termux:

```bash
pkg update -y
pkg install -y git
git clone https://github.com/inyogeshwar/InYogeshwar-Termux-Setup.git
cd InYogeshwar-Termux-Setup
chmod +x install.sh
bash install.sh
```

If the repository has not been created yet, download/extract this project ZIP and run `bash install.sh` from its folder.

## Compatibility policy

| Tool | Installer behavior | Reason |
|---|---|---|
| Gemini CLI | Experimental npm install, asks first | Official OS list does not name Android/Termux |
| OpenCode v2 | Experimental npm install, asks first, verifies command and rolls back on failure | Official npm platform gate and Android wrapper issues have been reported |
| Claude Code | Experimental npm install, asks first | Official OS list does not name Android/Termux |
| Codex CLI | Experimental npm install, asks first | Official native binary targets do not list Android/Bionic |
| Antigravity CLI | Skipped | Official Linux build requires glibc; Termux uses Android Bionic |

The installer does not spoof the operating system, replace libc, or force desktop binaries into Termux. Compatibility can change; check upstream documentation before changing these safeguards.

## Important notes

- Install All means: attempt all tools that the user explicitly accepts as experimental, and skip tools marked incompatible.
- Some tools may require their own account, subscription, API key or authentication. This project does not provide credentials.
- Never paste API keys into issue reports or setup logs.
- The installer does not request Android storage permission automatically.
- This project does not install Flutter or desktop IDEs.
- OpenCode's dark TUI is left to OpenCode's own configuration.

## Official references

- OpenCode v2 install: https://opencode.ai/docs/
- OpenCode Android platform issue: https://github.com/anomalyco/opencode/issues/47612
- Gemini CLI install: https://geminicli.com/docs/get-started/installation/
- Claude Code setup: https://docs.anthropic.com/en/docs/claude-code/getting-started
- Codex CLI: https://github.com/openai/codex
- Antigravity CLI: https://antigravity.google/docs/cli/install

## License

MIT
