class ShangaiGame {
  final List<String> players;
  final String mode;
  late List<dynamic> roundTargets;
  int shangaiRound = 1;
  late List<List<Map<String, dynamic>>> shangaiTurns;
  int currentPlayer = 0;
  List<Map<String, dynamic>> currentTurn = [];

  ShangaiGame({required this.players, this.mode = 'Shangai7'}) {
    shangaiTurns = List.generate(players.length, (_) => []);
    if (mode == 'Shangai20') {
      roundTargets = List.generate(20, (i) => i + 1); // 1-20
class ShanghaiGame {
  final List<String> players;
  final String mode;
  late List<dynamic> roundTargets;
  int shanghaiRound = 1;
  late List<List<Map<String, dynamic>>> shanghaiTurns;
  int currentPlayer = 0;
  List<Map<String, dynamic>> currentTurn = [];

  ShanghaiGame({required this.players, this.mode = 'Shanghai7'}) {
    shanghaiTurns = List.generate(players.length, (_) => []);
    if (mode == 'Shanghai20') {
      roundTargets = List.generate(20, (i) => i + 1); // 1-20
    } else if (mode == 'ShanghaiBull') {
      roundTargets = List<dynamic>.from(List.generate(20, (i) => i + 1)) + ['Bull']; // 1-20, then Bull
    } else {
      roundTargets = List.generate(7, (i) => i + 1); // 1-7
    }
  }

  int get maxRound => roundTargets.length;
  dynamic get currentTarget => roundTargets[shangaiRound - 1];

  void addDart(String type) {
    if (currentTurn.length >= 3) return;
    currentTurn.add({'type': type});
  }

  void cancelLastDart() {
    if (currentTurn.isNotEmpty) currentTurn.removeLast();
  }

  /// Returns winner index if game ends, otherwise null
  int? endTurn() {
    int score = 0;
    bool shangai = false;
    bool s = false, d = false, t = false;
    final target = currentTarget;
    for (var dart in currentTurn) {
      String type = dart['type'];
      if (type == 'Miss') continue;
      if (type == 'Shangai') {
        // Only allow Shangai if not Bull round in ShangaiBull mode
        if (!(mode == 'ShangaiBull' && target == 'Bull')) {
          shangai = true;
          s = d = t = true;
          if (target == 'Bull') {
            score = 50 + 75 + 25; // S=25, D=50, T=75
          } else if (target is int) {
            score = (3 * target + 2 * target + target).toInt();
          }
        }
        break;
      }
      if (type.startsWith('S')) { score += target == 'Bull' ? 25 : (target is int ? target : 0); s = true; }
      if (type.startsWith('D')) { score += target == 'Bull' ? 50 : (target is int ? 2 * target : 0); d = true; }
      if (type.startsWith('T')) { score += target == 'Bull' ? 75 : (target is int ? 3 * target : 0); t = true; }
    }
    // No Shangai possible on Bull round in ShangaiBull mode
    bool isShangai = shangai || (s && d && t);
    if (mode == 'ShangaiBull' && target == 'Bull') isShangai = false;
    shangaiTurns[currentPlayer].add({'turn': List.from(currentTurn), 'score': score, 'shangai': isShangai});
    currentTurn.clear();
    // Check win
    if (isShangai) {
      return currentPlayer;
    } else {
      // Next round or next player
      if (currentPlayer == players.length - 1) {
        if (shangaiRound == maxRound) {
          // End game, highest score wins (AFTER last player's score is added)
          List<int> totals = List.generate(players.length, (i) => shangaiTurns[i].fold(0, (a, b) => a + ((b['score'] ?? 0) as int)));
          int maxScore = totals[0];
          int winner = 0;
          for (int i = 1; i < players.length; i++) {
            if (totals[i] > maxScore) {
              maxScore = totals[i];
              winner = i;
            }
          }
          return winner;
        } else {
          shangaiRound++;
          currentPlayer = 0;
        }
      } else {
        currentPlayer++;
      }
    }
    return null;
  }

  List<List<Map<String, dynamic>>> get turns => shangaiTurns;
  int get currentRound => shangaiRound;
}
