import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<String> allPlayers = [];
  String? selectedPlayer;
  Map<String, dynamic>? stats;
  List<Map<String, dynamic>> playerGames = [];
  int? mostPlayedMode;
  double? bestAvg;
  String? lastPlayed;
  Map<int, Map<String, dynamic>> modeStats = {};
  List<int> playedModes = [];

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

  Future<void> _loadStats(String player) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('game_stats');
    if (data == null) {
      setState(() {
        stats = null;
        playerGames = [];
        mostPlayedMode = null;
        bestAvg = null;
        lastPlayed = null;
        modeStats = {};
        playedModes = [];
      });
      return;
    }
    final List games = json.decode(data);
    int wins = 0, losses = 0, totalScore = 0, totalThrows = 0, gamesPlayed = 0;
    Map<int, int> modeCount = {};
    double? bestAverage;
    String? lastDate;
    List<Map<String, dynamic>> filteredGames = [];
    Map<int, Map<String, dynamic>> tempModeStats = {};
    Set<int> modesPlayed = {};
    for (final g in games) {
      if ((g['players'] as List).contains(player)) {
        gamesPlayed++;
        if (g['winner'] == player) {
          wins++;
        } else {
          losses++;
        }
        final idx = (g['players'] as List).indexOf(player);
        final throws = (g['history'] as List)[idx] as List;
        totalThrows += throws.length;
        totalScore += throws.fold(0, (a, b) => a + (b as int));
        final avg = throws.isNotEmpty ? throws.fold(0, (a, b) => a + (b as int)) / throws.length : 0;
        if (bestAverage == null || avg > bestAverage) bestAverage = avg as double?;
        // Use only 'gameMode' for determining mode. If missing, set to 'unknown'.
        final mode = g.containsKey('gameMode') ? g['gameMode'] : 'unknown';
        modeCount[mode] = (modeCount[mode] ?? 0) + 1;
        lastDate = g['timestamp'];
        filteredGames.add(g);
        modesPlayed.add(mode);
        // Per-mode stats
        if (!tempModeStats.containsKey(mode)) {
          tempModeStats[mode] = {
            'games': 0,
            'wins': 0,
            'losses': 0,
            'totalScore': 0,
            'totalThrows': 0,
            'bestAvg': null,
            'lastPlayed': null,
          };
        }
        tempModeStats[mode]!['games']++;
        if (g['winner'] == player) {
          tempModeStats[mode]!['wins']++;
        } else {
          tempModeStats[mode]!['losses']++;
        }
        tempModeStats[mode]!['totalScore'] += throws.fold(0, (a, b) => a + (b as int));
        tempModeStats[mode]!['totalThrows'] += throws.length;
        if (throws.isNotEmpty) {
          final modeAvg = throws.fold(0, (a, b) => a + (b as int)) / throws.length;
          if (tempModeStats[mode]!['bestAvg'] == null || modeAvg > tempModeStats[mode]!['bestAvg']) {
            tempModeStats[mode]!['bestAvg'] = modeAvg;
          }
        }
        tempModeStats[mode]!['lastPlayed'] = g['timestamp'];
      }
    }
    double avg = totalThrows > 0 ? totalScore / totalThrows : 0;
    double wl = gamesPlayed > 0 ? wins / gamesPlayed : 0;
    int? mostPlayed = modeCount.isNotEmpty ? (modeCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key : null;
    setState(() {
      stats = {
        'games': gamesPlayed,
        'wins': wins,
        'losses': losses,
        'avg': avg,
        'wl': wl,
      };
      playerGames = filteredGames;
      mostPlayedMode = mostPlayed;
      bestAvg = bestAverage;
      lastPlayed = lastDate;
      modeStats = tempModeStats;
      playedModes = modesPlayed.toList()..sort();
    });
  }

  Future<void> _resetStats({required String player, int? days, int? mode}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('game_stats');
    if (data == null) return;
    List games = json.decode(data);
    DateTime now = DateTime.now();
    List newGames = [];
    for (final g in games) {
      final players = List<String>.from(g['players']);
      if (!players.contains(player)) {
        newGames.add(g);
        continue;
      }
      bool shouldRemove = false;
      if (days != null) {
        final dt = DateTime.tryParse(g['timestamp'] ?? '') ?? now;
        if (now.difference(dt).inDays < days) shouldRemove = true;
      }
      if (mode != null) {
        final gameMode = g.containsKey('gameMode') ? g['gameMode'] : (g.containsKey('startingScore') ? g['startingScore'] : null);
        if (gameMode != null && gameMode == mode) shouldRemove = true;
      }
      if (days == null && mode == null) shouldRemove = true; // global reset
      if (shouldRemove) {
        // Remove only the player from the game
        final idx = players.indexOf(player);
        players.removeAt(idx);
        (g['scores'] as List).removeAt(idx);
        (g['history'] as List).removeAt(idx);
        // If no players left, skip adding this game
        if (players.isNotEmpty) {
          g['players'] = players;
          newGames.add(g);
        }
        // If players empty, game is deleted
      } else {
        newGames.add(g);
      }
    }
    await prefs.setString('game_stats', json.encode(newGames));
    if (selectedPlayer != null) _loadStats(selectedPlayer!);
  }

  void _showResetDialog() {
    if (selectedPlayer == null) return;
    showDialog(
      context: context,
      builder: (ctx) {
        final TextEditingController daysController = TextEditingController();
        return AlertDialog(
          title: Text('Reset Stats for $selectedPlayer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _resetStats(player: selectedPlayer!);
                },
                child: Text('Reset All Stats'),
              ),
              ElevatedButton(
                onPressed: mostPlayedMode == null ? null : () {
                  Navigator.pop(ctx);
                  _resetStats(player: selectedPlayer!, mode: mostPlayedMode);
                },
                child: Text('Reset Most Played Game'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: daysController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: 'Days'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final days = int.tryParse(daysController.text);
                      if (days != null) {
                        Navigator.pop(ctx);
                        _resetStats(player: selectedPlayer!, days: days);
                      }
                    },
                    child: Text('Reset Last X Days'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String? _formatDate(String? isoDate) {
    if (isoDate == null) return null;
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount;
    double width = MediaQuery.of(context).size.width;
    if (width > 900) {
      crossAxisCount = 3;
    } else if (width > 600) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }
    return Scaffold(
      appBar: AppBar(title: Text('Player Stats')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<String>(
                value: selectedPlayer,
                hint: Text('Select a player'),
                items: allPlayers.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (p) {
                  setState(() { selectedPlayer = p; });
                  if (p != null) _loadStats(p);
                },
              ),
              const SizedBox(height: 24),
              if (selectedPlayer == null)
                Text('Select a player to view stats.', style: GoogleFonts.montserrat(fontSize: 18)),
              if (selectedPlayer != null && stats == null)
                Text('No games found for this player.', style: GoogleFonts.montserrat(fontSize: 18)),
              if (stats != null)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Global Stats', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(selectedPlayer ?? '', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text('Games played: ${stats!['games']}', style: GoogleFonts.montserrat(fontSize: 18)),
                        Text('Wins: ${stats!['wins']}', style: GoogleFonts.montserrat(fontSize: 18)),
                        Text('Losses: ${stats!['losses']}', style: GoogleFonts.montserrat(fontSize: 18)),
                        Text('Global average: ${stats!['avg'].toStringAsFixed(1)}', style: GoogleFonts.montserrat(fontSize: 18)),
                        Text('W/L ratio: ${(stats!['wl'] * 100).toStringAsFixed(1)}%', style: GoogleFonts.montserrat(fontSize: 18)),
                        const SizedBox(height: 16),
                        Text('Best average: ${bestAvg?.toStringAsFixed(1) ?? 'N/A'}', style: GoogleFonts.montserrat(fontSize: 18)),
                        Text('Last played: ${_formatDate(lastPlayed) ?? 'N/A'}', style: GoogleFonts.montserrat(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              if (playedModes.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: playedModes.length,
                  itemBuilder: (context, idx) {
                    final mode = playedModes[idx];
                    final mStats = modeStats[mode]!;
                    final avg = mStats['totalThrows'] > 0 ? mStats['totalScore'] / mStats['totalThrows'] : 0;
                    final wl = mStats['games'] > 0 ? mStats['wins'] / mStats['games'] : 0;
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Game Mode: $mode', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(selectedPlayer ?? '', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Text('Games played: ${mStats['games']}', style: GoogleFonts.montserrat(fontSize: 18)),
                            Text('Wins: ${mStats['wins']}', style: GoogleFonts.montserrat(fontSize: 18)),
                            Text('Losses: ${mStats['losses']}', style: GoogleFonts.montserrat(fontSize: 18)),
                            Text('Average: ${avg.toStringAsFixed(1)}', style: GoogleFonts.montserrat(fontSize: 18)),
                            Text('W/L ratio: ${(wl * 100).toStringAsFixed(1)}%', style: GoogleFonts.montserrat(fontSize: 18)),
                            const SizedBox(height: 16),
                            Text('Best average: ${mStats['bestAvg']?.toStringAsFixed(1) ?? 'N/A'}', style: GoogleFonts.montserrat(fontSize: 18)),
                            Text('Last played: ${_formatDate(mStats['lastPlayed']) ?? 'N/A'}', style: GoogleFonts.montserrat(fontSize: 18)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ElevatedButton(
                onPressed: _showResetDialog,
                child: Text('Reset Stats'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
