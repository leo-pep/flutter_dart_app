// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Tableau de score de fléchettes';

  @override
  String get gameInProgress => 'Partie en cours';

  @override
  String get enterScore => 'Entrez un score';

  @override
  String get maxScoreWarning => '⚠️ Le score maximum est 180 !';

  @override
  String winnerDialogTitle(Object winner) {
    return '🎉 $winner a gagné !';
  }

  @override
  String averageScore(Object avg) {
    return 'Moy: $avg';
  }

  @override
  String scoreWithPts(Object score) {
    return '$score pts';
  }

  @override
  String resetStatsFor(Object player) {
    return 'Réinitialiser les stats pour $player';
  }

  @override
  String get daysHint => 'Jours';

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String avg(Object value) {
    return 'Moy: $value';
  }

  @override
  String points(Object value) {
    return '$value pts';
  }

  @override
  String get validate => 'Valider';

  @override
  String get undo => 'Annuler';

  @override
  String get clear => 'Effacer';

  @override
  String get bust => 'Burst';

  @override
  String get playerStats => 'Statistiques du joueur';

  @override
  String get selectPlayer => 'Sélectionnez un joueur';

  @override
  String get noGamesFound => 'Aucune partie trouvée pour ce joueur.';

  @override
  String gamesPlayed(Object value) {
    return 'Parties jouées : $value';
  }

  @override
  String wins(Object value) {
    return 'Victoires : $value';
  }

  @override
  String losses(Object value) {
    return 'Défaites : $value';
  }

  @override
  String globalAverage(Object value) {
    return 'Moyenne globale : $value';
  }

  @override
  String wlRatio(Object value) {
    return 'Ratio V/D : $value%';
  }

  @override
  String bestAverage(Object value) {
    return 'Meilleure moyenne : $value';
  }

  @override
  String lastPlayed(Object value) {
    return 'Dernière partie : $value';
  }

  @override
  String gameMode(Object mode) {
    return 'Mode de jeu : $mode';
  }

  @override
  String average(Object value) {
    return 'Moyenne : $value';
  }

  @override
  String get resetStats => 'Réinitialiser les stats';

  @override
  String get resetAllStats => 'Tout réinitialiser';

  @override
  String get resetMostPlayedGame => 'Réinitialiser le mode le plus joué';

  @override
  String get resetLastXDays => 'Réinitialiser les X derniers jours';

  @override
  String get days => 'Jours';

  @override
  String get addPlayer => 'Ajouter un joueur';

  @override
  String get remove => 'Supprimer';

  @override
  String get playerName => 'Nom du joueur';

  @override
  String get add => 'Ajouter';

  @override
  String get selectPlayers => 'Sélectionnez les joueurs';

  @override
  String get noPlayersYet => 'Aucun joueur pour l\'instant. Ajoutez-en un ! 🥒';

  @override
  String get noPlayersSelected => 'Aucun joueur sélectionné.';

  @override
  String get gameModeLabel => 'Mode de jeu';
}
