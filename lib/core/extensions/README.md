# core/extensions/

Dart extension methods on framework and language types. Extensions here are shared across the entire codebase; they keep widget trees and business logic concise by encapsulating common transformations.

## What belongs here

- Extensions on `BuildContext` (e.g. `context.textTheme`, `context.screenWidth`).
- Extensions on `String` (e.g. `capitalize()`, `isValidEmail()`).
- Extensions on `DateTime`, `num`, collections, or other standard library types.
- Extensions on Flutter types like `Color` or `EdgeInsets`.

## What does NOT belong here

- Feature-specific helpers — keep those inside the feature module.
- Full utility classes with static methods — those belong in `core/utils/`.
- Anything that introduces a new dependency just for the extension.

## Example file

`context_extensions.dart` — adds `context.screenWidth`, `context.textTheme`, and `context.showSnackBar(message)` to `BuildContext`.
