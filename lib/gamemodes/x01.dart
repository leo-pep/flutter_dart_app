import 'package:flutter/material.dart';

class X01Game {
  final List<String> players;
  final int startingScore;
  late List<int> scores;
  late List<List<int>> history;
  int currentPlayer = 0;

  X01Game({required this.players, required this.startingScore}) {
    scores = List.filled(players.length, startingScore);
    history = List.generate(players.length, (_) => []);
  }

  double average(int index) {
    final throws = history[index];
    if (throws.isEmpty) return 0;
    final total = throws.reduce((a, b) => a + b);
    return total / throws.length;
  }

  /// Returns: (winnerName or null, bust)
  Map<String, dynamic> submitScore(int value) {
    if (value < 0 || value > 180) {
      return {'error': 'Score must be between 0 and 180'};
    }
    final newScore = scores[currentPlayer] - value;
    if (newScore < 0) {
      history[currentPlayer].add(0); // Bust
      currentPlayer = (currentPlayer + 1) % players.length;
      return {'bust': true};
    } else if (newScore == 0) {
      scores[currentPlayer] = 0;
      history[currentPlayer].add(value);
      String winner = players[currentPlayer];
      return {'winner': winner};
    } else {
      scores[currentPlayer] = newScore;
      history[currentPlayer].add(value);
      currentPlayer = (currentPlayer + 1) % players.length;
      return {};
    }
  }

  void undoLastScore() {
    final lastPlayer = (currentPlayer - 1 + players.length) % players.length;
    if (history[lastPlayer].isNotEmpty) {
      final last = history[lastPlayer].removeLast();
      scores[lastPlayer] += last;
      currentPlayer = lastPlayer;
    }
  }

  void bust() {
    history[currentPlayer].add(0);
    currentPlayer = (currentPlayer + 1) % players.length;
  }

  void clearScoreInput(TextEditingController controller) {
    controller.clear();
  }
}

