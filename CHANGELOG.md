## 0.2.1

* Lower minimum SDK constraints from Dart `^3.11.3` / Flutter `>=3.29.0` to Dart `^3.4.0` / Flutter `>=3.22.0` for wider compatibility.

## 0.2.0

### Performance
* Cache `CallStrings.english()` as `CallStrings.englishDefaults` to prevent cascading widget rebuilds.
* Extract speaking border animation into isolated `StatefulWidget` — `ParticipantTile` is now a `StatelessWidget`.
* Keep `SpeakingIndicator` in widget tree permanently and toggle via `visible` parameter instead of destroying/recreating the `AnimationController`.
* Skip rendering `SignalStrengthIcon` when signal strength is `excellent` (the default).
* Cache screen sharer name lookup in `didUpdateWidget` instead of scanning participants on every build.
* Add `RepaintBoundary` to `FloatingPipView` child to isolate video repaints during snap animation.
* Remove `_DefaultStrings` sentinel class (~60 lines of boilerplate).

### Bug Fixes
* Show remote screen share content in personal (1:1) call layout — previously `screenShareWidget` was ignored outside group calls.

### Breaking Changes
* `CallScreen.strings` is now nullable (`CallStrings?`). Pass `null` or omit to use English defaults. Previously accepted a non-null `CallStrings` with an internal sentinel.
* `CallStrings.englishDefaults` is a new cached static field — use it instead of `CallStrings.english()` when a stable reference is needed.

## 0.1.1

* Use GitHub-hosted screenshots to reduce package size.
* Exclude build artifacts from published package.

## 0.1.0

* Initial release.
* `CallScreen` widget for personal audio, personal video, and group calls.
* Adaptive group call layouts: 2x2 grid, 2x3 grid, speaker view, screen share view.
* Draggable PiP (Picture-in-Picture) view with corner snapping.
* Animated speaking indicators and speaking tile borders.
* Signal strength indicator per participant.
* Participants panel with host actions (mute, remove).
* Customizable "more" bottom sheet with encryption label.
* Screen share banner with stop button.
* Full theming via `CallTheme` with WhatsApp preset.
* Full localization via `CallStrings` with English defaults.
* Zero external dependencies.
