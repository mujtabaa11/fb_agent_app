# Accessibility Checklist

Follow this checklist before marking any new screen or component as done.

## 1. Interactive Elements

- [ ] Every `IconButton`, `ElevatedButton`, `FilledButton`, `TextButton`,
      `OutlinedButton`, `GestureDetector`, and `InkWell` has a `Semantics`
      wrapper with a descriptive `label` (or uses the widget's built-in
      `semanticLabel` / `tooltip` parameter).
- [ ] All semantic labels come from ARB/l10n — never hardcode user-facing
      strings in Dart files.

## 2. Touch Targets

- [ ] Every interactive element is at least **44 x 44 logical pixels**.
- [ ] Use the `AccessibleTouchTarget` wrapper (`lib/core/widgets/accessible_touch_target.dart`)
      for any element that does not natively meet the minimum.
- [ ] For Material buttons, set `minimumSize: const Size(44, 44)` in
      `ButtonStyle` or use `MaterialTapTargetSize.padded`.

## 3. Dynamic Semantics Labels

- [ ] Stateful toggles (e.g., show/hide password, play/pause, expand/collapse)
      update their `Semantics` label to reflect the **current** state.
- [ ] Theme or mode switchers include a `Semantics` wrapper whose label
      describes the control (e.g., `themeSwitcherLabel`).

## 4. Images and Icons

- [ ] Decorative icons are wrapped in `ExcludeSemantics` or use
      `Icon(icon, semanticLabel: null)`.
- [ ] Icons that convey meaning have a meaningful `Semantics` label.
- [ ] The `Image` widget uses `semanticLabel` for informational images and
      `excludeFromSemantics: true` for decorative images.

## 5. Error and Status Indicators

- [ ] Error states are conveyed by **both** color **and** text — never color
      alone.
- [ ] `SnackBar` messages contain descriptive text (no icon-only snackbars).
- [ ] Inline validation errors use `InputDecoration.errorText` so the field is
      announced as invalid by assistive technology.

## 6. Focus Order

- [ ] Verify logical tab order by navigating the screen with a keyboard or
      switch access (Tab / Shift+Tab).
- [ ] Form screens follow the order: fields top-to-bottom, then submit button.
- [ ] If the natural widget order does not produce a logical focus sequence,
      use `FocusTraversalOrder` to correct it.

## 7. Modal Focus Trap

- [ ] `showDialog`, `showModalBottomSheet`, and `showMenu` automatically trap
      focus. Verify by navigating with a screen reader — focus must not escape
      the modal.
- [ ] Custom overlays (`Overlay`, `CompositedTransformFollower`) must manually
      implement focus trapping via `FocusTrap` or equivalent.

## 8. Screen Reader Verification

- [ ] **iOS**: Navigate the entire screen with VoiceOver enabled
      (Settings > Accessibility > VoiceOver). Every control must be reachable
      and announced with a meaningful label.
- [ ] **Android**: Navigate the entire screen with TalkBack enabled
      (Settings > Accessibility > TalkBack). Confirm the same.

## 9. RTL Layout Audit

- [ ] All padding and margin use `EdgeInsetsDirectional` (not `EdgeInsets`).
- [ ] All alignment use `AlignmentDirectional` (not `Alignment`).
- [ ] Icons that imply direction (e.g., arrows) are mirrored or replaced in RTL.
- [ ] Run the RTL grep audit before committing:
      ```bash
      grep -rn "EdgeInsets\." lib/ --include="*.dart" | grep -v "EdgeInsetsDirectional"
      grep -rn "Alignment\." lib/ --include="*.dart" | grep -v "AlignmentDirectional"
      ```
