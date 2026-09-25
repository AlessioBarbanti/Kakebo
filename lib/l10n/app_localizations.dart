import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @newItem.
  ///
  /// In it, this message translates to:
  /// **'Nuova voce'**
  String get newItem;

  /// No description provided for @morning.
  ///
  /// In it, this message translates to:
  /// **'Buongiorno'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In it, this message translates to:
  /// **'Buon pomeriggio'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In it, this message translates to:
  /// **'Buonasera'**
  String get evening;

  /// No description provided for @skip.
  ///
  /// In it, this message translates to:
  /// **'Salta'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get back;

  /// No description provided for @backToLedger.
  ///
  /// In it, this message translates to:
  /// **'← Torna al registro'**
  String get backToLedger;

  /// No description provided for @setupTitle.
  ///
  /// In it, this message translates to:
  /// **'Prima di iniziare, scrivi cosa entra e cosa deve uscire.'**
  String get setupTitle;

  /// No description provided for @income.
  ///
  /// In it, this message translates to:
  /// **'Entrate del mese'**
  String get income;

  /// No description provided for @incomeHint.
  ///
  /// In it, this message translates to:
  /// **'Stipendio e altre entrate'**
  String get incomeHint;

  /// No description provided for @savingGoal.
  ///
  /// In it, this message translates to:
  /// **'Obiettivo di risparmio'**
  String get savingGoal;

  /// No description provided for @savingHint.
  ///
  /// In it, this message translates to:
  /// **'Da mettere da parte subito, prima di spendere'**
  String get savingHint;

  /// No description provided for @ruleTitle.
  ///
  /// In it, this message translates to:
  /// **'Punto di partenza: 50 / 30 / 20'**
  String get ruleTitle;

  /// No description provided for @ruleBody.
  ///
  /// In it, this message translates to:
  /// **'Metà ai bisogni, un terzo al resto, un quinto al risparmio. Poi il kakebo ti chiede di guardare ogni voce.'**
  String get ruleBody;

  /// No description provided for @apply.
  ///
  /// In it, this message translates to:
  /// **'Applica'**
  String get apply;

  /// No description provided for @applied.
  ///
  /// In it, this message translates to:
  /// **'Applicato'**
  String get applied;

  /// No description provided for @fixedOverHalf.
  ///
  /// In it, this message translates to:
  /// **'Le spese fisse superano già la metà'**
  String get fixedOverHalf;

  /// No description provided for @fixedPart.
  ///
  /// In it, this message translates to:
  /// **'Di cui {amount} già in spese fisse'**
  String fixedPart(String amount);

  /// No description provided for @otherPillars.
  ///
  /// In it, this message translates to:
  /// **'Desideri, cultura, imprevisti'**
  String get otherPillars;

  /// No description provided for @shareAmongThree.
  ///
  /// In it, this message translates to:
  /// **'Da dividere tra i tre pilastri'**
  String get shareAmongThree;

  /// No description provided for @savings.
  ///
  /// In it, this message translates to:
  /// **'Risparmio'**
  String get savings;

  /// No description provided for @becomesGoal.
  ///
  /// In it, this message translates to:
  /// **'Diventa il tuo obiettivo del mese'**
  String get becomesGoal;

  /// No description provided for @fixedTitle.
  ///
  /// In it, this message translates to:
  /// **'Spese fisse ricorrenti'**
  String get fixedTitle;

  /// No description provided for @fixedHint.
  ///
  /// In it, this message translates to:
  /// **'Si ripetono ogni mese, modificabili quando vuoi'**
  String get fixedHint;

  /// No description provided for @addFixed.
  ///
  /// In it, this message translates to:
  /// **'+ Aggiungi spesa fissa'**
  String get addFixed;

  /// No description provided for @remove.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi {name}'**
  String remove(String name);

  /// No description provided for @budgetsTitle.
  ///
  /// In it, this message translates to:
  /// **'Budget dei pilastri'**
  String get budgetsTitle;

  /// No description provided for @budgetsAuto.
  ///
  /// In it, this message translates to:
  /// **'Divisi in automatico da ciò che resta da spendere'**
  String get budgetsAuto;

  /// No description provided for @budgetsMine.
  ///
  /// In it, this message translates to:
  /// **'Scelti da te'**
  String get budgetsMine;

  /// No description provided for @allAssigned.
  ///
  /// In it, this message translates to:
  /// **'Tutto il disponibile è assegnato.'**
  String get allAssigned;

  /// No description provided for @toAssign.
  ///
  /// In it, this message translates to:
  /// **'Da assegnare: {amount}'**
  String toAssign(String amount);

  /// No description provided for @overBy.
  ///
  /// In it, this message translates to:
  /// **'Oltre il disponibile di {amount}'**
  String overBy(String amount);

  /// No description provided for @splitAgain.
  ///
  /// In it, this message translates to:
  /// **'Dividi di nuovo in automatico'**
  String get splitAgain;

  /// No description provided for @mindful.
  ///
  /// In it, this message translates to:
  /// **'Da spendere con consapevolezza'**
  String get mindful;

  /// No description provided for @perWeek.
  ///
  /// In it, this message translates to:
  /// **'circa {amount} a settimana'**
  String perWeek(String amount);

  /// No description provided for @startMonth.
  ///
  /// In it, this message translates to:
  /// **'Inizia {month}'**
  String startMonth(String month);

  /// No description provided for @eveningThought.
  ///
  /// In it, this message translates to:
  /// **'Il pensiero della sera'**
  String get eveningThought;

  /// No description provided for @happyQuestion.
  ///
  /// In it, this message translates to:
  /// **'Cosa ti ha reso felice oggi?'**
  String get happyQuestion;

  /// No description provided for @write.
  ///
  /// In it, this message translates to:
  /// **'Scrivi'**
  String get write;

  /// No description provided for @leftFor.
  ///
  /// In it, this message translates to:
  /// **'Ti restano per {month}'**
  String leftFor(String month);

  /// No description provided for @spendToday.
  ///
  /// In it, this message translates to:
  /// **'da spendere entro oggi'**
  String get spendToday;

  /// No description provided for @spentShare.
  ///
  /// In it, this message translates to:
  /// **'{pct}% del disponibile già speso'**
  String spentShare(int pct);

  /// No description provided for @branchTitle.
  ///
  /// In it, this message translates to:
  /// **'Il ramo del risparmio'**
  String get branchTitle;

  /// No description provided for @branchRule.
  ///
  /// In it, this message translates to:
  /// **'Ogni fiore vale {flower} del tuo obiettivo. Sboccia quando la spesa resta nel ritmo del mese: finora {soFar} su {goal}.'**
  String branchRule(String flower, String soFar, String goal);

  /// No description provided for @today.
  ///
  /// In it, this message translates to:
  /// **'Oggi'**
  String get today;

  /// No description provided for @addShort.
  ///
  /// In it, this message translates to:
  /// **'+ Annota'**
  String get addShort;

  /// No description provided for @emptyLedger.
  ///
  /// In it, this message translates to:
  /// **'Il registro è ancora vuoto. Annota la prima spesa del mese: basta un importo e un pilastro.'**
  String get emptyLedger;

  /// No description provided for @quietToday.
  ///
  /// In it, this message translates to:
  /// **'Nessuna spesa oggi. Una giornata leggera.'**
  String get quietToday;

  /// No description provided for @newExpense.
  ///
  /// In it, this message translates to:
  /// **'Nuova spesa'**
  String get newExpense;

  /// No description provided for @editExpense.
  ///
  /// In it, this message translates to:
  /// **'Modifica spesa'**
  String get editExpense;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @notePlaceholder.
  ///
  /// In it, this message translates to:
  /// **'Per cosa? es. spesa, cinema, farmacia'**
  String get notePlaceholder;

  /// No description provided for @suggested.
  ///
  /// In it, this message translates to:
  /// **'Pilastro suggerito dalla nota: {pillar}'**
  String suggested(String pillar);

  /// No description provided for @save.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get save;

  /// No description provided for @deleteExpense.
  ///
  /// In it, this message translates to:
  /// **'Elimina spesa'**
  String get deleteExpense;

  /// No description provided for @expenseDeleted.
  ///
  /// In it, this message translates to:
  /// **'Spesa eliminata'**
  String get expenseDeleted;

  /// No description provided for @undo.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get undo;

  /// No description provided for @erase.
  ///
  /// In it, this message translates to:
  /// **'Cancella'**
  String get erase;

  /// No description provided for @settings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settings;

  /// No description provided for @ledgerKicker.
  ///
  /// In it, this message translates to:
  /// **'REGISTRO'**
  String get ledgerKicker;

  /// No description provided for @ledgerTitle.
  ///
  /// In it, this message translates to:
  /// **'Dove sono andati'**
  String get ledgerTitle;

  /// No description provided for @thisWeek.
  ///
  /// In it, this message translates to:
  /// **'Questa settimana'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In it, this message translates to:
  /// **'Questo mese'**
  String get thisMonth;

  /// No description provided for @ofAvailable.
  ///
  /// In it, this message translates to:
  /// **'su {amount} disponibili'**
  String ofAvailable(String amount);

  /// No description provided for @leftOf.
  ///
  /// In it, this message translates to:
  /// **'{left} rimasti su {budget}'**
  String leftOf(String left, String budget);

  /// No description provided for @noneInPillar.
  ///
  /// In it, this message translates to:
  /// **'Nessuna spesa in questo pilastro.'**
  String get noneInPillar;

  /// No description provided for @journalKicker.
  ///
  /// In it, this message translates to:
  /// **'DIARIO'**
  String get journalKicker;

  /// No description provided for @journalTitle.
  ///
  /// In it, this message translates to:
  /// **'Due momenti'**
  String get journalTitle;

  /// No description provided for @journalIntro.
  ///
  /// In it, this message translates to:
  /// **'Uno per la sera, uno per il mese. Ogni domenica il diario raccoglie da solo la settimana.'**
  String get journalIntro;

  /// No description provided for @everyDayAt.
  ///
  /// In it, this message translates to:
  /// **'Ogni giorno alle {time}'**
  String everyDayAt(String time);

  /// No description provided for @written.
  ///
  /// In it, this message translates to:
  /// **'Scritto'**
  String get written;

  /// No description provided for @toWrite.
  ///
  /// In it, this message translates to:
  /// **'Da scrivere'**
  String get toWrite;

  /// No description provided for @eveningNow.
  ///
  /// In it, this message translates to:
  /// **'È sera: puoi scriverlo ora.'**
  String get eveningNow;

  /// No description provided for @opensAt.
  ///
  /// In it, this message translates to:
  /// **'Si apre stasera alle {time}.'**
  String opensAt(String time);

  /// No description provided for @theMonth.
  ///
  /// In it, this message translates to:
  /// **'Il mese'**
  String get theMonth;

  /// No description provided for @questionsFrom.
  ///
  /// In it, this message translates to:
  /// **'Le quattro domande · dal {date}'**
  String questionsFrom(String date);

  /// No description provided for @sealed.
  ///
  /// In it, this message translates to:
  /// **'Sigillato'**
  String get sealed;

  /// No description provided for @open.
  ///
  /// In it, this message translates to:
  /// **'Aperto'**
  String get open;

  /// No description provided for @monthSealed.
  ///
  /// In it, this message translates to:
  /// **'{month} è chiuso con il sigillo.'**
  String monthSealed(String month);

  /// No description provided for @questionsHint.
  ///
  /// In it, this message translates to:
  /// **'Quanto hai, quanto vuoi risparmiare, quanto spendi, come migliorare.'**
  String get questionsHint;

  /// No description provided for @timeline.
  ///
  /// In it, this message translates to:
  /// **'Cronologia'**
  String get timeline;

  /// No description provided for @week.
  ///
  /// In it, this message translates to:
  /// **'La settimana · {span}'**
  String week(String span);

  /// No description provided for @weekNoSpending.
  ///
  /// In it, this message translates to:
  /// **'Una settimana senza spese.'**
  String get weekNoSpending;

  /// No description provided for @questionsOf.
  ///
  /// In it, this message translates to:
  /// **'Le quattro domande · {month}'**
  String questionsOf(String month);

  /// No description provided for @sealedSaved.
  ///
  /// In it, this message translates to:
  /// **'Sigillato · {amount} risparmiati'**
  String sealedSaved(String amount);

  /// No description provided for @monthClosed.
  ///
  /// In it, this message translates to:
  /// **'Mese chiuso con il sigillo.'**
  String get monthClosed;

  /// No description provided for @resolutionFor.
  ///
  /// In it, this message translates to:
  /// **'Proposito per {month}: {goal}'**
  String resolutionFor(String month, String goal);

  /// No description provided for @backToJournal.
  ///
  /// In it, this message translates to:
  /// **'← Diario'**
  String get backToJournal;

  /// No description provided for @reviewKicker.
  ///
  /// In it, this message translates to:
  /// **'FINE MESE'**
  String get reviewKicker;

  /// No description provided for @reviewTitle.
  ///
  /// In it, this message translates to:
  /// **'Le quattro domande'**
  String get reviewTitle;

  /// No description provided for @soFar.
  ///
  /// In it, this message translates to:
  /// **'{month}, FINORA'**
  String soFar(String month);

  /// No description provided for @towardSaving.
  ///
  /// In it, this message translates to:
  /// **'verso il risparmio · obiettivo {goal}'**
  String towardSaving(String goal);

  /// No description provided for @flowerWorth.
  ///
  /// In it, this message translates to:
  /// **'Ogni fiore vale {flower}. Finora {soFar} su {goal} messi da parte.'**
  String flowerWorth(String flower, String soFar, String goal);

  /// No description provided for @question.
  ///
  /// In it, this message translates to:
  /// **'Domanda {n}'**
  String question(int n);

  /// No description provided for @incomeMinusFixed.
  ///
  /// In it, this message translates to:
  /// **'Entrate meno spese fisse'**
  String get incomeMinusFixed;

  /// No description provided for @goalFor.
  ///
  /// In it, this message translates to:
  /// **'Il tuo obiettivo per {month}'**
  String goalFor(String month);

  /// No description provided for @acrossPillars.
  ///
  /// In it, this message translates to:
  /// **'Nei quattro pilastri'**
  String get acrossPillars;

  /// No description provided for @smallResolution.
  ///
  /// In it, this message translates to:
  /// **'Un piccolo proposito per {month}'**
  String smallResolution(String month);

  /// No description provided for @plan.
  ///
  /// In it, this message translates to:
  /// **'Pianifica {month} →'**
  String plan(String month);

  /// No description provided for @sealMonth.
  ///
  /// In it, this message translates to:
  /// **'Chiudi {month} con il sigillo'**
  String sealMonth(String month);

  /// No description provided for @calendarKicker.
  ///
  /// In it, this message translates to:
  /// **'CALENDARIO'**
  String get calendarKicker;

  /// No description provided for @month.
  ///
  /// In it, this message translates to:
  /// **'Mese'**
  String get month;

  /// No description provided for @year.
  ///
  /// In it, this message translates to:
  /// **'Anno'**
  String get year;

  /// No description provided for @quietDay.
  ///
  /// In it, this message translates to:
  /// **'Una giornata tranquilla. Nessuna spesa annotata.'**
  String get quietDay;

  /// No description provided for @goalReached.
  ///
  /// In it, this message translates to:
  /// **'Obiettivo di risparmio raggiunto'**
  String get goalReached;

  /// No description provided for @spentInPillars.
  ///
  /// In it, this message translates to:
  /// **'Speso nei pilastri'**
  String get spentInPillars;

  /// No description provided for @onTrack.
  ///
  /// In it, this message translates to:
  /// **'Sulla strada per risparmiare'**
  String get onTrack;

  /// No description provided for @savedLabel.
  ///
  /// In it, this message translates to:
  /// **'Risparmiato'**
  String get savedLabel;

  /// No description provided for @goal.
  ///
  /// In it, this message translates to:
  /// **'Obiettivo'**
  String get goal;

  /// No description provided for @monthAhead.
  ///
  /// In it, this message translates to:
  /// **'Mese ancora da vivere.'**
  String get monthAhead;

  /// No description provided for @monthEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna spesa annotata in questo mese.'**
  String get monthEmpty;

  /// No description provided for @monthNow.
  ///
  /// In it, this message translates to:
  /// **'Mese in corso: il sigillo arriva con la revisione di fine mese.'**
  String get monthNow;

  /// No description provided for @monthReached.
  ///
  /// In it, this message translates to:
  /// **'Obiettivo raggiunto: il ramo è fiorito e il mese porta il sigillo.'**
  String get monthReached;

  /// No description provided for @missedBy.
  ///
  /// In it, this message translates to:
  /// **'Obiettivo mancato di {amount}.'**
  String missedBy(String amount);

  /// No description provided for @savedGoodnight.
  ///
  /// In it, this message translates to:
  /// **'Salvato nel diario. Buonanotte.'**
  String get savedGoodnight;

  /// No description provided for @edit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get edit;

  /// No description provided for @backToLedgerShort.
  ///
  /// In it, this message translates to:
  /// **'Torna al registro'**
  String get backToLedgerShort;

  /// No description provided for @breathFirst.
  ///
  /// In it, this message translates to:
  /// **'Prima, un respiro'**
  String get breathFirst;

  /// No description provided for @followCircle.
  ///
  /// In it, this message translates to:
  /// **'Segui il cerchio per tre respiri, poi scrivi.'**
  String get followCircle;

  /// No description provided for @ready.
  ///
  /// In it, this message translates to:
  /// **'Sono pronto'**
  String get ready;

  /// No description provided for @smallThing.
  ///
  /// In it, this message translates to:
  /// **'Anche una cosa piccola. Fai un respiro, poi scrivi.'**
  String get smallThing;

  /// No description provided for @todayHint.
  ///
  /// In it, this message translates to:
  /// **'Oggi…'**
  String get todayHint;

  /// No description provided for @later.
  ///
  /// In it, this message translates to:
  /// **'Più tardi'**
  String get later;

  /// No description provided for @keepThought.
  ///
  /// In it, this message translates to:
  /// **'Custodisci il pensiero'**
  String get keepThought;

  /// No description provided for @close.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get close;

  /// No description provided for @breatheIn.
  ///
  /// In it, this message translates to:
  /// **'Inspira'**
  String get breatheIn;

  /// No description provided for @breatheOut.
  ///
  /// In it, this message translates to:
  /// **'Espira'**
  String get breatheOut;

  /// No description provided for @channel.
  ///
  /// In it, this message translates to:
  /// **'La sera'**
  String get channel;

  /// No description provided for @channelInfo.
  ///
  /// In it, this message translates to:
  /// **'Il pensiero della sera e la nota delle spese'**
  String get channelInfo;

  /// No description provided for @noteTitle.
  ///
  /// In it, this message translates to:
  /// **'La nota della sera'**
  String get noteTitle;

  /// No description provided for @noteBody.
  ///
  /// In it, this message translates to:
  /// **'Annota le spese di oggi: basta un importo e un pilastro.'**
  String get noteBody;

  /// No description provided for @settingsKicker.
  ///
  /// In it, this message translates to:
  /// **'IMPOSTAZIONI'**
  String get settingsKicker;

  /// No description provided for @ledgerGroup.
  ///
  /// In it, this message translates to:
  /// **'REGISTRO'**
  String get ledgerGroup;

  /// No description provided for @monthStartLabel.
  ///
  /// In it, this message translates to:
  /// **'Inizio del mese'**
  String get monthStartLabel;

  /// No description provided for @monthStartHint.
  ///
  /// In it, this message translates to:
  /// **'Per esempio il giorno dello stipendio'**
  String get monthStartHint;

  /// No description provided for @startDay.
  ///
  /// In it, this message translates to:
  /// **'Il {day}°'**
  String startDay(int day);

  /// No description provided for @monthStartDialog.
  ///
  /// In it, this message translates to:
  /// **'Il mese inizia il giorno'**
  String get monthStartDialog;

  /// No description provided for @incomeFixed.
  ///
  /// In it, this message translates to:
  /// **'Entrate e spese fisse'**
  String get incomeFixed;

  /// No description provided for @incomeFixedHint.
  ///
  /// In it, this message translates to:
  /// **'Entrate, spese ricorrenti, risparmio e budget'**
  String get incomeFixedHint;

  /// No description provided for @fixedValue.
  ///
  /// In it, this message translates to:
  /// **'{amount} fisse ›'**
  String fixedValue(String amount);

  /// No description provided for @rhythm.
  ///
  /// In it, this message translates to:
  /// **'RITMO'**
  String get rhythm;

  /// No description provided for @weekly.
  ///
  /// In it, this message translates to:
  /// **'Riepilogo della domenica'**
  String get weekly;

  /// No description provided for @weeklyHint.
  ///
  /// In it, this message translates to:
  /// **'La settimana raccolta nel diario, niente da scrivere'**
  String get weeklyHint;

  /// No description provided for @proverb.
  ///
  /// In it, this message translates to:
  /// **'Frase del giorno'**
  String get proverb;

  /// No description provided for @proverbHint.
  ///
  /// In it, this message translates to:
  /// **'Un proverbio giapponese in fondo a Oggi'**
  String get proverbHint;

  /// No description provided for @eveningNote.
  ///
  /// In it, this message translates to:
  /// **'Nota serale'**
  String get eveningNote;

  /// No description provided for @eveningNoteHint.
  ///
  /// In it, this message translates to:
  /// **'Un invito a scrivere le spese del giorno'**
  String get eveningNoteHint;

  /// No description provided for @noteTime.
  ///
  /// In it, this message translates to:
  /// **'Orario della nota'**
  String get noteTime;

  /// No description provided for @tapToChange.
  ///
  /// In it, this message translates to:
  /// **'Tocca per cambiare'**
  String get tapToChange;

  /// No description provided for @noteTimeDialog.
  ///
  /// In it, this message translates to:
  /// **'Orario della nota serale'**
  String get noteTimeDialog;

  /// No description provided for @evenings.
  ///
  /// In it, this message translates to:
  /// **'LA SERA'**
  String get evenings;

  /// No description provided for @thoughtNotice.
  ///
  /// In it, this message translates to:
  /// **'Notifica del pensiero'**
  String get thoughtNotice;

  /// No description provided for @time.
  ///
  /// In it, this message translates to:
  /// **'Orario'**
  String get time;

  /// No description provided for @thoughtTimeDialog.
  ///
  /// In it, this message translates to:
  /// **'Orario del pensiero della sera'**
  String get thoughtTimeDialog;

  /// No description provided for @precise.
  ///
  /// In it, this message translates to:
  /// **'Orario preciso'**
  String get precise;

  /// No description provided for @preciseOn.
  ///
  /// In it, this message translates to:
  /// **'Le notifiche arrivano al minuto'**
  String get preciseOn;

  /// No description provided for @preciseOff.
  ///
  /// In it, this message translates to:
  /// **'Senza, Android può ritardarle fino a un\'ora'**
  String get preciseOff;

  /// No description provided for @active.
  ///
  /// In it, this message translates to:
  /// **'Attivo'**
  String get active;

  /// No description provided for @activate.
  ///
  /// In it, this message translates to:
  /// **'Attiva ›'**
  String get activate;

  /// No description provided for @writeToday.
  ///
  /// In it, this message translates to:
  /// **'Scrivi il pensiero di oggi'**
  String get writeToday;

  /// No description provided for @writeTodayHint.
  ///
  /// In it, this message translates to:
  /// **'Una schermata senza distrazioni'**
  String get writeTodayHint;

  /// No description provided for @data.
  ///
  /// In it, this message translates to:
  /// **'DATI'**
  String get data;

  /// No description provided for @exportLedger.
  ///
  /// In it, this message translates to:
  /// **'Esporta registro'**
  String get exportLedger;

  /// No description provided for @exportHint.
  ///
  /// In it, this message translates to:
  /// **'Un file CSV da aprire con un foglio di calcolo'**
  String get exportHint;

  /// No description provided for @ledgerSaved.
  ///
  /// In it, this message translates to:
  /// **'Registro salvato'**
  String get ledgerSaved;

  /// No description provided for @backupSave.
  ///
  /// In it, this message translates to:
  /// **'Salva un backup'**
  String get backupSave;

  /// No description provided for @backupHint.
  ///
  /// In it, this message translates to:
  /// **'Tutti i dati in un file, anche per un nuovo telefono'**
  String get backupHint;

  /// No description provided for @backupSaved.
  ///
  /// In it, this message translates to:
  /// **'Backup salvato'**
  String get backupSaved;

  /// No description provided for @restore.
  ///
  /// In it, this message translates to:
  /// **'Ripristina un backup'**
  String get restore;

  /// No description provided for @restoreHint.
  ///
  /// In it, this message translates to:
  /// **'Sostituisce i dati attuali con quelli del file'**
  String get restoreHint;

  /// No description provided for @restoreAsk.
  ///
  /// In it, this message translates to:
  /// **'Ripristinare il backup?'**
  String get restoreAsk;

  /// No description provided for @restoreWarn.
  ///
  /// In it, this message translates to:
  /// **'I dati attuali verranno sostituiti da quelli del file.'**
  String get restoreWarn;

  /// No description provided for @restoreYes.
  ///
  /// In it, this message translates to:
  /// **'Ripristina'**
  String get restoreYes;

  /// No description provided for @restored.
  ///
  /// In it, this message translates to:
  /// **'Backup ripristinato'**
  String get restored;

  /// No description provided for @notABackup.
  ///
  /// In it, this message translates to:
  /// **'Questo file non è un backup di Kakebo'**
  String get notABackup;

  /// No description provided for @wipe.
  ///
  /// In it, this message translates to:
  /// **'Cancella tutti i dati'**
  String get wipe;

  /// No description provided for @wipeHint.
  ///
  /// In it, this message translates to:
  /// **'Spese, pensieri e impostazioni. Non si può annullare'**
  String get wipeHint;

  /// No description provided for @wipeAsk.
  ///
  /// In it, this message translates to:
  /// **'Cancellare tutto?'**
  String get wipeAsk;

  /// No description provided for @wipeWarn.
  ///
  /// In it, this message translates to:
  /// **'Spese, spese fisse, pensieri, sigilli e impostazioni verranno eliminati da questo telefono. Se vuoi tenerli, salva prima un backup.'**
  String get wipeWarn;

  /// No description provided for @other.
  ///
  /// In it, this message translates to:
  /// **'ALTRO'**
  String get other;

  /// No description provided for @replayIntro.
  ///
  /// In it, this message translates to:
  /// **'Rivedi l\'introduzione'**
  String get replayIntro;

  /// No description provided for @replayIntroHint.
  ///
  /// In it, this message translates to:
  /// **'I pilastri e le domande'**
  String get replayIntroHint;

  /// No description provided for @licenses.
  ///
  /// In it, this message translates to:
  /// **'Licenze'**
  String get licenses;

  /// No description provided for @licensesHint.
  ///
  /// In it, this message translates to:
  /// **'Font, stampe e librerie usate'**
  String get licensesHint;

  /// No description provided for @prints.
  ///
  /// In it, this message translates to:
  /// **'Stampe (pubblico dominio, Wikimedia Commons)'**
  String get prints;

  /// No description provided for @printsList.
  ///
  /// In it, this message translates to:
  /// **'Utagawa Hiroshige, Giardino di susini a Kameido (Cento vedute famose di Edo), 1857.\nZheng Xie, Bambù e rocce. Google Art Project.\nZheng Xie, Orchidee. Princeton University Art Museum, 2014-128.\nKatsushika Hokusai, Crisantemi e ape, c. 1832.\nWang Mian, Pruno in inchiostro (lo sfondo di ogni schermata).\n\nOpere in pubblico dominio, riprodotte da Wikimedia Commons.'**
  String get printsList;

  /// No description provided for @pillarNeeds.
  ///
  /// In it, this message translates to:
  /// **'Necessità'**
  String get pillarNeeds;

  /// No description provided for @pillarNeedsJp.
  ///
  /// In it, this message translates to:
  /// **'必要 hitsuyō · bambù'**
  String get pillarNeedsJp;

  /// No description provided for @pillarNeedsVirtue.
  ///
  /// In it, this message translates to:
  /// **'Il bambù: si piega ma non si spezza'**
  String get pillarNeedsVirtue;

  /// No description provided for @pillarWants.
  ///
  /// In it, this message translates to:
  /// **'Desideri'**
  String get pillarWants;

  /// No description provided for @pillarWantsJp.
  ///
  /// In it, this message translates to:
  /// **'欲しい hoshii · susino'**
  String get pillarWantsJp;

  /// No description provided for @pillarWantsVirtue.
  ///
  /// In it, this message translates to:
  /// **'Il susino: fiorisce quando serve gioia'**
  String get pillarWantsVirtue;

  /// No description provided for @pillarCulture.
  ///
  /// In it, this message translates to:
  /// **'Cultura'**
  String get pillarCulture;

  /// No description provided for @pillarCultureJp.
  ///
  /// In it, this message translates to:
  /// **'文化 bunka · orchidea'**
  String get pillarCultureJp;

  /// No description provided for @pillarCultureVirtue.
  ///
  /// In it, this message translates to:
  /// **'L\'orchidea: nutre la mente in silenzio'**
  String get pillarCultureVirtue;

  /// No description provided for @pillarUnexpected.
  ///
  /// In it, this message translates to:
  /// **'Imprevisti'**
  String get pillarUnexpected;

  /// No description provided for @pillarUnexpectedJp.
  ///
  /// In it, this message translates to:
  /// **'予想外 yosōgai · crisantemo'**
  String get pillarUnexpectedJp;

  /// No description provided for @pillarUnexpectedVirtue.
  ///
  /// In it, this message translates to:
  /// **'Il crisantemo: resiste al freddo inatteso'**
  String get pillarUnexpectedVirtue;

  /// No description provided for @seasonWinter.
  ///
  /// In it, this message translates to:
  /// **'Inverno'**
  String get seasonWinter;

  /// No description provided for @seasonWinterPlant.
  ///
  /// In it, this message translates to:
  /// **'Nandina'**
  String get seasonWinterPlant;

  /// No description provided for @seasonSpring.
  ///
  /// In it, this message translates to:
  /// **'Primavera'**
  String get seasonSpring;

  /// No description provided for @seasonSpringPlant.
  ///
  /// In it, this message translates to:
  /// **'Ciliegio'**
  String get seasonSpringPlant;

  /// No description provided for @seasonSummer.
  ///
  /// In it, this message translates to:
  /// **'Estate'**
  String get seasonSummer;

  /// No description provided for @seasonSummerPlant.
  ///
  /// In it, this message translates to:
  /// **'Pesce rosso'**
  String get seasonSummerPlant;

  /// No description provided for @seasonAutumn.
  ///
  /// In it, this message translates to:
  /// **'Autunno'**
  String get seasonAutumn;

  /// No description provided for @seasonAutumnPlant.
  ///
  /// In it, this message translates to:
  /// **'Luna piena'**
  String get seasonAutumnPlant;

  /// No description provided for @proverb1Meaning.
  ///
  /// In it, this message translates to:
  /// **'Anche la polvere, accumulandosi, diventa una montagna.'**
  String get proverb1Meaning;

  /// No description provided for @proverb2Meaning.
  ///
  /// In it, this message translates to:
  /// **'Sapere quando si ha abbastanza.'**
  String get proverb2Meaning;

  /// No description provided for @proverb3Meaning.
  ///
  /// In it, this message translates to:
  /// **'Se hai fretta, prendi la strada lunga.'**
  String get proverb3Meaning;

  /// No description provided for @proverb4Meaning.
  ///
  /// In it, this message translates to:
  /// **'Chi compra ciò che costa poco, perde denaro.'**
  String get proverb4Meaning;

  /// No description provided for @proverb5Meaning.
  ///
  /// In it, this message translates to:
  /// **'Anche una pietra si scalda, se ci siedi sopra tre anni.'**
  String get proverb5Meaning;

  /// No description provided for @proverb6Meaning.
  ///
  /// In it, this message translates to:
  /// **'Cadi sette volte, rialzati otto.'**
  String get proverb6Meaning;

  /// No description provided for @proverb7Meaning.
  ///
  /// In it, this message translates to:
  /// **'Ogni incontro accade una volta sola.'**
  String get proverb7Meaning;

  /// No description provided for @defaultFixed1.
  ///
  /// In it, this message translates to:
  /// **'Affitto'**
  String get defaultFixed1;

  /// No description provided for @defaultFixed2.
  ///
  /// In it, this message translates to:
  /// **'Bollette luce e gas'**
  String get defaultFixed2;

  /// No description provided for @defaultFixed3.
  ///
  /// In it, this message translates to:
  /// **'Internet e telefono'**
  String get defaultFixed3;

  /// No description provided for @defaultFixed4.
  ///
  /// In it, this message translates to:
  /// **'Abbonamenti'**
  String get defaultFixed4;

  /// No description provided for @defaultFixed5.
  ///
  /// In it, this message translates to:
  /// **'Assicurazione'**
  String get defaultFixed5;

  /// No description provided for @csvDate.
  ///
  /// In it, this message translates to:
  /// **'data'**
  String get csvDate;

  /// No description provided for @csvNote.
  ///
  /// In it, this message translates to:
  /// **'nota'**
  String get csvNote;

  /// No description provided for @csvAmount.
  ///
  /// In it, this message translates to:
  /// **'importo'**
  String get csvAmount;

  /// No description provided for @csvPillar.
  ///
  /// In it, this message translates to:
  /// **'pilastro'**
  String get csvPillar;

  /// No description provided for @step1Title.
  ///
  /// In it, this message translates to:
  /// **'Un registro per la casa'**
  String get step1Title;

  /// No description provided for @step1Body.
  ///
  /// In it, this message translates to:
  /// **'Nato in Giappone nel 1904: annoti ogni spesa, ti fermi un momento, osservi dove vanno i soldi.'**
  String get step1Body;

  /// No description provided for @step1Cta.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get step1Cta;

  /// No description provided for @step2Title.
  ///
  /// In it, this message translates to:
  /// **'Quattro pilastri, quattro gentiluomini'**
  String get step2Title;

  /// No description provided for @step2Body.
  ///
  /// In it, this message translates to:
  /// **'Ogni spesa va in uno di quattro pilastri, ognuno con la sua pianta.'**
  String get step2Body;

  /// No description provided for @step2Cta.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get step2Cta;

  /// No description provided for @step3Title.
  ///
  /// In it, this message translates to:
  /// **'Quattro domande'**
  String get step3Title;

  /// No description provided for @step3Body.
  ///
  /// In it, this message translates to:
  /// **'A inizio e fine mese rispondi sempre alle stesse quattro. Scorri per iniziare.'**
  String get step3Body;

  /// No description provided for @step3Cta.
  ///
  /// In it, this message translates to:
  /// **'Inizia il mio mese'**
  String get step3Cta;

  /// No description provided for @fourQuestion1.
  ///
  /// In it, this message translates to:
  /// **'Quanto denaro hai?'**
  String get fourQuestion1;

  /// No description provided for @fourQuestion2.
  ///
  /// In it, this message translates to:
  /// **'Quanto vorresti risparmiare?'**
  String get fourQuestion2;

  /// No description provided for @fourQuestion3.
  ///
  /// In it, this message translates to:
  /// **'Quanto stai spendendo?'**
  String get fourQuestion3;

  /// No description provided for @fourQuestion4.
  ///
  /// In it, this message translates to:
  /// **'Come puoi migliorare?'**
  String get fourQuestion4;

  /// No description provided for @tabToday.
  ///
  /// In it, this message translates to:
  /// **'Oggi'**
  String get tabToday;

  /// No description provided for @tabLedger.
  ///
  /// In it, this message translates to:
  /// **'Registro'**
  String get tabLedger;

  /// No description provided for @tabJournal.
  ///
  /// In it, this message translates to:
  /// **'Diario'**
  String get tabJournal;

  /// No description provided for @tabCalendar.
  ///
  /// In it, this message translates to:
  /// **'Calendario'**
  String get tabCalendar;

  /// No description provided for @perDay.
  ///
  /// In it, this message translates to:
  /// **'{days, plural, =1{circa {amount} al giorno per domani} other{circa {amount} al giorno per i prossimi {days} giorni}}'**
  String perDay(String amount, int days);

  /// No description provided for @flowers.
  ///
  /// In it, this message translates to:
  /// **'{n, plural, =1{1 fiore su 10} other{{n} fiori su 10}}'**
  String flowers(int n);

  /// No description provided for @weekPace.
  ///
  /// In it, this message translates to:
  /// **'{onPace, select, true{Nel ritmo del mese} other{Sopra il ritmo del mese}}'**
  String weekPace(String onPace);

  /// No description provided for @weekFullest.
  ///
  /// In it, this message translates to:
  /// **'Il pilastro più pieno: {pillar}.'**
  String weekFullest(String pillar);

  /// No description provided for @weekQuiet.
  ///
  /// In it, this message translates to:
  /// **'{days} giorni senza spese.'**
  String weekQuiet(int days);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
