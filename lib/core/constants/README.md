# core/constants/

Centralised, app-wide constant values. Every magic number, static string, or environment-derived config should live here rather than being scattered across feature modules.

## What belongs here

- Environment-dependent config (API base URL, timeout durations, etc.) read from dotenv at runtime.
- Static UI strings that are not yet managed by the l10n/ARB system.
- Numeric constants shared across features (animation durations, pagination limits, etc.).
- Enum-like groupings of related values (e.g. supported image MIME types).

## What does NOT belong here

- Feature-specific constants — keep those inside the feature module's own directory.
- Theme tokens (colours, typography, spacing) — those belong in `core/theme/`.
- Localised strings — once a string is translated it moves to the ARB files in `l10n/`.

## Example file

`app_constants.dart` — contains `AppConstants.baseUrl` (from dotenv).
