import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_page.dart';
import 'stats_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> allPlayers = [];
  List<String> selectedPlayers = [];
  final TextEditingController _controller = TextEditingController();
  int selectedStartingScore = 301;
  final List<int> possibleModes = [101, 201, 301, 501, 701, 901];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      allPlayers = prefs.getStringList('all_players') ?? [];
    });
  }

  Future<void> _savePlayers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('all_players', allPlayers);
  }

  void _addPlayer(String name) {
    if (name.isNotEmpty && !allPlayers.contains(name)) {
      setState(() {
        allPlayers.add(name);
        selectedPlayers.add(name);
      });
      _savePlayers();
    } else if (name.isNotEmpty && !selectedPlayers.contains(name)) {
      setState(() {
        selectedPlayers.add(name);
      });
    }
  }

  void _removePlayer(String name) {
    setState(() {
      selectedPlayers.remove(name);
    });
  }

  void _startGame() {
    if (selectedPlayers.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GamePage(players: selectedPlayers, startingScore: selectedStartingScore),
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
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            tooltip: 'Player Stats',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StatsPage()),
              );
            },
          ),
        ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Players:', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allPlayers.length,
                      itemBuilder: (context, index) {
                        final p = allPlayers[index];
                        final selected = selectedPlayers.contains(p);
                        return CheckboxListTile(
                          value: selected,
                          title: Text(p, style: GoogleFonts.montserrat(fontSize: 18)),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                if (!selectedPlayers.contains(p)) selectedPlayers.add(p);
                              } else {
                                selectedPlayers.remove(p);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  if (allPlayers.isEmpty)
                    Center(
                      child: Text(
                        'No players yet. Add one!',
                        style: GoogleFonts.montserrat(color: colorScheme.outline, fontSize: 18),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: selectedPlayers.isEmpty
                  ? Center(
                child: Text(
                  'No players selected.',
                  style: GoogleFonts.montserrat(color: colorScheme.outline, fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: selectedPlayers.length,
                itemBuilder: (context, index) {
                  final p = selectedPlayers[index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF23272F).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.7),
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
