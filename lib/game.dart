enum Piece { tiger, goat }

class Move {
  final int from, to;
  final int? captured;
  const Move(this.from, this.to, [this.captured]);
}

class Game {
  List<Piece?> board;
  Piece turn;
  int placed, captured, quiet;
  String? result;
  final Map<String, int> repetitions;

  Game()
      : board = List.filled(25, null),
        turn = Piece.goat,
        placed = 0,
        captured = 0,
        quiet = 0,
        repetitions = {} {
    for (final i in [0, 4, 22]) { board[i] = Piece.tiger; }
  }

  Game._(this.board, this.turn, this.placed, this.captured, this.quiet,
      this.result, this.repetitions);
  Game copy() => Game._(List.of(board), turn, placed, captured, quiet,
      result, Map.of(repetitions));

  static bool connected(int a, int b) {
    if (a < 0 || b < 0 || a >= 25 || b >= 25 || a == b) return false;
    final dr = (a ~/ 5 - b ~/ 5).abs();
    final dc = (a % 5 - b % 5).abs();
    if (dr + dc == 1) return true;
    return dr == 1 && dc == 1 && (a ~/ 5 + a % 5).isEven;
  }

  List<Move> moves(int from) {
    if (from < 0 || from >= 25 || board[from] == null) return [];
    final piece = board[from];
    if (piece == Piece.goat && placed < 16) return [];
    final list = <Move>[];
    for (var to = 0; to < 25; to++) {
      if (board[to] != null) continue;
      if (connected(from, to)) {
        list.add(Move(from, to));
        continue;
      }
      final dr = to ~/ 5 - from ~/ 5;
      final dc = to % 5 - from % 5;
      if (piece == Piece.tiger &&
          ((dr.abs() == 2 && dc == 0) ||
           (dc.abs() == 2 && dr == 0) ||
           (dr.abs() == 2 && dc.abs() == 2))) {
        final mid = (from ~/ 5 + dr ~/ 2) * 5 + from % 5 + dc ~/ 2;
        if (board[mid] == Piece.goat && connected(from, mid) && connected(mid, to)) {
          list.add(Move(from, to, mid));
        }
      }
    }
    return list;
  }

  bool hasMove(Piece side) {
    if (side == Piece.goat && placed < 16) return board.contains(null);
    for (var i = 0; i < 25; i++) {
      if (board[i] == side && moves(i).isNotEmpty) return true;
    }
    return false;
  }

  bool place(int to) {
    if (result != null || turn != Piece.goat || placed >= 16 ||
        to < 0 || to >= 25 || board[to] != null) return false;
    board[to] = Piece.goat;
    placed++;
    quiet = 0;
    finishTurn();
    return true;
  }

  bool move(int from, int to) {
    if (result != null || from < 0 || from >= 25 || board[from] != turn) return false;
    final choices = moves(from).where((m) => m.to == to);
    if (choices.isEmpty) return false;
    final choice = choices.first;
    board[to] = board[from];
    board[from] = null;
    if (choice.captured != null) {
      board[choice.captured!] = null;
      captured++;
      quiet = 0;
    } else {
      quiet++;
    }
    finishTurn();
    return true;
  }

  void finishTurn() {
    turn = turn == Piece.goat ? Piece.tiger : Piece.goat;
    if (captured >= 5) { result = 'Tigers win!'; return; }
    if (!hasMove(Piece.tiger)) { result = 'Goats win!'; return; }
    if (turn == Piece.goat && !hasMove(Piece.goat)) {
      result = 'Tigers win!'; return;
    }
    final key = '${board.map((p) => p?.index ?? 2).join()}-${turn.index}-$placed';
    repetitions[key] = (repetitions[key] ?? 0) + 1;
    if (repetitions[key]! >= 3 || (placed == 16 && quiet >= 100)) {
      result = 'Draw — well played!';
    }
  }
}
