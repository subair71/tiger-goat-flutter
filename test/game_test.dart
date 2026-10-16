import 'package:flutter_test/flutter_test.dart';
import 'package:tiger_goat/game.dart';
import 'package:tiger_goat/main.dart';

void main() {
  test('starts with three tigers and sixteen goats in reserve', () {
    final game = Game();
    expect(game.board.where((p) => p == Piece.tiger).length, 3);
    expect(game.placed, 0);
    expect(game.turn, Piece.goat);
    expect(game.place(0), false);
    expect(game.place(12), true);
    expect(game.turn, Piece.tiger);
    expect(game.place(13), false);
  });
  test('capture removes exactly one goat and changes turn', () {
    final game = Game();
    game.place(1);
    expect(game.move(0, 2), true);
    expect(game.board[1], null);
    expect(game.board[2], Piece.tiger);
    expect(game.captured, 1);
    expect(game.turn, Piece.goat);
  });
  test('occupied landing and disconnected diagonal are rejected', () {
    final game = Game();
    game.board[1] = Piece.goat;
    game.board[2] = Piece.goat;
    game.turn = Piece.tiger;
    expect(game.move(0, 2), false);
    expect(Game.connected(1, 7), false);
    expect(Game.connected(4, 5), false);
    expect(Game.connected(0, 6), true);
  });
  test('goats can move only after all sixteen have been placed', () {
    final game = Game();
    game.board[12] = Piece.goat;
    expect(game.move(12, 13), false);
    game.placed = 16;
    expect(game.move(12, 13), true);
  });
  test('fifth capture ends game and prevents further turns', () {
    final game = Game();
    game.captured = 4;
    game.place(1);
    expect(game.move(0, 2), true);
    expect(game.result, 'Tigers win!');
    expect(game.place(3), false);
  });
  test('all three trapped tigers give goats victory', () {
    final game = Game();
    game.board = List.filled(25, null);
    for (final i in [0, 1, 2]) { game.board[i] = Piece.tiger; }
    for (var i = 3; i < 19; i++) { game.board[i] = Piece.goat; }
    game.placed = 16;
    game.finishTurn();
    expect(game.result, 'Goats win!');
  });
  test('snapshot does not share mutable board or repetition data', () {
    final game = Game();
    final snapshot = game.copy();
    game.place(12);
    expect(snapshot.board[12], null);
    expect(snapshot.placed, 0);
    expect(snapshot.repetitions, isEmpty);
  });
  testWidgets('game opens and goat placement updates reserve', (tester) async {
    await tester.pumpWidget(const TigerGoatApp());
    expect(find.text('Goats’ turn'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Row 3, column 3, empty'));
    await tester.pumpAndSettle();
    expect(find.text('Tigers’ turn'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    await tester.ensureVisible(find.text('Undo'));
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Goats’ turn'), findsOneWidget);
  });
}
