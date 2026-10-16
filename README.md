# Tiger & Goat — Flutter

A responsive, offline, local two-player game with **3 tigers and 16 goats**.
Includes a custom-painted 5×5 board, turn guidance, legal-move highlights,
goat placement, tiger captures, counters, undo, restart confirmation, rules,
semantic board labels, victory detection, and repetition/no-progress draws.
No backend, paid service, or third-party runtime package is required.

## Run on the web

Requires Flutter with Dart 3.3 or newer, on the PATH.

```sh
cd tiger_goat
flutter pub get
flutter run -d chrome
```

## Android / iOS

Generate native platform shells using your installed Flutter SDK:

```sh
flutter create --platforms=android,ios --project-name tiger_goat .
flutter pub get
flutter run
```

iOS requires macOS and Xcode. Android requires an Android SDK and a device or
emulator. No APK or iOS binary is included in this source package.

## Validate and build

```sh
dart format lib test
flutter analyze
flutter test
flutter build web --release
```

For GitHub Pages in a repository subdirectory, use:

```sh
flutter build web --release --base-href /YOUR-REPOSITORY/
```

## Rules of this implementation

This is an explicitly defined **5×5 board variant**, not a claim to reproduce
any particular regional triangular-board rules.

- Three tigers begin at the two upper corners and bottom center.
- Goats play first. Place one goat per goat turn until all 16 have entered play.
- Tigers take their turns throughout placement. After placement, goats move.
- Pieces move one point along a drawn line. Diagonals exist only at even-parity
  intersections, as shown on the board.
- A tiger may jump one adjacent goat into an empty point immediately beyond it
  along two connected collinear edges. The goat is removed. Captures are optional;
  only one jump is allowed per turn. Goats cannot capture.
- Goats win when every tiger is blocked. Tigers win at five captured goats or
  when goats have no legal turn after placement.
- Three repetitions of board, side-to-move, and placement count produce a draw.
  So do 100 consecutive moves without a capture after placement is complete.
- Undo restores a full previous turn, including counters and repetition state.
- New game clears the game. Closing/reloading the app resets it; there is no
  persistent save, computer opponent, or online multiplayer.

## Project layout

- `lib/game.dart`: UI-independent rules and snapshot state.
- `lib/main.dart`: responsive Material UI and board painter.
- `test/game_test.dart`: rules and widget regression tests.
- `web/index.html`: Flutter web entry point.

## Verification status

Source and archive were inspected during creation. The creation environment did
not have Flutter or Dart installed, so compilation, analyzer, tests, and visual
runtime checks have **not** been executed. Run the validation commands above
with your Flutter installation before distribution.
