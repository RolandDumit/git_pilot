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
- Use `orient_ui` as the primary source for app theming and reusable UI widgets in this project.
- Prefer building new screens and shared components with `orient_ui` primitives instead of introducing parallel styling or widget systems.
- For each presentation feature, create a `widgets/` folder inside that feature and place page-specific supporting widgets there so page files stay concise and focused on composition.
- Prefer feature-oriented organization when the app grows.
- Make dependencies injectable so BLoCs, use cases, and process-backed services remain testable.
- Add tests around use cases, repository behavior, and BLoC state transitions.
- Mock or fake process execution in tests instead of invoking real Git commands.

## Initial Intent

This project should evolve into a cross-platform Git client with a Flutter UI, BLoC-driven presentation logic, a clean architecture foundation, and process-based command execution for Git operations.

## Orient UI

This project uses Orient UI — a design system for Flutter. It replaces Material and Cupertino with neutral, customizable components.

### Rules

- **Never use Material or Cupertino widgets for theming or UI components.** Use Orient UI equivalents instead.
- Never hardcode colors, font sizes, radii, or durations. Always use Style tokens.
- Before adding a component, check if the project already has one that does the same job. Only run `orient_ui add <name>` if there's no equivalent. It prints usage examples — follow them.
- After adding a component, fix the `import 'style.dart'` path to match where `style.dart` actually lives in the project. If the CLI mentions dependencies, add those too if they don't already exist.
- These are plain Dart files in `lib/`, not a package. Edit them directly to customize.
- New custom widgets you create should also use `Style.of(context)` and Orient UI tokens to stay consistent.
- When you need a new color or token, add it to `style.dart` — don't hardcode values.

### Style System

`lib/style.dart` is the theming foundation. Wrap your app with `Style` widget.

```dart
// Access theme anywhere
final style = Style.of(context);

// Colors
style.colors.background
style.colors.foreground
style.colors.accent
style.colors.border
style.colors.success / .error / .info / .warning
style.colors.button.primary / .secondary / .destructive
style.colors.navigation.railBackground / .bottomBarBackground

// Typography
context.typography.display / .heading / .title / .subtitle / .body / .bodySmall / .caption
style.typography.body.withColor(style.colors.foreground)
textStyle.bold / .w500 / .muted(context)

// Static tokens
Style.radii.small / .medium / .large
Style.durations.fast / .normal / .slow
Style.breakpoints.desktop
```

You can add custom color fields, typography scales, or tokens directly to `lib/style.dart`.

### Components

Use `orient_ui add <name>` to add. Each is a standalone file in `lib/`.

| Instead of | Use | Add command |
|---|---|---|
| ElevatedButton, TextButton, OutlinedButton | `Button` | `orient_ui add button` |
| Switch, CupertinoSwitch | `Toggle` | `orient_ui add toggle` |
| ListTile | `Tile` | `orient_ui add tile` |
| SwitchListTile | `ToggleTile` | `orient_ui add toggle_tile` |
| Radio | `SingleChoice` | `orient_ui add single_choice` |
| RadioListTile | `SingleChoiceTile` | `orient_ui add single_choice_tile` |
| Checkbox | `MultiChoice` | `orient_ui add multi_choice` |
| CheckboxListTile | `MultiChoiceTile` | `orient_ui add multi_choice_tile` |
| AlertDialog, showDialog | `Popup.show()` | `orient_ui add popup` |
| showDialog (confirm) | `ConfirmationPopup.show()` | `orient_ui add confirmation_popup` |
| showDialog (alert) | `AlertPopup.show()` | `orient_ui add alert_popup` |
| SnackBar, ScaffoldMessenger | `Toast.show()` | `orient_ui add toast` |
| CircularProgressIndicator | `Spinner` | `orient_ui add spinner` |
| BottomNavigationBar, NavigationRail | `NavBar` | `orient_ui add nav_bar` |
| TabBar | `Tabs` | `orient_ui add tabs` |
| SegmentedButton | `SegmentBar` | `orient_ui add segment_bar` |
| PopupMenuButton | `PopoverMenu` | `orient_ui add popover_menu` |
| DropdownButton | `Picker` | `orient_ui add picker` |
| TextField (search) | `SearchField` | `orient_ui add search_field` |
| IconButton | `TappableIcon` | `orient_ui add tappable_icon` |
| Chip, Badge | `Tag` | `orient_ui add tag` |
| Card | `CardBox` | `orient_ui add card_box` |
| Banner, MaterialBanner | `InfoBanner` | `orient_ui add info_banner` |
| — | `CopyButton` | `orient_ui add copy_button` |
| — | `EmptyState` | `orient_ui add empty_state` |
