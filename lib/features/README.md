# features/

Self-contained feature modules. Each feature owns its own models, providers, screens, and widgets, keeping coupling between features minimal.

## What belongs here

Each feature lives in its own sub-directory following this structure:

```
features/
  auth/
    models/        # Data classes, DTOs, entities
    providers/     # Riverpod providers (@riverpod annotated)
    screens/       # Full-screen page widgets
    widgets/       # Feature-specific UI components
  home/
    ...
```

- Screens routed to by GoRouter.
- Riverpod providers that manage feature-specific state and data fetching.
- Models and DTOs consumed only by this feature.
- Widgets used exclusively within this feature's screens.

## What does NOT belong here

- Shared widgets used across multiple features — those belong in `core/widgets/`.
- Global state or app-wide providers — those belong in `core/` or a top-level `providers/` file.
- Routing definitions — route paths are registered in `routing/router.dart`.

## Example file

`auth/screens/login_screen.dart` — the login page widget that reads from `auth/providers/auth_provider.dart` and navigates via GoRouter on successful sign-in.
