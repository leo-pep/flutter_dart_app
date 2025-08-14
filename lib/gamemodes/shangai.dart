class ShangaiGame {
  final List<String> players;
  int shangaiRound = 1;
  late List<List<Map<String, dynamic>>> shangaiTurns;
  int currentPlayer = 0;
  List<Map<String, dynamic>> currentTurn = [];

  ShangaiGame({required this.players}) {
    shangaiTurns = List.generate(players.length, (_) => []);
  }

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
    for (var dart in currentTurn) {
      String type = dart['type'];
      if (type == 'Miss') continue;
      if (type == 'Shangai') {
        shangai = true;
        s = d = t = true;
        score = 3 * shangaiRound + 2 * shangaiRound + shangaiRound;
        break;
      }
      if (type.startsWith('S')) { score += shangaiRound; s = true; }
      if (type.startsWith('D')) { score += 2 * shangaiRound; d = true; }
      if (type.startsWith('T')) { score += 3 * shangaiRound; t = true; }
    }
    shangaiTurns[currentPlayer].add({'turn': List.from(currentTurn), 'score': score, 'shangai': shangai || (s && d && t)});
    currentTurn.clear();
    // Check win
    if (shangai || (s && d && t)) {
      return currentPlayer;
    } else {
      // Next round or next player
      if (currentPlayer == players.length - 1) {
        if (shangaiRound == 7) {
          // End game, highest score wins
          int maxScore = 0, winner = 0;
          for (int i = 0; i < players.length; i++) {
            int total = shangaiTurns[i].fold(0, (a, b) => a + ((b['score'] ?? 0) as int));
            if (total > maxScore) { maxScore = total; winner = i; }
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
