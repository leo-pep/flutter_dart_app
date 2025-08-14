import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../gamemodes/cricket.dart';
import '../gamemodes/shangai.dart';
import '../gamemodes/around_clock.dart';
import '../gamemodes/x01.dart';

class GamePage extends StatefulWidget {
  final List<String> players;
  final int startingScore;
  final String gameMode;

  const GamePage({super.key, required this.players, required this.startingScore, required this.gameMode});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late List<int> scores;
  late List<List<int>> history;
  int currentPlayer = 0;
  final TextEditingController _scoreController = TextEditingController();

  // Game mode logic classes
  CricketGame? cricketGame;
  ShangaiGame? shangaiGame;
  AroundClockGame? aroundClockGame;
  X01Game? x01Game;

  @override
  void initState() {
    super.initState();
    scores = List.filled(widget.players.length, widget.startingScore);
    history = List.generate(widget.players.length, (_) => []);
    if (widget.gameMode == 'Cricket' || widget.gameMode == 'CutThroat') {
      cricketGame = CricketGame(
        players: widget.players,
        isCutThroat: widget.gameMode == 'CutThroat',
      );
    }
    if (widget.gameMode == 'Shangai') {
      shangaiGame = ShangaiGame(players: widget.players);
    }
    if (widget.gameMode == 'AroundClock') {
      aroundClockGame = AroundClockGame(players: widget.players);
    }
    if (widget.gameMode == 'X01') {
      x01Game = X01Game(players: widget.players, startingScore: widget.startingScore);
    }
  }

  double _average(int index) {
    if (widget.gameMode == 'X01' && x01Game != null) {
      return x01Game!.average(index);
    }
    final throws = history[index];
    if (throws.isEmpty) return 0;
    final total = throws.reduce((a, b) => a + b);
    return total / throws.length;
  }

  void _submitScore({int? overrideValue}) async {
    if (widget.gameMode == 'X01' && x01Game != null) {
      final value = overrideValue ?? int.tryParse(_scoreController.text);
      if (value == null) return;
      final result = x01Game!.submitScore(value);
      if (result['error'] != null) {
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
        if (result['winner'] != null) {
          _saveGameResult(result['winner']);
          _showWinnerDialog(result['winner']);
        }
        _scoreController.clear();
      });
      return;
    }

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
      if (widget.gameMode == 'X01' && x01Game != null) {
        x01Game!.undoLastScore();
        return;
      }
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
      'gameMode': widget.startingScore, // Use this for now
      'finalScores': List.from(scores),
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
      if (widget.gameMode == 'X01' && x01Game != null) {
        x01Game!.burst();
        _scoreController.clear();
        return;
      }
      history[currentPlayer].add(0);
      currentPlayer = (currentPlayer + 1) % widget.players.length;
      _scoreController.clear();
    });
  }

  Widget buildCricketTable() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cricket Progress', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Player', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold))),
                  ...cricketGame!.cricketTargets.map((t) => DataColumn(label: Text(t, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)))),
                  DataColumn(label: Text('Points', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold))),
                ],
                rows: [
                  for (int i = 0; i < widget.players.length; i++)
                    DataRow(cells: [
                      DataCell(Text(widget.players[i], style: GoogleFonts.montserrat())),
                      ...cricketGame!.cricketTargets.map((t) {
                        int hits = cricketGame!.cricketHits[t]?[i] ?? 0;
                        return DataCell(Container(
                          alignment: Alignment.center,
                          child: Text('$hits', style: GoogleFonts.montserrat(fontWeight: hits == 3 ? FontWeight.bold : FontWeight.normal, color: hits == 3 ? Colors.green : Colors.black)),
                        ));
                      }),
                      DataCell(Text('${cricketGame!.cricketPoints[i]}', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold))),
                    ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShangaiTable() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shangai Progress', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)),
            DataTable(
              columns: [
                DataColumn(label: Text('Player', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Score', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Shangai', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold))),
              ],
              rows: [
                for (int i = 0; i < widget.players.length; i++)
                  DataRow(cells: [
                    DataCell(Text(widget.players[i], style: GoogleFonts.montserrat())),
                    DataCell(Text(
                      shangaiGame!.shangaiTurns[i].fold<int>(0, (a, b) => a + ((b['score'] ?? 0) as int)).toString(),
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      shangaiGame!.shangaiTurns[i].any((b) => b['shangai'] == true) ? '✔' : '',
                      style: GoogleFonts.montserrat(color: Colors.green, fontWeight: FontWeight.bold),
                    )),
                  ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAroundClockTable() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Around the Clock Progress', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)),
            DataTable(
              columns: [
                DataColumn(label: Text('Player', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Current Target', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Hits', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold))),
              ],
              rows: [
                for (int i = 0; i < widget.players.length; i++)
                  DataRow(cells: [
                    DataCell(Text(widget.players[i], style: GoogleFonts.montserrat())),
                    DataCell(Text(
                      aroundClockGame!.targetLabel(aroundClockGame!.aroundTargets[i]),
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      aroundClockGame!.aroundHits[i].length.toString(),
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                    )),
                  ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDoubleTripleDialog(String target) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Multiplier for $target'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('double'),
            child: Text('Double'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('triple'),
            child: Text('Triple'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
    if (result == 'double') {
      setState(() {
        cricketGame!.currentTurn.add({'target': target, 'mult': 2});
      });
    } else if (result == 'triple') {
      setState(() {
        cricketGame!.currentTurn.add({'target': target, 'mult': 3});
      });
    }
  }

  Widget buildInputUI() {
    if (widget.gameMode == 'X01') {
      return buildNumpadAndButtons();
    }
    if (widget.gameMode == 'Cricket' || widget.gameMode == 'CutThroat') {
      // Cricket input: 15-20, Bull, Miss, multiple clicks, cancel
      List<String> buttons = [...cricketGame!.targets, 'Miss'];
      return Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: buttons.map((b) => GestureDetector(
              onLongPress: cricketGame!.currentTurn.length >= 3 ? null : () async {
                if (b == 'Bull') {
                  setState(() {
                    cricketGame!.currentTurn.add({'target': b, 'mult': 2});
                  });
                } else if (b != 'Miss') {
                  await _showDoubleTripleDialog(b);
                }
              },
              child: ElevatedButton(
                onPressed: cricketGame!.currentTurn.length >= 3 ? null : () {
                  setState(() {
                    cricketGame!.currentTurn.add({'target': b, 'mult': 1});
                  });
                },
                child: Text(b, style: GoogleFonts.montserrat(fontSize: 20)),
              ),
            )).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.undo),
                label: Text('Cancel Last'),
                onPressed: cricketGame!.currentTurn.isNotEmpty ? () {
                  setState(() {
                    cricketGame!.currentTurn.removeLast();
                  });
                } : null,
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text('End Turn'),
                onPressed: cricketGame!.currentTurn.isNotEmpty ? () {
                  // Apply turn
                  for (var dart in cricketGame!.currentTurn) {
                    String t = dart['target'];
                    if (t == 'Miss') continue;
                    int mult = dart['mult'] ?? 1;
                    if (cricketGame!.hits[t] != null) {
                      int before = cricketGame!.hits[t]![currentPlayer];
                      int after = before + mult;
                      int extra = after > 3 ? after - 3 : 0;
                      cricketGame!.hits[t]![currentPlayer] = after > 3 ? 3 : after;
                      if (extra > 0) {
                        int others = 0;
                        for (int i = 0; i < widget.players.length; i++) {
                          if (i != currentPlayer && (cricketGame!.hits[t]?[i] ?? 0) < 3) others++;
                        }
                        if (others > 0) {
                          int points = (t == 'Bull' ? 25 : int.tryParse(t) ?? 0) * extra;
                          if (widget.gameMode == 'Cricket') {
                            cricketGame!.points[currentPlayer] += points;
                          } else {
                            // CutThroat: add points to opponents who haven't closed
                            for (int i = 0; i < widget.players.length; i++) {
                              if (i != currentPlayer && (cricketGame!.hits[t]?[i] ?? 0) < 3) cricketGame!.points[i] += points;
                            }
                          }
                        }
                      }
                    }
                  }
                  cricketGame!.turnHistory[currentPlayer].add({'turn': List.from(cricketGame!.currentTurn)});
                  cricketGame!.currentTurn.clear();
                  // Check win
                  bool allClosed = cricketGame!.targets.every((t) => (cricketGame!.hits[t]?[currentPlayer] ?? 0) == 3);
                  bool win = false;
                  if (allClosed) {
                    if (widget.gameMode == 'Cricket') {
                      win = cricketGame!.points[currentPlayer] > cricketGame!.points.where((p) => p != cricketGame!.points[currentPlayer]).reduce((a, b) => a > b ? a : b);
                    } else {
                      win = cricketGame!.points[currentPlayer] < cricketGame!.points.where((p) => p != cricketGame!.points[currentPlayer]).reduce((a, b) => a < b ? a : b);
                    }
                  }
                  if (win) {
                    _showWinnerDialog(widget.players[currentPlayer]);
                  } else {
                    setState(() {
                      currentPlayer = (currentPlayer + 1) % widget.players.length;
                    });
                  }
                } : null,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('Current turn: ' + cricketGame!.currentTurn.map((d) {
            if (d['mult'] == 2) return 'd'+d['target'].toString();
            if (d['mult'] == 3) return 't'+d['target'].toString();
            return d['target'].toString();
          }).join(', ')),
        ],
      );
    }
    if (widget.gameMode == 'Shangai') {
      // Shangai input: S/D/T<target>, Shangai, Miss
      String target = shangaiGame!.currentRound.toString();
      List<String> buttons = ['S$target', 'D$target', 'T$target', 'Shangai', 'Miss'];
      return Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: buttons.map((b) => ElevatedButton(
              onPressed: shangaiGame!.currentTurn.length >= 3 ? null : () {
                setState(() {
                  shangaiGame!.currentTurn.add({'type': b});
                });
              },
              child: Text(b, style: GoogleFonts.montserrat(fontSize: 20)),
            )).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.undo),
                label: Text('Cancel Last'),
                onPressed: shangaiGame!.currentTurn.isNotEmpty ? () {
                  setState(() {
                    shangaiGame!.currentTurn.removeLast();
                  });
                } : null,
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text('End Turn'),
                onPressed: shangaiGame!.currentTurn.isNotEmpty ? () {
                  // Apply turn
                  int score = 0;
                  bool shangai = false;
                  bool s = false, d = false, t = false;
                  for (var dart in shangaiGame!.currentTurn) {
                    String type = dart['type'];
                    if (type == 'Miss') continue;
                    if (type == 'Shangai') {
                      shangai = true;
                      s = d = t = true;
                      score = 3 * shangaiGame!.currentRound + 2 * shangaiGame!.currentRound + shangaiGame!.currentRound;
                      break;
                    }
                    if (type.startsWith('S')) { score += shangaiGame!.currentRound; s = true; }
                    if (type.startsWith('D')) { score += 2 * shangaiGame!.currentRound; d = true; }
                    if (type.startsWith('T')) { score += 3 * shangaiGame!.currentRound; t = true; }
                  }
                  shangaiGame!.turns[currentPlayer].add({'turn': List.from(shangaiGame!.currentTurn), 'score': score, 'shangai': shangai || (s && d && t)});
                  shangaiGame!.currentTurn.clear();
                  // Check win
                  if (shangai || (s && d && t)) {
                    _showWinnerDialog(widget.players[currentPlayer]);
                  } else {
                    // Next round or next player
                    if (currentPlayer == widget.players.length - 1) {
                      if (shangaiGame!.currentRound == 7) {
                        // End game, highest score wins
                        int maxScore = 0, winner = 0;
                        for (int i = 0; i < widget.players.length; i++) {
                          int total = shangaiGame!.turns[i].fold(0, (a, b) => a + ((b['score'] ?? 0) as int));
                          if (total > maxScore) { maxScore = total; winner = i; }
                        }
                        _showWinnerDialog(widget.players[winner]);
                      } else {
                        setState(() {
                          shangaiGame!.shangaiRound++;
                          currentPlayer = 0;
                        });
                      }
                    } else {
                      setState(() {
                        currentPlayer++;
                      });
                    }
                  }
                } : null,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('Current turn: ${shangaiGame!.currentTurn.map((d) => d['type']).join(', ')}'),
        ],
      );
    }
    if (widget.gameMode == 'AroundClock') {
      // Around the clock input: <target> or Miss, continue to next target if darts remain
      int playerTarget = aroundClockGame!.targets[currentPlayer];
      String targetLabel = aroundClockGame!.targetLabel(playerTarget);
      List<String> buttons = [targetLabel, 'Miss'];
      return Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: buttons.map((b) => ElevatedButton(
              onPressed: () {
                setState(() {
                  aroundClockGame!.currentTurn.add({'target': b});
                  aroundClockGame!.dartsLeft--;
                  if (b == targetLabel) {
                    aroundClockGame!.hits[currentPlayer].add(playerTarget);
                    aroundClockGame!.targets[currentPlayer]++;
                    if (aroundClockGame!.targets[currentPlayer] > 22) aroundClockGame!.targets[currentPlayer] = 22; // DBull is last
                  }
                  // End turn after 3 darts or if player finished
                  if (aroundClockGame!.dartsLeft == 0 || aroundClockGame!.targets[currentPlayer] > 22) {
                    // Check win condition
                    if (aroundClockGame!.targets[currentPlayer] > 22) {
                      _showWinnerDialog(widget.players[currentPlayer]);
                      return;
                    }
                    // Next player turn
                    aroundClockGame!.currentTurn.clear();
                    aroundClockGame!.dartsLeft = 3;
                    currentPlayer = (currentPlayer + 1) % widget.players.length;
                  }
                });
              },
              child: Text(b),
            )).toList(),
          ),
          SizedBox(height: 8),
          Text('Current turn: ${aroundClockGame!.currentTurn.map((d) => d['target']).join(', ')}'),
        ],
      );
    }
    return SizedBox();
  }

  Widget buildNumpadAndButtons() {
    final buttonTextStyle = GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold);
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    final buttonPadding = EdgeInsets.symmetric(vertical: 18); // Increased padding
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        // Numpad section (2/3)
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // First 3 rows: 1-9
              for (var row = 0; row < 3; row++)
                Row(
                  children: [
                    for (var col = 1; col <= 3; col++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            onPressed: () => onNumpadTap('${row * 3 + col}'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                              foregroundColor: isDark ? Colors.white : Colors.black,
                              textStyle: buttonTextStyle,
                              shape: buttonShape,
                              padding: buttonPadding,
                              minimumSize: Size(0, 56),
                            ),
                            child: Text('${row * 3 + col}'),
                          ),
                        ),
                      ),
                  ],
                ),
              // Last row: Bust (spans 2 columns), 0
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton(
                        onPressed: () => onNumpadTap('Bust'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          textStyle: buttonTextStyle,
                          shape: buttonShape,
                          padding: buttonPadding,
                          minimumSize: Size(0, 56),
                        ),
                        child: const Text('Bust'),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton(
                        onPressed: () => onNumpadTap('0'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          foregroundColor: isDark ? Colors.white : Colors.black,
                          textStyle: buttonTextStyle,
                          shape: buttonShape,
                          padding: buttonPadding,
                          minimumSize: Size(0, 56),
                        ),
                        child: const Text('0'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Button section (1/3)
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => onNumpadTap('OK'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        textStyle: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold),
                        shape: buttonShape,
                        padding: EdgeInsets.symmetric(vertical: 22), // More vertical padding
                        minimumSize: Size(0, 64), // Ensure enough height
                      ),
                      child: const Text('Valider', overflow: TextOverflow.ellipsis, maxLines: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            _undoLastScore();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            foregroundColor: Colors.white,
                            shape: buttonShape,
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 48),
                          ),
                          child: const Icon(Icons.undo, size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _scoreController.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[700],
                            foregroundColor: Colors.white,
                            shape: buttonShape,
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 48),
                          ),
                          child: const Icon(Icons.clear, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildScorecards() {
    // Only show scores for X01
    if (widget.gameMode != 'X01') return SizedBox.shrink();
    return SizedBox(
      height: 200,
      child: ListView.separated(
        itemCount: widget.players.length,
        separatorBuilder: (_, __) => SizedBox(height: 16),
        itemBuilder: (context, i) {
          final avg = _average(i).toStringAsFixed(1);
          final isCurrent = x01Game != null ? i == x01Game!.currentPlayer : i == currentPlayer;
          final score = x01Game != null ? x01Game!.scores[i] : scores[i];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: isCurrent
                  ? LinearGradient(colors: [Colors.green.shade400, Colors.green.shade700])
                  : LinearGradient(colors: [Colors.white.withValues(alpha: 0.7), Colors.white.withValues(alpha: 0.7)]),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                if (isCurrent)
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: isCurrent ? Colors.white : Colors.green.shade100,
                child: Text(
                  widget.players[i][0].toUpperCase(),
                  style: GoogleFonts.montserrat(
                    color: isCurrent ? Colors.green.shade700 : Colors.green.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
              title: Text(
                widget.players[i],
                style: GoogleFonts.montserrat(
                  color: isCurrent ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              subtitle: Text(
                'Avg: $avg',
                style: GoogleFonts.montserrat(
                  color: isCurrent ? Colors.white70 : Colors.black.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              trailing: Text(
                '$score pts',
                style: GoogleFonts.montserrat(
                  color: isCurrent ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Show the score being typed above the numpad/buttons
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final numpadHeight = size.height / 3;

    // Full screen layout for non-X01 games
    if (widget.gameMode != 'X01') {
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current player indicator
                Card(
                  color: Colors.blueAccent,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Text(
                          "It's ",
                          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 22),
                        ),
                        Text(
                          widget.players[currentPlayer],
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                          ),
                        ),
                        Text(
                          "'s turn",
                          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.gameMode == 'Cricket' || widget.gameMode == 'CutThroat') buildCricketTable(),
                if (widget.gameMode == 'Shangai') buildShangaiTable(),
                if (widget.gameMode == 'AroundClock') buildAroundClockTable(),
                SizedBox(height: 16),
                // Modern button arrangement
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: buildModernInputUI(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // X01 specific layout
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
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: buildScorecards(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 0),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
                ),
                child: Text(
                  _scoreController.text.isEmpty ? 'Entrez un score' : _scoreController.text,
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: numpadHeight,
            child: buildInputUI(),
          ),
        ],
      ),
    );
  }

  // Add this new method for modern button arrangement
  Widget buildModernInputUI() {
    if (widget.gameMode == 'Cricket' || widget.gameMode == 'CutThroat') {
      List<String> buttons = [...cricketGame!.targets, 'Miss'];
      return Column(
        children: [
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: buttons.map((b) => GestureDetector(
              onLongPress: cricketGame!.currentTurn.length >= 3 ? null : () async {
                if (b == 'Bull') {
                  setState(() {
                    cricketGame!.currentTurn.add({'target': b, 'mult': 2});
                  });
                } else if (b != 'Miss') {
                  await _showDoubleTripleDialog(b);
                }
              },
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: b == 'Miss' ? Colors.redAccent : Colors.greenAccent,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  textStyle: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: cricketGame!.currentTurn.length >= 3 ? null : () {
                  setState(() {
                    cricketGame!.currentTurn.add({'target': b, 'mult': 1});
                  });
                },
                child: Text(b),
              ),
            )).toList(),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.undo),
                label: Text('Cancel Last'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: cricketGame!.currentTurn.isNotEmpty ? () {
                  setState(() {
                    cricketGame!.currentTurn.removeLast();
                  });
                } : null,
              ),
              SizedBox(width: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text('Validate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: cricketGame!.currentTurn.isNotEmpty ? () {
                  // Apply turn
                  for (var dart in cricketGame!.currentTurn) {
                    String t = dart['target'];
                    if (t == 'Miss') continue;
                    int mult = dart['mult'] ?? 1;
                    if (cricketGame!.hits[t] != null) {
                      int before = cricketGame!.hits[t]![currentPlayer];
                      int after = before + mult;
                      int extra = after > 3 ? after - 3 : 0;
                      cricketGame!.hits[t]![currentPlayer] = after > 3 ? 3 : after;
                      if (extra > 0) {
                        int others = 0;
                        for (int i = 0; i < widget.players.length; i++) {
                          if (i != currentPlayer && (cricketGame!.hits[t]?[i] ?? 0) < 3) others++;
                        }
                        if (others > 0) {
                          int points = (t == 'Bull' ? 25 : int.tryParse(t) ?? 0) * extra;
                          if (widget.gameMode == 'Cricket') {
                            cricketGame!.points[currentPlayer] += points;
                          } else {
                            // CutThroat: add points to opponents who haven't closed
                            for (int i = 0; i < widget.players.length; i++) {
                              if (i != currentPlayer && (cricketGame!.hits[t]?[i] ?? 0) < 3) cricketGame!.points[i] += points;
                            }
                          }
                        }
                      }
                    }
                  }
                  cricketGame!.turnHistory[currentPlayer].add({'turn': List.from(cricketGame!.currentTurn)});
                  cricketGame!.currentTurn.clear();
                  // Check win
                  bool allClosed = cricketGame!.targets.every((t) => (cricketGame!.hits[t]?[currentPlayer] ?? 0) == 3);
                  bool win = false;
                  if (allClosed) {
                    if (widget.gameMode == 'Cricket') {
                      win = cricketGame!.points[currentPlayer] > cricketGame!.points.where((p) => p != cricketGame!.points[currentPlayer]).reduce((a, b) => a > b ? a : b);
                    } else {
                      win = cricketGame!.points[currentPlayer] < cricketGame!.points.where((p) => p != cricketGame!.points[currentPlayer]).reduce((a, b) => a < b ? a : b);
                    }
                  }
                  if (win) {
                    _showWinnerDialog(widget.players[currentPlayer]);
                  } else {
                    setState(() {
                      currentPlayer = (currentPlayer + 1) % widget.players.length;
                    });
                  }
                } : null,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('Current turn: ' + cricketGame!.currentTurn.map((d) {
            if (d['mult'] == 2) return 'd'+d['target'].toString();
            if (d['mult'] == 3) return 't'+d['target'].toString();
            return d['target'].toString();
          }).join(', ')),
        ],
      );
    }
    if (widget.gameMode == 'Shangai') {
      String target = shangaiGame!.currentRound.toString();
      List<String> buttons = ['S$target', 'D$target', 'T$target', 'Shangai', 'Miss'];
      return Column(
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: buttons.map((b) => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: b == 'Miss' ? Colors.redAccent : Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                textStyle: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: shangaiGame!.currentTurn.length >= 3 ? null : () {
                setState(() {
                  shangaiGame!.currentTurn.add({'type': b});
                });
              },
              child: Text(b),
            )).toList(),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.undo),
                label: Text('Cancel Last'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: shangaiGame!.currentTurn.isNotEmpty ? () {
                  setState(() {
                    shangaiGame!.currentTurn.removeLast();
                  });
                } : null,
              ),
              SizedBox(width: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text('Validate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: shangaiGame!.currentTurn.isNotEmpty ? () {
                  // Apply turn
                  int score = 0;
                  bool shangai = false;
                  bool s = false, d = false, t = false;
                  for (var dart in shangaiGame!.currentTurn) {
                    String type = dart['type'];
                    if (type == 'Miss') continue;
                    if (type == 'Shangai') {
                      shangai = true;
                      s = d = t = true;
                      score = 3 * shangaiGame!.currentRound + 2 * shangaiGame!.currentRound + shangaiGame!.currentRound;
                      break;
                    }
                    if (type.startsWith('S')) { score += shangaiGame!.currentRound; s = true; }
                    if (type.startsWith('D')) { score += 2 * shangaiGame!.currentRound; d = true; }
                    if (type.startsWith('T')) { score += 3 * shangaiGame!.currentRound; t = true; }
                  }
                  shangaiGame!.turns[currentPlayer].add({'turn': List.from(shangaiGame!.currentTurn), 'score': score, 'shangai': shangai || (s && d && t)});
                  shangaiGame!.currentTurn.clear();
                  // Check win
                  if (shangai || (s && d && t)) {
                    _showWinnerDialog(widget.players[currentPlayer]);
                  } else {
                    // Next round or next player
                    if (currentPlayer == widget.players.length - 1) {
                      if (shangaiGame!.currentRound == 7) {
                        // End game, highest score wins
                        int maxScore = 0, winner = 0;
                        for (int i = 0; i < widget.players.length; i++) {
                          int total = shangaiGame!.turns[i].fold(0, (a, b) => a + ((b['score'] ?? 0) as int));
                          if (total > maxScore) { maxScore = total; winner = i; }
                        }
                        _showWinnerDialog(widget.players[winner]);
                      } else {
                        setState(() {
                          shangaiGame!.shangaiRound++;
                          currentPlayer = 0;
                        });
                      }
                    } else {
                      setState(() {
                        currentPlayer++;
                      });
                    }
                  }
                } : null,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('Current turn: ' + shangaiGame!.currentTurn.map((d) => d['type']).join(', ')),
        ],
      );
    }
    if (widget.gameMode == 'AroundClock') {
      // Around the clock input: <target> or Miss, continue to next target if darts remain
      int playerTarget = aroundClockGame!.targets[currentPlayer];
      String targetLabel = aroundClockGame!.targetLabel(playerTarget);
      List<String> buttons = [targetLabel, 'Miss'];
      return Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: buttons.map((b) => ElevatedButton(
              onPressed: () {
                setState(() {
                  aroundClockGame!.currentTurn.add({'target': b});
                  aroundClockGame!.dartsLeft--;
                  if (b == targetLabel) {
                    aroundClockGame!.hits[currentPlayer].add(playerTarget);
                    aroundClockGame!.targets[currentPlayer]++;
                    if (aroundClockGame!.targets[currentPlayer] > 22) aroundClockGame!.targets[currentPlayer] = 22; // DBull is last
                  }
                  // End turn after 3 darts or if player finished
                  if (aroundClockGame!.dartsLeft == 0 || aroundClockGame!.targets[currentPlayer] > 22) {
                    // Check win condition
                    if (aroundClockGame!.targets[currentPlayer] > 22) {
                      _showWinnerDialog(widget.players[currentPlayer]);
                      return;
                    }
                    // Next player turn
                    aroundClockGame!.currentTurn.clear();
                    aroundClockGame!.dartsLeft = 3;
                    currentPlayer = (currentPlayer + 1) % widget.players.length;
                  }
                });
              },
              child: Text(b),
            )).toList(),
          ),
          SizedBox(height: 8),
          Text('Current turn: ${aroundClockGame!.currentTurn.map((d) => d['target']).join(', ')}'),
        ],
      );
    }
    return SizedBox();
  }

  // Add missing onNumpadTap method for numpad functionality
  void onNumpadTap(String value) {
    setState(() {
      if (value == 'C') {
        _scoreController.clear();
      } else if (value == 'Bust') {
        _burst();
      } else if (value == 'OK') {
        _submitScore();
      } else {
        _scoreController.text += value;
      }
    });
  }
}
