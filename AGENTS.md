# Git Pilot

## Project Overview

- This is a Flutter project written in Dart.
- The app is a Git client built with Flutter.
- State management should use the `bloc` ecosystem.
- The codebase should follow clean architecture principles.
- Command-line Git integration should go through the [`process`](https://pub.dev/packages/process) package from pub.dev.

## Architectural Direction

Use clean architecture to keep UI, business logic, and infrastructure concerns separate.

Suggested layers:

- `presentation`: Flutter widgets, pages, navigation, BLoCs, events, and states.
- `domain`: entities, repository contracts, and use cases.
- `data`: models, repository implementations, and data sources.
- `core` or `shared`: cross-cutting utilities, errors, result types, and common services.

## State Management

- Use `bloc`/`flutter_bloc` for feature state management.
- Keep BLoCs focused on orchestration and state transitions.
- Put business rules in domain use cases instead of widgets or BLoCs.
- Prefer immutable events, states, and domain models.

## Git Command Integration

- Interact with Git through the `process` package rather than calling `dart:io` processes directly.
- Encapsulate command execution behind an abstraction such as a Git service or command runner.
- Keep shell/process concerns in the data or infrastructure layer.
- Return structured results to the domain layer instead of leaking raw process details into the UI.

## Development Guidelines

- Keep UI code independent from Git execution details.
- Prefer feature-oriented organization when the app grows.
- Make dependencies injectable so BLoCs, use cases, and process-backed services remain testable.
- Add tests around use cases, repository behavior, and BLoC state transitions.
- Mock or fake process execution in tests instead of invoking real Git commands.

## Initial Intent

This project should evolve into a cross-platform Git client with a Flutter UI, BLoC-driven presentation logic, a clean architecture foundation, and process-based command execution for Git operations.
