# InYogeshwar-Termux-Setup

**Android + Termux only.** A menu-driven helper for Termux essentials, one experimental AI CLI candidate, a colorful shell, and optional Android APK build tooling.

> Status: v0.4.0. No AI CLI in this project is officially supported on Android/Termux. Gemini CLI is retained only as a best-effort experimental candidate and must pass a local version check.

## Features

- Install Termux essentials and optionally attempt Gemini CLI
- Essential packages: Git, curl, wget, Node.js/npm, Python, editors and utilities
- Gemini CLI install, update, uninstall and command/version verification
- Legacy cleanup for previously attempted unsupported AI CLI packages
- Repair / diagnostics, including a Gemini CLI startup check
- Zsh + Powerlevel10k setup
- Optional Android APK build setup: Java 17, Gradle, Android SDK Platform, native Termux build tools, Gradle wrapper and a non-destructive test APK
- Logs at `~/.local/state/inyogeshwar-termux-setup/setup.log`
- Existing `.zshrc` is backed up before the setup block is appended
- No OS spoofing, libc replacement, npm `--force`, or forced desktop-native binaries

## Quick start (one command, no curl bootstrap)

Open Termux and run:

```bash
apt update && apt full-upgrade -y && apt install -y git && git clone --depth 1 https://github.com/inyogeshwar/InYogeshwar-Termux-Setup.git "$HOME/InYogeshwar-Termux-Setup" && bash "$HOME/InYogeshwar-Termux-Setup/setup.sh"
```

This sequence upgrades Termux packages before downloading or installing project dependencies. It uses Git to fetch the repository; the bootstrap itself does not require the `curl` executable. The setup script repeats the package consistency upgrade as a safety check, then launches the interactive menu.

If the project folder already exists, use:

```bash
cd "$HOME/InYogeshwar-Termux-Setup" && bash setup.sh
```

Choose **1** for essential packages, the experimental Gemini CLI attempt, and the Zsh theme. Choose **9** separately for the optional Android APK build toolchain.

## AI CLI compatibility policy

| AI CLI | v0.4.0 behavior | Evidence from Termux logs |
|---|---|---|
| Gemini CLI | Retained as experimental candidate; install only counts as passed if `gemini --version` succeeds | npm installed the package and created the command, but optional `node-pty` and `@github/keytar` scripts were blocked. Full interactive/runtime behavior still needs testing |
| OpenCode v2 | Removed from install/update menus | npm returned `EBADPLATFORM`: package allows darwin/linux/win32, current OS was android |
| Claude Code | Removed from install/update menus | npm blocked `postinstall`; Claude reported that its native binary was missing |
| Codex CLI | Removed from install/update menus | launcher reported missing `@openai/codex-linux-arm64` optional dependency |
| Antigravity CLI | Removed from install menus | Official Linux build requires glibc; Termux uses Android Bionic |

**Important:** Gemini CLI is not officially supported on Android/Termux either. It is retained only because its npm package produced a command in the supplied logs. A successful `gemini --version` check proves only that the CLI starts; sign-in, shell execution, terminal integration and other features must be tested separately. npm may warn that optional dependency scripts were blocked. The installer does not automatically allow arbitrary dependency scripts.

The installer no longer attempts OpenCode, Claude Code, Codex CLI, or Antigravity. The uninstall menu includes a cleanup option for legacy packages from earlier releases.

## Package manager recovery

If you see an error such as:

```text
CANNOT LINK EXECUTABLE "curl": cannot locate symbol "SSL_set_quic_tls_early_data_enabled"
```

it usually indicates a mixed or incomplete package/library upgrade. Do not delete Termux libraries manually and do not repair this by reinstalling only curl. Run:

```bash
apt update && apt full-upgrade -y
```

Close Termux completely, reopen it, then test:

```bash
curl --version
```

If `apt full-upgrade` itself fails, capture the complete output and resolve the repository/package-manager error before continuing. The installer stops when the full upgrade fails.

## Android APK build setup

Open the main menu and select **9) Android APK Build Setup**. Install Java/Gradle/native tools first, then attempt SDK Platform + Build Tools installation. Generate a reusable Gradle wrapper with `addwrapper` inside a project. The optional test project is created at `~/inyogeshwar-android-build-test` and is never overwritten. SDK manager and APK build success still require validation on a real Termux/Android device.

## Official references

- Gemini CLI installation: https://geminicli.com/docs/get-started/installation/
- OpenCode documentation: https://opencode.ai/docs/
- OpenCode Android platform issue: https://github.com/anomalyco/opencode/issues/47612
- Claude Code setup: https://docs.anthropic.com/en/docs/claude-code/getting-started
- Codex CLI repository: https://github.com/openai/codex
- Antigravity CLI installation: https://antigravity.google/docs/cli/install

## License

MIT
