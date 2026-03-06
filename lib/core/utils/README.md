# core/utils/

Pure utility functions and helper classes that don't fit into extensions, errors, or theme. These are stateless, side-effect-free (or minimally side-effectful) helpers used across multiple features.

## What belongs here

- Validators (email format, phone number, password strength).
- Formatters (currency, date display, file size).
- Platform-detection helpers.
- Logging or crash-reporting wrappers.
- Debounce / throttle utilities.

## What does NOT belong here

- Anything with complex state or lifecycle — use a Riverpod provider instead.
- Extension methods on existing types — those belong in `core/extensions/`.
- Constants or config values — those belong in `core/constants/`.
- Feature-specific helpers — keep those inside the feature module.

## Example file

`validators.dart` — contains `Validators.isValidEmail(String value)` and `Validators.isStrongPassword(String value)` used by multiple auth-related features.
