# Changelog

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
