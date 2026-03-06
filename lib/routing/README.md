# routing/

GoRouter configuration and route-related helpers. All navigation paths are declared here so the app has a single source of truth for its route tree.

## What belongs here

- The top-level `GoRouter` instance and its route definitions.
- Route path constants (e.g. `/login`, `/home`, `/profile/:id`).
- Redirect guards (e.g. redirect unauthenticated users to the login screen).
- Route-level transition builders, if custom page transitions are needed.

## What does NOT belong here

- Screen widgets — those live in their feature's `screens/` folder.
- Navigation UI (e.g. a bottom navigation bar) — that belongs in the feature or `core/widgets/`.
- Deep-link parsing logic beyond what GoRouter provides natively.

## Example file

`router.dart` — defines the `GoRouter` instance with the full route tree, redirect logic, and error page.
