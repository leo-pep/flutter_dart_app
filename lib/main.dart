import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(DartScoreboardApp());
}

class DartScoreboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart Scoreboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> players = [];
  final TextEditingController _controller = TextEditingController();
  int selectedStartingScore = 301;
  final List<int> possibleModes = [101, 201, 301, 501, 701, 901];

  void _addPlayer(String name) {
    if (name.isNotEmpty && !players.contains(name)) {
      setState(() {
        players.add(name);
      });
    }
  }

  void _removePlayer(String name) {
    setState(() {
      players.remove(name);
    });
  }

  void _startGame() {
    if (players.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GamePage(players: players, startingScore: selectedStartingScore),
        ),
      );
    }
  }

  void _showAddPlayerDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ajouter un joueur'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Nom du joueur'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _addPlayer(_controller.text.trim());
              _controller.clear();
              Navigator.pop(context);
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scoreboard Fléchettes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedStartingScore,
              decoration: InputDecoration(
                labelText: 'Mode de jeu',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedStartingScore = value);
                }
              },
              items: possibleModes
                  .map((mode) => DropdownMenuItem(
                value: mode,
                child: Text('$mode'),
              ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final p = players[index];
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text(p),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _removePlayer(p),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddPlayerDialog,
                  icon: Icon(Icons.person_add),
                  label: Text('Ajouter Joueur'),
                ),
                FilledButton.icon(
                  onPressed: _startGame,
                  icon: Icon(Icons.play_arrow),
                  label: Text('Lancer Partie ($selectedStartingScore)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  final List<String> players;
  final int startingScore;

  GamePage({required this.players, required this.startingScore});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late List<int> scores;
  late List<List<int>> history;
  int currentPlayer = 0;
  final TextEditingController _scoreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    scores = List.filled(widget.players.length, widget.startingScore);
    history = List.generate(widget.players.length, (_) => []);
  }

  double _average(int index) {
    final throws = history[index];
    if (throws.isEmpty) return 0;
    final total = throws.reduce((a, b) => a + b);
    return total / throws.length;
  }

  void _submitScore({int? overrideValue}) async {
    final value = overrideValue ?? int.tryParse(_scoreController.text);
    if (value == null || value < 0 || value > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Le score maximum est 180 !'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      final newScore = scores[currentPlayer] - value;
      if (newScore < 0) {
        history[currentPlayer].add(0); // Bust
      } else if (newScore == 0) {
        scores[currentPlayer] = 0;
        history[currentPlayer].add(value);
        _saveGameResult(widget.players[currentPlayer]);
        _showWinnerDialog(widget.players[currentPlayer]);
        return;
      } else {
        scores[currentPlayer] = newScore;
        history[currentPlayer].add(value);
      }
      currentPlayer = (currentPlayer + 1) % widget.players.length;
      _scoreController.clear();
    });
  }

  void _undoLastScore() {
    setState(() {
      final lastPlayer = (currentPlayer - 1 + widget.players.length) % widget.players.length;
      if (history[lastPlayer].isNotEmpty) {
        final last = history[lastPlayer].removeLast();
        scores[lastPlayer] += last;
        currentPlayer = lastPlayer;
      }
    });
  }

  void _saveGameResult(String winner) async {
    final prefs = await SharedPreferences.getInstance();
    final statsKey = 'game_stats';
    final String? existing = prefs.getString(statsKey);
    List<Map<String, dynamic>> stats = [];
    if (existing != null) {
      stats = List<Map<String, dynamic>>.from(json.decode(existing));
    }

    stats.add({
      'winner': winner,
      'players': widget.players,
      'scores': scores,
      'history': history,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await prefs.setString(statsKey, json.encode(stats));
  }

  void _showWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('🎉 $winner a gagné !'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Retour à l\'accueil'),
          )
        ],
      ),
    );
  }

  void _quitGame() {
    Navigator.pop(context);
  }

  void _burst() {
    setState(() {
      history[currentPlayer].add(0);
      currentPlayer = (currentPlayer + 1) % widget.players.length;
      _scoreController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Partie en cours'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _quitGame,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...List.generate(widget.players.length, (i) {
              final avg = _average(i).toStringAsFixed(1);
              return Card(
                elevation: 2,
                color: i == currentPlayer ? Colors.green[50] : null,
                child: ListTile(
                  title: Text('${widget.players[i]} ($avg)'),
                  trailing: Text('${scores[i]} pts'),
                ),
              );
            }),
            const SizedBox(height: 16),
            TextField(
              controller: _scoreController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Score du tour',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.icon(
                  onPressed: _submitScore,
                  icon: Icon(Icons.check),
                  label: Text('Valider'),
                ),
                OutlinedButton.icon(
                  onPressed: _undoLastScore,
                  icon: Icon(Icons.undo),
                  label: Text('Annuler'),
                ),
                TextButton.icon(
                  onPressed: _burst,
                  icon: Icon(Icons.warning_amber_rounded),
                  label: Text('Burst'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
