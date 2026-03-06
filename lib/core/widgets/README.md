# core/widgets/

Reusable UI components shared across two or more features. Widgets here are app-specific but not tied to any single feature's domain logic.

## What belongs here

- Branded buttons, cards, and input fields.
- Loading indicators and shimmer placeholders.
- Error-state widgets (e.g. a full-screen "something went wrong" view with retry).
- Empty-state illustrations.
- Responsive layout helpers (e.g. `AppScaffold` with consistent padding).

## What does NOT belong here

- Feature-specific widgets used only inside one feature — keep those in the feature's own `widgets/` folder.
- Pure layout primitives with no app-specific styling — use Flutter's built-in widgets.
- Theme definitions — those belong in `core/theme/`.

## Example file

`app_loading_indicator.dart` — a centred, brand-coloured `CircularProgressIndicator` wrapped in a `Semantics` widget with the localised "Loading..." label.
