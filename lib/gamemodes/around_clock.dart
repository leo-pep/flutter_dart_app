
class AroundClockGame {
  final List<String> players;
  late List<List<int>> aroundHits;
  late List<int> aroundTargets;
  int currentPlayer = 0;
  int dartsLeft = 3;
  List<Map<String, dynamic>> currentTurn = [];

  AroundClockGame({required this.players}) {
    aroundHits = List.generate(players.length, (_) => []);
    aroundTargets = List.filled(players.length, 1);
  }

  String targetLabel(int target) {
    if (target <= 20) return target.toString();
    if (target == 21) return 'Bull';
    if (target == 22) return 'DBull';
    return 'Done';
  }

  /// Returns winner index if game ends, otherwise null
  int? addDart(String target) {
    currentTurn.add({'target': target});
    dartsLeft--;
    int playerTarget = aroundTargets[currentPlayer];
    String targetLabelStr = targetLabel(playerTarget);
    if (target == targetLabelStr) {
      aroundHits[currentPlayer].add(playerTarget);
      aroundTargets[currentPlayer]++;
      if (aroundTargets[currentPlayer] > 22) aroundTargets[currentPlayer] = 22;
    }
    // End turn after 3 darts or if player finished
    if (dartsLeft == 0 || aroundTargets[currentPlayer] > 22) {
      if (aroundTargets[currentPlayer] > 22) {
        int winner = currentPlayer;
        resetTurn();
        return winner;
      }
      resetTurn();
      currentPlayer = (currentPlayer + 1) % players.length;
    }
    return null;
  }

  void resetTurn() {
    currentTurn.clear();
    dartsLeft = 3;
  }

  List<int> get targets => aroundTargets;
  List<List<int>> get hits => aroundHits;
}
