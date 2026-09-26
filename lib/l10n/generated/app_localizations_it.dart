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
  String get backHome => '← Oggi';

  @override
  String setupTitle(String month) {
    return 'Prepara $month';
  }

  @override
  String get setupIntro =>
      'Cosa entra, cosa esce ogni mese, cosa mettere da parte: il resto è da spendere con consapevolezza.';

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
  String get branchTitle => 'Il ritmo del mese';

  @override
  String get paceExplanation => 'Come si legge il ritmo';

  @override
  String get writeThought => 'Scrivi un pensiero';

  @override
  String get expenseReflection => 'Ripensando a questa spesa';

  @override
  String get optionalReflection => 'Facoltativo, anche solo poche parole.';

  @override
  String get expenseReflectionPrompt =>
      'Come ti senti rispetto a questa scelta?';

  @override
  String get reflectionPlaceholder => 'Se ti va, lascia qualche parola…';

  @override
  String get reflectionInvitation =>
      'Prenditi il tempo che vuoi. Puoi rispondere a una sola domanda, o tornare più tardi.';

  @override
  String get reflectionAutosaved =>
      'Le parole si salvano mentre scrivi. Puoi tornare a cambiarle.';

  @override
  String get monthNumbers => 'I numeri del mese';

  @override
  String get monthGood => 'Cosa ti ha fatto stare bene?';

  @override
  String get monthChange => 'Cosa faresti diversamente?';

  @override
  String get monthIntention =>
      'Quale piccola intenzione vuoi portare nel prossimo mese?';

  @override
  String get intentionForThisMonth => 'Un’intenzione da ritrovare';

  @override
  String get intentionGentle =>
      'L’hai scritta il mese scorso. Puoi tenerla con te, oppure scegliere una strada diversa.';

  @override
  String get weekReflection => 'Un momento per riflettere';

  @override
  String get reflectionMemory => 'Parole del mese';

  @override
  String get moreMemories => 'Mostra altri ricordi';

  @override
  String get weekReflectionPrompt =>
      'C’è una scelta di questa settimana che vorresti ripetere?';

  @override
  String get branchRule =>
      'Un fiore sboccia per ogni decimo di mese trascorso, se la spesa resta nel ritmo del disponibile. Misura il passo, non i soldi messi da parte.';

  @override
  String get today => 'Oggi';

  @override
  String get addExpense => 'Annota spesa';

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
    return 'Rivedi il mese · termina il $date';
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
      'Ciò che ti ha fatto stare bene, ciò che cambieresti, una piccola intenzione per il futuro.';

  @override
  String get timeline => 'Cronologia';

  @override
  String week(String span) {
    return 'La settimana · $span';
  }

  @override
  String get weekNoSpending => 'Una settimana senza spese.';

  @override
  String get backToToday => 'Torna a Oggi';

  @override
  String get choosePillar => 'Scegli un pilastro';

  @override
  String get reminderHint => 'Le spese di oggi e un pensiero felice';

  @override
  String get weekSame => 'Come la settimana prima.';

  @override
  String weekMore(String amount, String pillar) {
    return '$amount in più della settimana prima, soprattutto in $pillar.';
  }

  @override
  String weekLess(String amount, String pillar) {
    return '$amount in meno della settimana prima, soprattutto in $pillar.';
  }

  @override
  String get availableLabel => 'Disponibile';

  @override
  String get spentLabel => 'Speso';

  @override
  String spentOf(String month, String spent, String available) {
    return '$month: $spent su $available';
  }

  @override
  String questionsOf(String month) {
    return 'Riflessioni · $month';
  }

  @override
  String sealedSaved(String amount) {
    return 'Sigillato · $amount risparmiati';
  }

  @override
  String resolutionFor(String month, String goal) {
    return 'Proposito per $month: $goal';
  }

  @override
  String get backToJournal => '← Diario';

  @override
  String get reviewKicker => 'FINE MESE';

  @override
  String get reviewTitle => 'Uno sguardo al mese';

  @override
  String get residualNow => 'Residuo attuale';

  @override
  String residualNote(String goal, String left) {
    return 'Entrate meno spese fisse e spese annotate. Tolto l\'obiettivo di $goal, restano $left da spendere.';
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
  String get dayShade => 'Più colore, più Desideri, Cultura e Imprevisti';

  @override
  String get spentInPillars => 'Speso nei pilastri';

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
  String get breathFirst => 'Prima, un respiro';

  @override
  String get followCircle => 'Segui il cerchio per tre respiri, poi scrivi.';

  @override
  String get ready => 'Scrivi ora';

  @override
  String get sound => 'Suono delle campane';

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
      'Annota le spese di oggi, poi scrivi cosa ti ha reso felice.';

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
  String get proverbHint =>
      'Un pensiero per oggi sotto il saluto, con originale e fonte al tocco';

  @override
  String get tapToChange => 'Tocca per cambiare';

  @override
  String get evenings => 'LA SERA';

  @override
  String get thoughtNotice => 'Promemoria serale';

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
  String get meditation => 'Meditazione prima del pensiero';

  @override
  String get meditationHint => 'Tre respiri guidati prima di scrivere';

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
      'Utagawa Hiroshige, Giardino di susini a Kameido (Cento vedute famose di Edo), 1857.\nZheng Xie, Bambù e rocce. Google Art Project.\nZheng Xie, Orchidee. Princeton University Art Museum, 2014-128.\nKatsushika Hokusai, Crisantemi e ape, c. 1832.\n\nOpere in pubblico dominio, riprodotte da Wikimedia Commons.';

  @override
  String get pillarNeeds => 'Necessità';

  @override
  String get pillarNeedsVirtue => 'Il bambù: si piega ma non si spezza';

  @override
  String get pillarWants => 'Desideri';

  @override
  String get pillarWantsVirtue => 'Il susino: fiorisce quando serve gioia';

  @override
  String get pillarCulture => 'Cultura';

  @override
  String get pillarCultureVirtue => 'L\'orchidea: nutre la mente in silenzio';

  @override
  String get pillarUnexpected => 'Imprevisti';

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
  String get japaneseSaying => 'Detto giapponese';

  @override
  String get phrase1 =>
      'Anche la polvere, accumulandosi, diventa una montagna.';

  @override
  String get phrase2 => 'Sapere quando si ha abbastanza.';

  @override
  String get phrase2Source => 'Laozi, Tao Te Ching, 33';

  @override
  String get phrase3 => 'Se hai fretta, prendi la strada lunga.';

  @override
  String get phrase4 => 'Ogni giorno è un buon giorno.';

  @override
  String get phrase4Source => 'Yunmen, dalla Raccolta della Roccia Blu, 6';

  @override
  String get phrase5 =>
      'Anche una pietra si scalda, se ci siedi sopra tre anni.';

  @override
  String get phrase6 => 'In ciò che resta c\'è fortuna.';

  @override
  String get phrase7 => 'Cadi sette volte, rialzati otto.';

  @override
  String get phrase8 =>
      'Si guardano i fiori solo in piena fioritura, e la luna solo senza nubi?';

  @override
  String get phrase8Source => 'Yoshida Kenkô, Tsurezuregusa, 137';

  @override
  String get phrase9 => 'Chi si prepara non ha di che preoccuparsi.';

  @override
  String get phrase10 => 'Anche il cammino più lungo comincia da un passo.';

  @override
  String get phrase11 => 'Ogni incontro accade una volta sola.';

  @override
  String get phrase11Source => 'Ii Naosuke, Chanoyu ichie shû, 1858';

  @override
  String get phrase12 => 'La fortuna entra nella casa dove si ride.';

  @override
  String get phrase13 => 'Il troppo vale quanto il troppo poco.';

  @override
  String get phrase13Source => 'Confucio, Dialoghi, XI';

  @override
  String get phrase14 => 'Domani soffierà il vento di domani.';

  @override
  String get phrase15 => 'Col sole si coltiva, con la pioggia si legge.';

  @override
  String get phrase16 => 'Farlo è più facile che preoccuparsene.';

  @override
  String get phrase17 => 'Ripassare l\'antico per capire il nuovo.';

  @override
  String get phrase17Source => 'Confucio, Dialoghi, II';

  @override
  String get phrase18 => 'Dopo la pioggia la terra si fa più salda.';

  @override
  String get phrase19 => 'Il bastone si prende prima di cadere.';

  @override
  String get phrase20 => 'Non dimenticare lo spirito degli inizi.';

  @override
  String get phrase20Source => 'Zeami, Kakyô';

  @override
  String get phrase21 => 'Dove vivi, lì è la tua capitale.';

  @override
  String get phrase22 => 'Anche le scimmie cadono dagli alberi.';

  @override
  String get phrase23 =>
      'Il fiume scorre senza sosta, e la sua acqua non è mai la stessa.';

  @override
  String get phrase23Source => 'Kamo no Chômei, Hôjôki';

  @override
  String get phrase24 =>
      'A saper aspettare, arriva il tempo buono per salpare.';

  @override
  String get phrase25 => 'Fortuna e sfortuna si scambiano spesso di posto.';

  @override
  String get phrase26 => 'La goccia di pioggia scava la pietra.';

  @override
  String get phrase27 => 'Il bene più alto è come l\'acqua.';

  @override
  String get phrase27Source => 'Laozi, Tao Te Ching, 8';

  @override
  String get phrase28 => 'Da sveglio ti basta mezzo tatami, sdraiato uno.';

  @override
  String get phrase29 => 'Fai tutto ciò che puoi, poi lascia fare al cielo.';

  @override
  String get phrase30 => 'Se un dio ti lascia, un altro ti raccoglie.';

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
  String get step2Title => 'Quattro pilastri, quattro gentiluomini';

  @override
  String get step2Body =>
      'Ogni spesa va in uno di quattro pilastri, ognuno con la sua pianta.';

  @override
  String get step3Title => 'Quattro domande';

  @override
  String get step3Body =>
      'A inizio e fine mese rispondi sempre alle stesse quattro.';

  @override
  String get next => 'Avanti';

  @override
  String get setupFirst =>
      'Rispondi alle prime due domande: ciò che resta è da spendere con consapevolezza.';

  @override
  String introProgress(int current, int total) {
    return 'Passaggio $current di $total';
  }

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
}
