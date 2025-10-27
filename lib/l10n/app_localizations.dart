import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Dart Scoreboard'**
  String get appTitle;

  /// No description provided for @gameInProgress.
  ///
  /// In en, this message translates to:
  /// **'Game in progress'**
  String get gameInProgress;

  /// No description provided for @enterScore.
  ///
  /// In en, this message translates to:
  /// **'Enter a score'**
  String get enterScore;

  /// No description provided for @maxScoreWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Maximum score is 180!'**
  String get maxScoreWarning;

  /// No description provided for @winnerDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'🎉 {winner} wins!'**
  String winnerDialogTitle(Object winner);

  /// No description provided for @averageScore.
  ///
  /// In en, this message translates to:
  /// **'Avg: {avg}'**
  String averageScore(Object avg);

  /// No description provided for @scoreWithPts.
  ///
  /// In en, this message translates to:
  /// **'{score} pts'**
  String scoreWithPts(Object score);

  /// No description provided for @resetStatsFor.
  ///
  /// In en, this message translates to:
  /// **'Reset stats for {player}'**
  String resetStatsFor(Object player);

  /// No description provided for @daysHint.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get daysHint;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @avg.
  ///
  /// In en, this message translates to:
  /// **'Avg: {value}'**
  String avg(Object value);

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'{value} pts'**
  String points(Object value);

  /// No description provided for @validate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validate;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @bust.
  ///
  /// In en, this message translates to:
  /// **'Bust'**
  String get bust;

  /// No description provided for @playerStats.
  ///
  /// In en, this message translates to:
  /// **'Player Stats'**
  String get playerStats;

  /// No description provided for @selectPlayer.
  ///
  /// In en, this message translates to:
  /// **'Select a player'**
  String get selectPlayer;

  /// No description provided for @noGamesFound.
  ///
  /// In en, this message translates to:
  /// **'No games found for this player.'**
  String get noGamesFound;

  /// No description provided for @gamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games played: {value}'**
  String gamesPlayed(Object value);

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins: {value}'**
  String wins(Object value);

  /// No description provided for @losses.
  ///
  /// In en, this message translates to:
  /// **'Losses: {value}'**
  String losses(Object value);

  /// No description provided for @globalAverage.
  ///
  /// In en, this message translates to:
  /// **'Global average: {value}'**
  String globalAverage(Object value);

  /// No description provided for @wlRatio.
  ///
  /// In en, this message translates to:
  /// **'W/L ratio: {value}%'**
  String wlRatio(Object value);

  /// No description provided for @bestAverage.
  ///
  /// In en, this message translates to:
  /// **'Best average: {value}'**
  String bestAverage(Object value);

  /// No description provided for @lastPlayed.
  ///
  /// In en, this message translates to:
  /// **'Last played: {value}'**
  String lastPlayed(Object value);

  /// No description provided for @gameMode.
  ///
  /// In en, this message translates to:
  /// **'Game Mode: {mode}'**
  String gameMode(Object mode);

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average: {value}'**
  String average(Object value);

  /// No description provided for @resetStats.
  ///
  /// In en, this message translates to:
  /// **'Reset Stats'**
  String get resetStats;

  /// No description provided for @resetAllStats.
  ///
  /// In en, this message translates to:
  /// **'Reset All Stats'**
  String get resetAllStats;

  /// No description provided for @resetMostPlayedGame.
  ///
  /// In en, this message translates to:
  /// **'Reset Most Played Game'**
  String get resetMostPlayedGame;

  /// No description provided for @resetLastXDays.
  ///
  /// In en, this message translates to:
  /// **'Reset Last X Days'**
  String get resetLastXDays;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @addPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add Player'**
  String get addPlayer;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @playerName.
  ///
  /// In en, this message translates to:
  /// **'Player name'**
  String get playerName;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @selectPlayers.
  ///
  /// In en, this message translates to:
  /// **'Select players'**
  String get selectPlayers;

  /// No description provided for @noPlayersYet.
  ///
  /// In en, this message translates to:
  /// **'No players yet. Add one!'**
  String get noPlayersYet;

  /// No description provided for @noPlayersSelected.
  ///
  /// In en, this message translates to:
  /// **'No players selected.'**
  String get noPlayersSelected;

  /// No description provided for @gameModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Game Mode'**
  String get gameModeLabel;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
