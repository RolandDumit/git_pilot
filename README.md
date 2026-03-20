# Git Pilot

Git Pilot is an open-source Git client built with Flutter for cross-platform desktop use.

The goal of the project is to provide a clean, modern desktop experience for working with Git repositories on macOS, Windows, and Linux, while keeping the codebase maintainable, testable, and easy to extend.

## What This Project Is

- A Flutter desktop application for working with Git repositories
- An open-source project intended to grow into a full cross-platform Git client
- A codebase structured around clean architecture and `bloc`-based state management
- A desktop-first experience that integrates with Git through process-backed command execution

## Project Goals

- Make common Git workflows accessible through a polished desktop UI
- Support multiple desktop platforms from a single Flutter codebase

## Repository Structure

This repository uses local Dart and Flutter packages to enforce clean architecture boundaries.

- [lib/](/home/roland/Projects/Personal/git_pilot/lib) contains the root application bootstrap and composition code
- [packages/core](/home/roland/Projects/Personal/git_pilot/packages/core) contains shared cross-cutting types
- [packages/domain](/home/roland/Projects/Personal/git_pilot/packages/domain) contains entities, contracts, and use cases
- [packages/data](/home/roland/Projects/Personal/git_pilot/packages/data) contains infrastructure and repository implementations
- [packages/presentation](/home/roland/Projects/Personal/git_pilot/packages/presentation) contains the Flutter UI and BLoC state management

Each layer package has its own `pubspec.yaml` and `lib/` directory. This is intentional: it keeps dependency rules enforceable by package boundaries rather than relying only on folder conventions inside a single app `lib/`.

## Open Source

Git Pilot is being developed as an open-source project. The intention is to build in public, keep the architecture approachable, and make it easy for contributors to understand how the app is organized as it grows.

## Status

The project is in its early stages and is currently establishing its architecture, UI direction, and Git integration foundations.
