# InYogeshwar-Termux-Setup

**Android + Termux only.** A menu-driven setup helper for AI coding CLIs and a colorful terminal environment.

> Status: v0.3.1 / experimental. This is not a promise that every desktop CLI supports Android.

## Features

- Install All Compatible Tools or choose tools individually
- Essential Termux packages: Git, curl, wget, Node.js/npm, Python, editors and utilities
- AI CLI install attempts with explicit Android compatibility warnings; npm installs do not use `--force` and use bounded network retries
- Update, repair/diagnostics and uninstall menu
- Zsh + Powerlevel10k setup
- Optional Android APK build setup: Java 17, Gradle, Android SDK Platform, native Termux build tools, Gradle wrapper and a non-destructive test APK
- Logs at `~/.local/state/inyogeshwar-termux-setup/setup.log`
- Existing `.zshrc` is backed up before the setup block is appended
- OpenCode's own TUI settings are not modified
- Android APK build support is experimental; SDK manager and Gradle builds may fail depending on device, architecture and Termux packages.

## Quick start (one command, no curl bootstrap)

Open Termux and run:

```bash
apt update && apt full-upgrade -y && apt install -y git && git clone --depth 1 https://github.com/inyogeshwar/InYogeshwar-Termux-Setup.git "$HOME/InYogeshwar-Termux-Setup" && bash "$HOME/InYogeshwar-Termux-Setup/setup.sh"
```

This sequence upgrades Termux packages **before** downloading or installing project dependencies. It uses Git to fetch the repository; the bootstrap itself does not require the `curl` executable. The setup script repeats the package consistency upgrade as a safety check, then launches the interactive menu.

If the project folder already exists, do not run the clone command again. Use:

```bash
cd "$HOME/InYogeshwar-Termux-Setup" && bash setup.sh
```

From the menu, choose **1** for essential packages + compatible AI CLI installation attempts + Zsh theme. Choose **9** separately for the optional Android APK build toolchain. Experimental CLI and SDK steps retain their compatibility warnings and confirmations.

## Package manager recovery

If you see an error such as:

```text
CANNOT LINK EXECUTABLE "curl": cannot locate symbol "SSL_set_quic_tls_early_data_enabled"
```

it usually indicates a mixed or incomplete package/library upgrade. Do not delete Termux libraries manually and do not try to repair this by reinstalling only curl. Run:

```bash
apt update && apt full-upgrade -y
```

Close Termux completely, reopen it, then test:

```bash
curl --version
```

If `apt full-upgrade` itself fails, capture the complete output and resolve the repository/package-manager error before continuing. The installer stops when the full upgrade fails; it will not claim that the setup succeeded.

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

## Android APK build setup

Open the main menu and select **9) Android APK Build Setup**. Install Java/Gradle/native tools first, then attempt SDK Platform + Build Tools installation. Generate a reusable Gradle wrapper with `addwrapper` inside a project. The optional test project is created at `~/inyogeshwar-android-build-test` and is never overwritten. SDK manager and APK build success still require validation on a real Termux/Android device.

## Official references

- OpenCode v2 install: https://opencode.ai/docs/
- OpenCode Android platform issue: https://github.com/anomalyco/opencode/issues/47612
- Gemini CLI install: https://geminicli.com/docs/get-started/installation/
- Claude Code setup: https://docs.anthropic.com/en/docs/claude-code/getting-started
- Codex CLI: https://github.com/openai/codex
- Antigravity CLI: https://antigravity.google/docs/cli/install

## License

MIT
