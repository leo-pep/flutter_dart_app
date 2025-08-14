class CricketGame {
  final List<String> players;
  final bool isCutThroat;
  final List<String> cricketTargets = ['15', '16', '17', '18', '19', '20', 'Bull', 'DBull'];
  late Map<String, List<int>> cricketHits;
  late List<int> cricketPoints;
  late List<List<Map<String, dynamic>>> turnHistory;
  int currentPlayer = 0;
  List<Map<String, dynamic>> currentTurn = [];

  CricketGame({required this.players, this.isCutThroat = false}) {
    cricketHits = {for (var t in cricketTargets) t: List.filled(players.length, 0)};
    cricketPoints = List.filled(players.length, 0);
    turnHistory = List.generate(players.length, (_) => []);
  }

  void addDart(String target, {int mult = 1}) {
    if (currentTurn.length >= 3) return;
    currentTurn.add({'target': target, 'mult': mult});
  }

  void cancelLastDart() {
    if (currentTurn.isNotEmpty) currentTurn.removeLast();
  }

  void endTurn() {
    for (var dart in currentTurn) {
      String t = dart['target'];
      if (t == 'Miss') continue;
      int mult = dart['mult'] ?? 1;
      if (cricketHits[t] != null) {
        int before = cricketHits[t]![currentPlayer];
        int after = before + mult;
        int extra = after > 3 ? after - 3 : 0;
        cricketHits[t]![currentPlayer] = after > 3 ? 3 : after;
        if (extra > 0) {
          int others = 0;
          for (int i = 0; i < players.length; i++) {
            if (i != currentPlayer && (cricketHits[t]?[i] ?? 0) < 3) others++;
          }
          if (others > 0) {
            int points = (t == 'Bull' ? 25 : t == 'DBull' ? 50 : int.tryParse(t) ?? 0) * extra;
            if (!isCutThroat) {
              cricketPoints[currentPlayer] += points;
            } else {
              for (int i = 0; i < players.length; i++) {
                if (i != currentPlayer && (cricketHits[t]?[i] ?? 0) < 3) cricketPoints[i] += points;
              }
            }
          }
        }
      }
    }
    turnHistory[currentPlayer].add({'turn': List.from(currentTurn)});
    currentTurn.clear();
    currentPlayer = (currentPlayer + 1) % players.length;
  }

  bool checkWin() {
    bool allClosed = cricketTargets.every((t) => (cricketHits[t]?[currentPlayer] ?? 0) == 3);
    if (!allClosed) return false;
    if (!isCutThroat) {
      int max = cricketPoints.reduce((a, b) => a > b ? a : b);
      return cricketPoints[currentPlayer] == max;
    } else {
      int min = cricketPoints.reduce((a, b) => a < b ? a : b);
      return cricketPoints[currentPlayer] == min;
    }
  }

  List<String> get targets => cricketTargets;
  Map<String, List<int>> get hits => cricketHits;
  List<int> get points => cricketPoints;
}
