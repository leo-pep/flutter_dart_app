// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dart Scoreboard';

  @override
  String get gameInProgress => 'Game in progress';

  @override
  String get enterScore => 'Enter a score';

  @override
  String get maxScoreWarning => '⚠️ Maximum score is 180!';

  @override
  String winnerDialogTitle(Object winner) {
    return '🎉 $winner wins!';
  }

  @override
  String averageScore(Object avg) {
    return 'Avg: $avg';
  }

  @override
  String scoreWithPts(Object score) {
    return '$score pts';
  }

  @override
  String resetStatsFor(Object player) {
    return 'Reset stats for $player';
  }

  @override
  String get daysHint => 'Days';

  @override
  String get backToHome => 'Back to Home';

  @override
  String avg(Object value) {
    return 'Avg: $value';
  }

  @override
  String points(Object value) {
    return '$value pts';
  }

  @override
  String get validate => 'Validate';

  @override
  String get undo => 'Undo';

  @override
  String get clear => 'Clear';

  @override
  String get bust => 'Bust';

  @override
  String get playerStats => 'Player Stats';

  @override
  String get selectPlayer => 'Select a player';

  @override
  String get noGamesFound => 'No games found for this player.';

  @override
  String gamesPlayed(Object value) {
    return 'Games played: $value';
  }

  @override
  String wins(Object value) {
    return 'Wins: $value';
  }

  @override
  String losses(Object value) {
    return 'Losses: $value';
  }

  @override
  String globalAverage(Object value) {
    return 'Global average: $value';
  }

  @override
  String wlRatio(Object value) {
    return 'W/L ratio: $value%';
  }

  @override
  String bestAverage(Object value) {
    return 'Best average: $value';
  }

  @override
  String lastPlayed(Object value) {
    return 'Last played: $value';
  }

  @override
  String gameMode(Object mode) {
    return 'Game Mode: $mode';
  }

  @override
  String average(Object value) {
    return 'Average: $value';
  }

  @override
  String get resetStats => 'Reset Stats';

  @override
  String get resetAllStats => 'Reset All Stats';

  @override
  String get resetMostPlayedGame => 'Reset Most Played Game';

  @override
  String get resetLastXDays => 'Reset Last X Days';

  @override
  String get days => 'Days';

  @override
  String get addPlayer => 'Add Player';

  @override
  String get remove => 'Remove';

  @override
  String get playerName => 'Player name';

  @override
  String get add => 'Add';

  @override
  String get selectPlayers => 'Select players';

  @override
  String get noPlayersYet => 'No players yet. Add one!';

  @override
  String get noPlayersSelected => 'No players selected.';

  @override
  String get gameModeLabel => 'Game Mode';
}
