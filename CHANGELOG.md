# Changelog

## 0.4.0 — Termux compatibility cleanup
- Keep Gemini CLI as the only best-effort experimental AI CLI candidate; require `gemini --version` to pass after installation.
- Remove OpenCode v2, Claude Code, Codex CLI and Antigravity from install and update flows based on observed Android/Termux incompatibilities.
- Simplify custom install choices to Gemini CLI, Zsh theme and essential Termux packages.
- Add diagnostics that distinguish a present Gemini command from a successful version/startup check.
- Add uninstall options for legacy unsupported CLI packages left by earlier releases.
- Update compatibility help and README with the exact errors observed on the device.
- Bump displayed project version to 0.4.0.

## 0.3.1 — OpenCode installer output and prompt fixes
- Remove npm `--force`; use normal package installation with bounded fetch retries and timeout.
- Fix confirmation prompt color rendering by printing ANSI escape sequences correctly.
- Bump displayed project version to 0.3.1.

## 0.3.0 — Safer Termux bootstrap and package recovery
- Remove the curl executable from the bootstrap download path; Git fetches the repository.
- Run `apt update` and `apt full-upgrade -y` before dependency installation.
- Stop the base package installer when package index refresh or full upgrade fails.
- Document recovery steps for mixed libcurl/OpenSSL package states.
- Keep existing project-folder and local-change safety checks.

## 0.2.0 — Android build module
- Add optional Android APK Build Setup menu and modular installer.
- Add Java 17, Gradle, Android SDK Platform, native tool override, Gradle wrapper and test APK workflows.
- Back up shell configuration before appending environment settings.
- Refuse to overwrite the test project or an existing project Gradle wrapper.
- Add Android build diagnostics and explicit experimental compatibility warnings.

## 0.1.0 — Initial MVP
- Added Termux-only guard and colorful menu
- Added essential package setup
- Added custom and all-tools installation flows
- Added experimental npm install checks for OpenCode v2, Gemini CLI, Claude Code and Codex CLI
- Added explicit Antigravity Termux incompatibility guard
- Added update, uninstall and diagnostics menus
- Added Zsh + Powerlevel10k setup with `.zshrc` backup

## Implementation note
The Hunter Ai Termux Setup v3.0 script supplied for review was treated as a feature reference. Its destructive project deletion and full `.zshrc` replacement behavior were not carried over.
