// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get newItem => 'Nuova voce';

  @override
  String get morning => 'Buongiorno';

  @override
  String get afternoon => 'Buon pomeriggio';

  @override
  String get evening => 'Buonasera';

  @override
  String get skip => 'Salta';

  @override
  String get back => 'Indietro';

  @override
  String get backToLedger => '← Torna al registro';

  @override
  String get setupTitle =>
      'Prima di iniziare, scrivi cosa entra e cosa deve uscire.';

  @override
  String get income => 'Entrate del mese';

  @override
  String get incomeHint => 'Stipendio e altre entrate';

  @override
  String get savingGoal => 'Obiettivo di risparmio';

  @override
  String get savingHint => 'Da mettere da parte subito, prima di spendere';

  @override
  String get ruleTitle => 'Punto di partenza: 50 / 30 / 20';

  @override
  String get ruleBody =>
      'Metà ai bisogni, un terzo al resto, un quinto al risparmio. Poi il kakebo ti chiede di guardare ogni voce.';

  @override
  String get apply => 'Applica';

  @override
  String get applied => 'Applicato';

  @override
  String get fixedOverHalf => 'Le spese fisse superano già la metà';

  @override
  String fixedPart(String amount) {
    return 'Di cui $amount già in spese fisse';
  }

  @override
  String get otherPillars => 'Desideri, cultura, imprevisti';

  @override
  String get shareAmongThree => 'Da dividere tra i tre pilastri';

  @override
  String get savings => 'Risparmio';

  @override
  String get becomesGoal => 'Diventa il tuo obiettivo del mese';

  @override
  String get fixedTitle => 'Spese fisse ricorrenti';

  @override
  String get fixedHint => 'Si ripetono ogni mese, modificabili quando vuoi';

  @override
  String get addFixed => '+ Aggiungi spesa fissa';

  @override
  String remove(String name) {
    return 'Rimuovi $name';
  }

  @override
  String get budgetsTitle => 'Budget dei pilastri';

  @override
  String get budgetsAuto => 'Divisi in automatico da ciò che resta da spendere';

  @override
  String get budgetsMine => 'Scelti da te';

  @override
  String get allAssigned => 'Tutto il disponibile è assegnato.';

  @override
  String toAssign(String amount) {
    return 'Da assegnare: $amount';
  }

  @override
  String overBy(String amount) {
    return 'Oltre il disponibile di $amount';
  }

  @override
  String get splitAgain => 'Dividi di nuovo in automatico';

  @override
  String get mindful => 'Da spendere con consapevolezza';

  @override
  String perWeek(String amount) {
    return 'circa $amount a settimana';
  }

  @override
  String startMonth(String month) {
    return 'Inizia $month';
  }

  @override
  String get eveningThought => 'Il pensiero della sera';

  @override
  String get happyQuestion => 'Cosa ti ha reso felice oggi?';

  @override
  String get write => 'Scrivi';

  @override
  String leftFor(String month) {
    return 'Ti restano per $month';
  }

  @override
  String get spendToday => 'da spendere entro oggi';

  @override
  String spentShare(int pct) {
    return '$pct% del disponibile già speso';
  }

  @override
  String get branchTitle => 'Il ramo del risparmio';

  @override
  String branchRule(String flower, String soFar, String goal) {
    return 'Ogni fiore vale $flower del tuo obiettivo. Sboccia quando la spesa resta nel ritmo del mese: finora $soFar su $goal.';
  }

  @override
  String get today => 'Oggi';

  @override
  String get addShort => '+ Annota';

  @override
  String get emptyLedger =>
      'Il registro è ancora vuoto. Annota la prima spesa del mese: basta un importo e un pilastro.';

  @override
  String get quietToday => 'Nessuna spesa oggi. Una giornata leggera.';

  @override
  String get newExpense => 'Nuova spesa';

  @override
  String get editExpense => 'Modifica spesa';

  @override
  String get cancel => 'Annulla';

  @override
  String get notePlaceholder => 'Per cosa? es. spesa, cinema, farmacia';

  @override
  String suggested(String pillar) {
    return 'Pilastro suggerito dalla nota: $pillar';
  }

  @override
  String get save => 'Salva';

  @override
  String get deleteExpense => 'Elimina spesa';

  @override
  String get expenseDeleted => 'Spesa eliminata';

  @override
  String get undo => 'Annulla';

  @override
  String get erase => 'Cancella';

  @override
  String get settings => 'Impostazioni';

  @override
  String get ledgerKicker => 'REGISTRO';

  @override
  String get ledgerTitle => 'Dove sono andati';

  @override
  String get thisWeek => 'Questa settimana';

  @override
  String get thisMonth => 'Questo mese';

  @override
  String ofAvailable(String amount) {
    return 'su $amount disponibili';
  }

  @override
  String leftOf(String left, String budget) {
    return '$left rimasti su $budget';
  }

  @override
  String get noneInPillar => 'Nessuna spesa in questo pilastro.';

  @override
  String get journalKicker => 'DIARIO';

  @override
  String get journalTitle => 'Due momenti';

  @override
  String get journalIntro =>
      'Uno per la sera, uno per il mese. Ogni domenica il diario raccoglie da solo la settimana.';

  @override
  String everyDayAt(String time) {
    return 'Ogni giorno alle $time';
  }

  @override
  String get written => 'Scritto';

  @override
  String get toWrite => 'Da scrivere';

  @override
  String get eveningNow => 'È sera: puoi scriverlo ora.';

  @override
  String opensAt(String time) {
    return 'Si apre stasera alle $time.';
  }

  @override
  String get theMonth => 'Il mese';

  @override
  String questionsFrom(String date) {
    return 'Le quattro domande · dal $date';
  }

  @override
  String get sealed => 'Sigillato';

  @override
  String get open => 'Aperto';

  @override
  String monthSealed(String month) {
    return '$month è chiuso con il sigillo.';
  }

  @override
  String get questionsHint =>
      'Quanto hai, quanto vuoi risparmiare, quanto spendi, come migliorare.';

  @override
  String get timeline => 'Cronologia';

  @override
  String week(String span) {
    return 'La settimana · $span';
  }

  @override
  String get weekNoSpending => 'Una settimana senza spese.';

  @override
  String questionsOf(String month) {
    return 'Le quattro domande · $month';
  }

  @override
  String sealedSaved(String amount) {
    return 'Sigillato · $amount risparmiati';
  }

  @override
  String get monthClosed => 'Mese chiuso con il sigillo.';

  @override
  String resolutionFor(String month, String goal) {
    return 'Proposito per $month: $goal';
  }

  @override
  String get backToJournal => '← Diario';

  @override
  String get reviewKicker => 'FINE MESE';

  @override
  String get reviewTitle => 'Le quattro domande';

  @override
  String soFar(String month) {
    return '$month, FINORA';
  }

  @override
  String towardSaving(String goal) {
    return 'verso il risparmio · obiettivo $goal';
  }

  @override
  String flowerWorth(String flower, String soFar, String goal) {
    return 'Ogni fiore vale $flower. Finora $soFar su $goal messi da parte.';
  }

  @override
  String question(int n) {
    return 'Domanda $n';
  }

  @override
  String get incomeMinusFixed => 'Entrate meno spese fisse';

  @override
  String goalFor(String month) {
    return 'Il tuo obiettivo per $month';
  }

  @override
  String get acrossPillars => 'Nei quattro pilastri';

  @override
  String smallResolution(String month) {
    return 'Un piccolo proposito per $month';
  }

  @override
  String plan(String month) {
    return 'Pianifica $month →';
  }

  @override
  String sealMonth(String month) {
    return 'Chiudi $month con il sigillo';
  }

  @override
  String get calendarKicker => 'CALENDARIO';

  @override
  String get month => 'Mese';

  @override
  String get year => 'Anno';

  @override
  String get quietDay => 'Una giornata tranquilla. Nessuna spesa annotata.';

  @override
  String get goalReached => 'Obiettivo di risparmio raggiunto';

  @override
  String get spentInPillars => 'Speso nei pilastri';

  @override
  String get onTrack => 'Sulla strada per risparmiare';

  @override
  String get savedLabel => 'Risparmiato';

  @override
  String get goal => 'Obiettivo';

  @override
  String get monthAhead => 'Mese ancora da vivere.';

  @override
  String get monthEmpty => 'Nessuna spesa annotata in questo mese.';

  @override
  String get monthNow =>
      'Mese in corso: il sigillo arriva con la revisione di fine mese.';

  @override
  String get monthReached =>
      'Obiettivo raggiunto: il ramo è fiorito e il mese porta il sigillo.';

  @override
  String missedBy(String amount) {
    return 'Obiettivo mancato di $amount.';
  }

  @override
  String get savedGoodnight => 'Salvato nel diario. Buonanotte.';

  @override
  String get edit => 'Modifica';

  @override
  String get backToLedgerShort => 'Torna al registro';

  @override
  String get breathFirst => 'Prima, un respiro';

  @override
  String get followCircle => 'Segui il cerchio per tre respiri, poi scrivi.';

  @override
  String get ready => 'Sono pronto';

  @override
  String get smallThing =>
      'Anche una cosa piccola. Fai un respiro, poi scrivi.';

  @override
  String get todayHint => 'Oggi…';

  @override
  String get later => 'Più tardi';

  @override
  String get keepThought => 'Custodisci il pensiero';

  @override
  String get close => 'Chiudi';

  @override
  String get breatheIn => 'Inspira';

  @override
  String get breatheOut => 'Espira';

  @override
  String get channel => 'La sera';

  @override
  String get channelInfo => 'Il pensiero della sera e la nota delle spese';

  @override
  String get noteTitle => 'La nota della sera';

  @override
  String get noteBody =>
      'Annota le spese di oggi: basta un importo e un pilastro.';

  @override
  String get settingsKicker => 'IMPOSTAZIONI';

  @override
  String get ledgerGroup => 'REGISTRO';

  @override
  String get monthStartLabel => 'Inizio del mese';

  @override
  String get monthStartHint => 'Per esempio il giorno dello stipendio';

  @override
  String startDay(int day) {
    return 'Il $day°';
  }

  @override
  String get monthStartDialog => 'Il mese inizia il giorno';

  @override
  String get incomeFixed => 'Entrate e spese fisse';

  @override
  String get incomeFixedHint => 'Entrate, spese ricorrenti, risparmio e budget';

  @override
  String fixedValue(String amount) {
    return '$amount fisse ›';
  }

  @override
  String get rhythm => 'RITMO';

  @override
  String get weekly => 'Riepilogo della domenica';

  @override
  String get weeklyHint =>
      'La settimana raccolta nel diario, niente da scrivere';

  @override
  String get proverb => 'Frase del giorno';

  @override
  String get proverbHint => 'Un proverbio giapponese in fondo a Oggi';

  @override
  String get eveningNote => 'Nota serale';

  @override
  String get eveningNoteHint => 'Un invito a scrivere le spese del giorno';

  @override
  String get noteTime => 'Orario della nota';

  @override
  String get tapToChange => 'Tocca per cambiare';

  @override
  String get noteTimeDialog => 'Orario della nota serale';

  @override
  String get evenings => 'LA SERA';

  @override
  String get thoughtNotice => 'Notifica del pensiero';

  @override
  String get time => 'Orario';

  @override
  String get thoughtTimeDialog => 'Orario del pensiero della sera';

  @override
  String get precise => 'Orario preciso';

  @override
  String get preciseOn => 'Le notifiche arrivano al minuto';

  @override
  String get preciseOff => 'Senza, Android può ritardarle fino a un\'ora';

  @override
  String get active => 'Attivo';

  @override
  String get activate => 'Attiva ›';

  @override
  String get writeToday => 'Scrivi il pensiero di oggi';

  @override
  String get writeTodayHint => 'Una schermata senza distrazioni';

  @override
  String get data => 'DATI';

  @override
  String get exportLedger => 'Esporta registro';

  @override
  String get exportHint => 'Un file CSV da aprire con un foglio di calcolo';

  @override
  String get ledgerSaved => 'Registro salvato';

  @override
  String get backupSave => 'Salva un backup';

  @override
  String get backupHint =>
      'Tutti i dati in un file, anche per un nuovo telefono';

  @override
  String get backupSaved => 'Backup salvato';

  @override
  String get restore => 'Ripristina un backup';

  @override
  String get restoreHint => 'Sostituisce i dati attuali con quelli del file';

  @override
  String get restoreAsk => 'Ripristinare il backup?';

  @override
  String get restoreWarn =>
      'I dati attuali verranno sostituiti da quelli del file.';

  @override
  String get restoreYes => 'Ripristina';

  @override
  String get restored => 'Backup ripristinato';

  @override
  String get notABackup => 'Questo file non è un backup di Kakebo';

  @override
  String get wipe => 'Cancella tutti i dati';

  @override
  String get wipeHint => 'Spese, pensieri e impostazioni. Non si può annullare';

  @override
  String get wipeAsk => 'Cancellare tutto?';

  @override
  String get wipeWarn =>
      'Spese, spese fisse, pensieri, sigilli e impostazioni verranno eliminati da questo telefono. Se vuoi tenerli, salva prima un backup.';

  @override
  String get other => 'ALTRO';

  @override
  String get replayIntro => 'Rivedi l\'introduzione';

  @override
  String get replayIntroHint => 'I pilastri e le domande';

  @override
  String get licenses => 'Licenze';

  @override
  String get licensesHint => 'Font, stampe e librerie usate';

  @override
  String get prints => 'Stampe (pubblico dominio, Wikimedia Commons)';

  @override
  String get printsList =>
      'Utagawa Hiroshige, Giardino di susini a Kameido (Cento vedute famose di Edo), 1857.\nZheng Xie, Bambù e rocce. Google Art Project.\nZheng Xie, Orchidee. Princeton University Art Museum, 2014-128.\nKatsushika Hokusai, Crisantemi e ape, c. 1832.\nWang Mian, Pruno in inchiostro (lo sfondo di ogni schermata).\n\nOpere in pubblico dominio, riprodotte da Wikimedia Commons.';

  @override
  String get pillarNeeds => 'Necessità';

  @override
  String get pillarNeedsJp => '必要 hitsuyō · bambù';

  @override
  String get pillarNeedsVirtue => 'Il bambù: si piega ma non si spezza';

  @override
  String get pillarWants => 'Desideri';

  @override
  String get pillarWantsJp => '欲しい hoshii · susino';

  @override
  String get pillarWantsVirtue => 'Il susino: fiorisce quando serve gioia';

  @override
  String get pillarCulture => 'Cultura';

  @override
  String get pillarCultureJp => '文化 bunka · orchidea';

  @override
  String get pillarCultureVirtue => 'L\'orchidea: nutre la mente in silenzio';

  @override
  String get pillarUnexpected => 'Imprevisti';

  @override
  String get pillarUnexpectedJp => '予想外 yosōgai · crisantemo';

  @override
  String get pillarUnexpectedVirtue =>
      'Il crisantemo: resiste al freddo inatteso';

  @override
  String get seasonWinter => 'Inverno';

  @override
  String get seasonWinterPlant => 'Nandina';

  @override
  String get seasonSpring => 'Primavera';

  @override
  String get seasonSpringPlant => 'Ciliegio';

  @override
  String get seasonSummer => 'Estate';

  @override
  String get seasonSummerPlant => 'Pesce rosso';

  @override
  String get seasonAutumn => 'Autunno';

  @override
  String get seasonAutumnPlant => 'Luna piena';

  @override
  String get proverb1Meaning =>
      'Anche la polvere, accumulandosi, diventa una montagna.';

  @override
  String get proverb2Meaning => 'Sapere quando si ha abbastanza.';

  @override
  String get proverb3Meaning => 'Se hai fretta, prendi la strada lunga.';

  @override
  String get proverb4Meaning => 'Chi compra ciò che costa poco, perde denaro.';

  @override
  String get proverb5Meaning =>
      'Anche una pietra si scalda, se ci siedi sopra tre anni.';

  @override
  String get proverb6Meaning => 'Cadi sette volte, rialzati otto.';

  @override
  String get proverb7Meaning => 'Ogni incontro accade una volta sola.';

  @override
  String get defaultFixed1 => 'Affitto';

  @override
  String get defaultFixed2 => 'Bollette luce e gas';

  @override
  String get defaultFixed3 => 'Internet e telefono';

  @override
  String get defaultFixed4 => 'Abbonamenti';

  @override
  String get defaultFixed5 => 'Assicurazione';

  @override
  String get csvDate => 'data';

  @override
  String get csvNote => 'nota';

  @override
  String get csvAmount => 'importo';

  @override
  String get csvPillar => 'pilastro';

  @override
  String get step1Title => 'Un registro per la casa';

  @override
  String get step1Body =>
      'Nato in Giappone nel 1904: annoti ogni spesa, ti fermi un momento, osservi dove vanno i soldi.';

  @override
  String get step1Cta => 'Avanti';

  @override
  String get step2Title => 'Quattro pilastri, quattro gentiluomini';

  @override
  String get step2Body =>
      'Ogni spesa va in uno di quattro pilastri, ognuno con la sua pianta.';

  @override
  String get step2Cta => 'Avanti';

  @override
  String get step3Title => 'Quattro domande';

  @override
  String get step3Body =>
      'A inizio e fine mese rispondi sempre alle stesse quattro. Scorri per iniziare.';

  @override
  String get step3Cta => 'Inizia il mio mese';

  @override
  String get fourQuestion1 => 'Quanto denaro hai?';

  @override
  String get fourQuestion2 => 'Quanto vorresti risparmiare?';

  @override
  String get fourQuestion3 => 'Quanto stai spendendo?';

  @override
  String get fourQuestion4 => 'Come puoi migliorare?';

  @override
  String get tabToday => 'Oggi';

  @override
  String get tabLedger => 'Registro';

  @override
  String get tabJournal => 'Diario';

  @override
  String get tabCalendar => 'Calendario';

  @override
  String perDay(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'circa $amount al giorno per i prossimi $days giorni',
      one: 'circa $amount al giorno per domani',
    );
    return '$_temp0';
  }

  @override
  String flowers(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n fiori su 10',
      one: '1 fiore su 10',
    );
    return '$_temp0';
  }

  @override
  String weekPace(String onPace) {
    String _temp0 = intl.Intl.selectLogic(onPace, {
      'true': 'Nel ritmo del mese',
      'other': 'Sopra il ritmo del mese',
    });
    return '$_temp0';
  }

  @override
  String weekFullest(String pillar) {
    return 'Il pilastro più pieno: $pillar.';
  }

  @override
  String weekQuiet(int days) {
    return '$days giorni senza spese.';
  }
}
