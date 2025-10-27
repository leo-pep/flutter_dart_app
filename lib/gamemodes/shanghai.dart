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
  dynamic get currentTarget => roundTargets[shanghaiRound - 1];

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
    bool shanghai = false;
    bool s = false, d = false, t = false;
    final target = currentTarget;
    for (var dart in currentTurn) {
      String type = dart['type'];
      if (type == 'Miss') continue;
      if (type == 'Shanghai') {
        // Only allow Shanghai if not Bull round in ShanghaiBull mode
        if (!(mode == 'ShanghaiBull' && target == 'Bull')) {
          shanghai = true;
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
    // No Shanghai possible on Bull round in ShanghaiBull mode
    bool isShanghai = shanghai || (s && d && t);
    if (mode == 'ShanghaiBull' && target == 'Bull') isShanghai = false;
    shanghaiTurns[currentPlayer].add({'turn': List.from(currentTurn), 'score': score, 'shanghai': isShanghai});
    currentTurn.clear();
    // Check win
    if (isShanghai) {
      return currentPlayer;
    } else {
      // Next round or next player
      if (currentPlayer == players.length - 1) {
        if (shanghaiRound == maxRound) {
          // End game, highest score wins (AFTER last player's score is added)
          List<int> totals = List.generate(players.length, (i) => shanghaiTurns[i].fold(0, (a, b) => a + ((b['score'] ?? 0) as int)));
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
          shanghaiRound++;
          currentPlayer = 0;
        }
      } else {
        currentPlayer++;
      }
    }
    return null;
  }

  List<List<Map<String, dynamic>>> get turns => shanghaiTurns;
  int get currentRound => shanghaiRound;
}
