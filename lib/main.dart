import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(DartScoreboardApp());
}

class DartScoreboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart Scoreboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.light),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.green.shade900,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.montserrat(
            color: Colors.green.shade900,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          color: Colors.white.withOpacity(0.7),
          shadowColor: Colors.black12,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
        scaffoldBackgroundColor: const Color(0xFF181A20),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          color: const Color(0xFF23272F).withOpacity(0.85),
          shadowColor: Colors.black54,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          fillColor: const Color(0xFF23272F),
          filled: true,
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white38),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            fillColor: const Color(0xFF23272F),
            filled: true,
            labelStyle: TextStyle(color: Colors.white70),
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [BoxShadow(blurRadius: 24, color: Colors.black12)],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Player', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(hintText: 'Player name'),
                style: GoogleFonts.montserrat(fontSize: 18),
                onSubmitted: (_) {
                  _addPlayer(_controller.text.trim());
                  _controller.clear();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _addPlayer(_controller.text.trim());
                    _controller.clear();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Dart Scoreboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedStartingScore,
              decoration: InputDecoration(
                labelText: 'Game Mode',
                prefixIcon: Icon(Icons.sports_score),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF23272F) : Colors.white,
              ),
              style: GoogleFonts.montserrat(fontSize: 18, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF23272F) : Colors.white,
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedStartingScore = value);
                }
              },
              items: possibleModes
                  .map((mode) => DropdownMenuItem(
                value: mode,
                child: Text('$mode', style: GoogleFonts.montserrat(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
              ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: players.isEmpty
                  ? Center(
                child: Text(
                  'No players yet. Add one!',
                  style: GoogleFonts.montserrat(color: colorScheme.outline, fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final p = players[index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF23272F).withOpacity(0.85) : Colors.white.withOpacity(0.7),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(p[0].toUpperCase(), style: GoogleFonts.montserrat(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(p, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 18, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: colorScheme.error),
                          onPressed: () => _removePlayer(p),
                          tooltip: 'Remove',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPlayerDialog,
        icon: Icon(Icons.person_add),
        label: Text('Add Player', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 8),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _startGame,
            icon: Icon(Icons.play_arrow),
            label: Text('Start Game ($selectedStartingScore)', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              textStyle: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF23272F).withOpacity(0.85) : Colors.white.withOpacity(0.7);
    final cardText = isDark ? Colors.white : Colors.black;
    final size = MediaQuery.of(context).size;
    final numpadHeight = size.height / 3;
    final scorecardHeight = size.height * 2 / 3 - 32; // minus padding

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
      return SizedBox(
        height: scorecardHeight,
        child: ListView.separated(
          itemCount: widget.players.length,
          separatorBuilder: (_, __) => SizedBox(height: 16),
          itemBuilder: (context, i) {
            final avg = _average(i).toStringAsFixed(1);
            final isCurrent = i == currentPlayer;
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: isCurrent
                    ? LinearGradient(colors: [Colors.green.shade400, Colors.green.shade700])
                    : LinearGradient(colors: [cardBg, cardBg]),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  if (isCurrent)
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
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
                    color: isCurrent ? Colors.white : cardText,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                subtitle: Text(
                  'Avg: $avg',
                  style: GoogleFonts.montserrat(
                    color: isCurrent ? Colors.white70 : cardText.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                trailing: Text(
                  '${scores[i]} pts',
                  style: GoogleFonts.montserrat(
                    color: isCurrent ? Colors.white : cardText,
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
          Container(
            height: numpadHeight,
            child: buildNumpadAndButtons(),
          ),
        ],
      ),
    );
  }
}
