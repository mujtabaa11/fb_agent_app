# core/theme/

Design-system tokens and `ThemeData` factories. All colours, typography scales, spacing values, and component-level style overrides are defined here so the entire app draws from a single source of truth.

## What belongs here

- `ThemeData` factory functions for light and dark modes.
- Colour palettes (`AppColors`) and semantic colour mappings.
- Typography scale definitions (`AppTextStyles`).
- Spacing / sizing constants (`AppSpacing`).
- Component-level theme overrides (e.g. `elevatedButtonTheme`, `inputDecorationTheme`).

## What does NOT belong here

- Widget implementations — those belong in `core/widgets/` or feature screens.
- Runtime-changing user preferences (e.g. "user selected dark mode") — that state lives in a Riverpod provider.
- Raw hex colour values scattered in other files — always reference tokens defined here.

## Example file

`app_theme.dart` — exposes `AppTheme.light()` and `AppTheme.dark()` which return fully configured `ThemeData` instances.
