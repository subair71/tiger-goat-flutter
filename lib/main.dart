import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game.dart';

void main() => runApp(const TigerGoatApp());
const forest = Color(0xFF173E35);
const cream = Color(0xFFF6F2E8);
const gold = Color(0xFFDCA75C);

class TigerGoatApp extends StatelessWidget {
  const TigerGoatApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Tiger & Goat', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(seedColor: forest, surface: cream)),
    home: const GamePage(),
  );
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Game game = Game();
  final history = <Game>[];
  int? selected;
  String message = 'Place your first goat on an empty point.';

  void tap(int index) {
    if (game.result != null) return;
    setState(() {
      if (game.turn == Piece.goat && game.placed < 16) {
        final before = game.copy();
        if (game.place(index)) { history.add(before); selected = null; updateMessage(); }
        else { message = 'Choose an empty point to place a goat.'; }
        return;
      }
      if (game.board[index] == game.turn) {
        selected = selected == index ? null : index;
        message = selected == null ? 'Select a piece to move.' :
          game.moves(index).isEmpty ? 'This piece is blocked. Choose another.' : 'Tap a glowing point to move.';
        return;
      }
      if (selected != null) {
        final before = game.copy();
        if (game.move(selected!, index)) {
          history.add(before); selected = null; updateMessage();
        } else { message = 'Follow the board lines to a highlighted point.'; }
      } else { message = 'Select one of your pieces first.'; }
    });
  }

  void updateMessage() {
    message = game.result ?? (game.turn == Piece.goat && game.placed < 16
      ? 'Place a goat on any empty point.' : 'Select a ${game.turn.name}, then a glowing point.');
  }

  Future<void> restart() async {
    final yes = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Start a new game?'),
      content: const Text('The current board and undo history will be cleared.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep playing')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('New game'))]));
    if (yes == true && mounted) setState(() { game = Game(); history.clear(); selected = null; updateMessage(); });
  }

  @override
  Widget build(BuildContext context) {
    final goatTurn = game.turn == Piece.goat;
    final destinations = selected == null ? <int>{} : game.moves(selected!).map((m) => m.to).toSet();
    return Scaffold(
      appBar: AppBar(backgroundColor: cream, title: const Text('TIGER & GOAT', style: TextStyle(
        color: forest, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 17)),
        actions: [IconButton(tooltip: 'How to play', onPressed: () => showModalBottomSheet<void>(
          context: context, isScrollControlled: true, builder: (context) => const SafeArea(child:
            SingleChildScrollView(padding: EdgeInsets.all(24), child: Rules()))), icon: const Icon(Icons.help_outline)),
          const SizedBox(width: 12)]),
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1000),
          child: LayoutBuilder(builder: (context, constraints) {
            final board = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('A game of instinct.\nA victory of strategy.', style: TextStyle(
                color: forest, fontSize: 30, height: 1.12, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              const Text('3 TIGERS  /  16 GOATS  /  TWO PLAYERS', style: TextStyle(
                fontSize: 11, letterSpacing: 1.7, color: forest)),
              const SizedBox(height: 22),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: forest,
                borderRadius: BorderRadius.circular(20)), child: Row(children: [
                  Text(goatTurn ? '🐐' : '🐯', style: const TextStyle(fontSize: 30)), const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(game.result ?? (goatTurn ? 'Goats’ turn' : 'Tigers’ turn'),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    Text(game.result == null ? (game.placed < 16 ? 'Placement phase • pass the device' : 'Movement phase • pass the device') : 'Start a new game to play again',
                      style: const TextStyle(color: Color(0xFFBCD1C4), fontSize: 12))]))])),
              const SizedBox(height: 16),
              AspectRatio(aspectRatio: 1, child: LayoutBuilder(builder: (context, size) {
                final side = size.maxWidth;
                final radius = math.min(24.0, side * .067);
                Offset point(int i) => Offset(side * (.09 + (i % 5) * .205), side * (.09 + (i ~/ 5) * .205));
                return Container(decoration: BoxDecoration(color: const Color(0xFFE9DFC9),
                  borderRadius: BorderRadius.circular(28), border: Border.all(color: const Color(0xFFD9CBAF))),
                  child: Stack(children: [Positioned.fill(child: CustomPaint(painter: BoardPainter())),
                    for (var i = 0; i < 25; i++) Positioned(left: point(i).dx - radius, top: point(i).dy - radius,
                      width: radius * 2, height: radius * 2, child: Semantics(
                        label: 'Row ${i ~/ 5 + 1}, column ${i % 5 + 1}, ${game.board[i]?.name ?? 'empty'}${destinations.contains(i) ? ', legal destination' : ''}',
                        button: true, selected: selected == i, child: Tooltip(
                          message: game.board[i]?.name ?? 'Empty point', child: Material(color: Colors.transparent,
                            child: InkWell(borderRadius: BorderRadius.circular(50), onTap: () => tap(i),
                              child: Center(child: AnimatedContainer(duration: const Duration(milliseconds: 160),
                                width: game.board[i] == null ? (destinations.contains(i) ? 23 : 10) : radius * 2 - 3,
                                height: game.board[i] == null ? (destinations.contains(i) ? 23 : 10) : radius * 2 - 3,
                                decoration: BoxDecoration(shape: BoxShape.circle,
                                  color: game.board[i] == Piece.tiger ? gold : game.board[i] == Piece.goat ? cream :
                                    destinations.contains(i) ? forest : const Color(0xFF8C806B),
                                  border: Border.all(color: selected == i ? forest : Colors.transparent, width: 3),
                                  boxShadow: game.board[i] == null ? [] : [const BoxShadow(color: Color(0x33000000), blurRadius: 5, offset: Offset(0, 3))]),
                                child: game.board[i] == null ? null : Center(child: Text(game.board[i] == Piece.tiger ? '🐯' : '🐐',
                                  style: TextStyle(fontSize: radius * 1.15))))))))))]));
              })),
              const SizedBox(height: 12),
              Semantics(liveRegion: true, child: Text(message, textAlign: TextAlign.center,
                style: const TextStyle(color: forest, fontSize: 13))),
              const SizedBox(height: 18),
              Row(children: [Expanded(child: OutlinedButton.icon(onPressed: history.isEmpty ? null : () => setState(() {
                game = history.removeLast(); selected = null; updateMessage();
              }), icon: const Icon(Icons.undo), label: const Text('Undo'))), const SizedBox(width: 12),
                Expanded(child: FilledButton.icon(onPressed: restart, icon: const Icon(Icons.refresh), label: const Text('New game')))]),
            ]);
            final info = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [Expanded(child: stat('IN RESERVE', '${16 - game.placed}', 'goats to place')),
                const SizedBox(width: 12), Expanded(child: stat('CAPTURED', '${game.captured} / 5', 'tigers’ target'))]),
              const SizedBox(height: 20),
              Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(24)), child: const Rules()),
              const SizedBox(height: 16),
              const Text('OFFLINE PLAY • ONE DEVICE\n5×5 board variant', textAlign: TextAlign.center,
                style: TextStyle(color: forest, fontSize: 11, letterSpacing: 1.2, height: 1.8)),
            ]);
            if (constraints.maxWidth >= 800) return Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(flex: 3, child: board), const SizedBox(width: 36), Expanded(flex: 2, child: info)]);
            return Column(children: [board, const SizedBox(height: 28), info]);
          }))))),
    );
  }

  Widget stat(String title, String value, String label) => Container(padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 10, letterSpacing: 1.4, color: forest)),
      Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: forest)),
      Text(label, style: const TextStyle(fontSize: 12, color: forest))]));
}

class BoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()..color = const Color(0xFFB1A181)..strokeWidth = 1.6;
    Offset point(int i) => Offset(size.width * (.09 + (i % 5) * .205), size.height * (.09 + (i ~/ 5) * .205));
    for (var a = 0; a < 25; a++) {
      for (var b = a + 1; b < 25; b++) {
        if (Game.connected(a, b)) canvas.drawLine(point(a), point(b), pen);
      }
    }
  }
  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => false;
}

class Rules extends StatelessWidget {
  const Rules({super.key});
  @override
  Widget build(BuildContext context) => const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('How to play', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: forest)),
    SizedBox(height: 18),
    Text('01  Build the herd', style: TextStyle(fontWeight: FontWeight.bold, color: forest)),
    Text('Goats go first. Place one goat on an empty point each turn. After all 16 are placed, move a goat one step along a line.'),
    SizedBox(height: 16),
    Text('02  Hunt with care', style: TextStyle(fontWeight: FontWeight.bold, color: forest)),
    Text('Tigers move one step, or jump over one adjacent goat along a straight connected line into an empty point. The jumped goat is captured. One jump per turn; captures are optional.'),
    SizedBox(height: 16),
    Text('03  Win together', style: TextStyle(fontWeight: FontWeight.bold, color: forest)),
    Text('Goats win by trapping all three tigers. Tigers win by capturing five goats, or leaving the goats without a legal turn. Three repeated positions or 100 moves without a capture after placement is a draw.'),
    SizedBox(height: 16),
    Text('Use the glowing points to find legal moves. Undo takes back one turn. This is a 5×5 board variant with diagonals only where drawn.', style: TextStyle(fontSize: 12, color: forest)),
  ]);
}
