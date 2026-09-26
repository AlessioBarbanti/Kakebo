// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get newItem => 'New item';

  @override
  String get morning => 'Good morning';

  @override
  String get afternoon => 'Good afternoon';

  @override
  String get evening => 'Good evening';

  @override
  String get skip => 'Skip';

  @override
  String get back => 'Back';

  @override
  String get backToLedger => '← Back to the ledger';

  @override
  String get backHome => '← Today';

  @override
  String setupTitle(String month) {
    return 'Plan $month';
  }

  @override
  String get setupIntro =>
      'What comes in, what goes out every month, what to put aside: the rest is yours to spend mindfully.';

  @override
  String get income => 'Income this month';

  @override
  String get incomeHint => 'Salary and other income';

  @override
  String get savingGoal => 'Savings goal';

  @override
  String get savingHint => 'Put it aside right away, before spending';

  @override
  String goalOverMargin(String amount) {
    return 'That is more than is left after fixed costs ($amount): nothing would be left to spend.';
  }

  @override
  String get fixedOverIncome =>
      'Fixed costs are more than your income: nothing is left to save or spend.';

  @override
  String get ruleTitle => 'Starting point: 50 / 30 / 20';

  @override
  String get ruleBody =>
      'Half for needs, about a third for the rest, a fifth for savings. Then kakebo asks you to look at every item.';

  @override
  String get apply => 'Apply';

  @override
  String get applied => 'Applied';

  @override
  String get fixedOverHalf => 'Fixed costs already take more than half';

  @override
  String fixedPart(String amount) {
    return '$amount of it already in fixed costs';
  }

  @override
  String get otherPillars => 'Wants, culture, unexpected';

  @override
  String get shareAmongThree => 'Shared among the three pillars';

  @override
  String get savings => 'Savings';

  @override
  String get becomesGoal => 'Becomes your goal for the month';

  @override
  String get fixedTitle => 'Recurring fixed costs';

  @override
  String get fixedHint =>
      'They repeat every month; change them whenever you like';

  @override
  String get fixedNameHint => 'E.g. rent';

  @override
  String incomeAfterFixed(String fixed, String left) {
    return 'After fixed costs ($fixed), $left is left';
  }

  @override
  String get fixedQuestion => 'What do you pay every month?';

  @override
  String get addFixed => '+ Add a fixed cost';

  @override
  String remove(String name) {
    return 'Remove $name';
  }

  @override
  String get budgetsTitle => 'Pillar budgets';

  @override
  String get budgetsAuto => 'Split automatically from what is left to spend';

  @override
  String get budgetsMine => 'Set by you';

  @override
  String get allAssigned => 'Everything available is assigned.';

  @override
  String toAssign(String amount) {
    return 'Still to assign: $amount';
  }

  @override
  String overBy(String amount) {
    return '$amount over what is available';
  }

  @override
  String get splitAgain => 'Split automatically again';

  @override
  String get mindful => 'To spend mindfully';

  @override
  String perWeek(String amount) {
    return 'about $amount a week';
  }

  @override
  String startMonth(String month) {
    return 'Start $month';
  }

  @override
  String get eveningThought => 'The evening thought';

  @override
  String get happyQuestion => 'What made you happy today?';

  @override
  String get write => 'Write';

  @override
  String leftFor(String month) {
    return 'Left for $month';
  }

  @override
  String get spendToday => 'to spend by today';

  @override
  String spentShare(int pct) {
    return '$pct% of what is available already spent';
  }

  @override
  String get branchTitle => 'The month\'s pace';

  @override
  String get paceExplanation => 'Understanding the pace';

  @override
  String get writeThought => 'Write a thought';

  @override
  String get expenseReflection => 'Looking back on this expense';

  @override
  String get optionalReflection => 'Optional, even just a few words.';

  @override
  String get expenseReflectionPrompt => 'How do you feel about this choice?';

  @override
  String get reflectionPlaceholder => 'Leave a few words, if you like…';

  @override
  String get reflectionInvitation =>
      'Take your time. You can answer just one question, or come back later.';

  @override
  String get reflectionAutosaved =>
      'Your words are saved as you write. You can change them later.';

  @override
  String get monthNumbers => 'The month in numbers';

  @override
  String get monthGood => 'What made you feel good?';

  @override
  String get monthChange => 'What would you do differently?';

  @override
  String get monthIntention =>
      'What small intention would you like to carry into next month?';

  @override
  String get intentionForThisMonth => 'An intention to return to';

  @override
  String get intentionGentle =>
      'You wrote this last month. You can carry it with you, or choose a different path.';

  @override
  String get weekReflection => 'A moment to reflect';

  @override
  String get reflectionMemory => 'Words from the month';

  @override
  String get moreMemories => 'Show earlier memories';

  @override
  String get weekReflectionPrompt =>
      'Is there a choice from this week you would like to make again?';

  @override
  String get branchRule =>
      'A flower opens for each tenth of the month gone by, as long as spending keeps pace with what is available. It measures pace, not money put aside.';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get addExpense => 'Add expense';

  @override
  String get emptyLedger =>
      'The ledger is still empty. Write down the month\'s first expense: an amount and a pillar are enough.';

  @override
  String get quietToday => 'No spending today. A light day.';

  @override
  String get newExpense => 'New expense';

  @override
  String get editExpense => 'Edit expense';

  @override
  String get cancel => 'Cancel';

  @override
  String get notePlaceholder => 'What for? e.g. groceries, cinema, pharmacy';

  @override
  String suggested(String pillar) {
    return 'Pillar suggested by the note: $pillar';
  }

  @override
  String get save => 'Save';

  @override
  String get deleteExpense => 'Delete expense';

  @override
  String get changeDate => 'Change the date';

  @override
  String get expenseDate => 'Date of the expense';

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get undo => 'Undo';

  @override
  String get erase => 'Delete';

  @override
  String get settings => 'Settings';

  @override
  String get ledgerKicker => 'LEDGER';

  @override
  String get ledgerTitle => 'Where it went';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String ofAvailable(String amount) {
    return 'of $amount available';
  }

  @override
  String leftOf(String left, String budget) {
    return '$left left of $budget';
  }

  @override
  String get noneInPillar => 'No expenses in this pillar.';

  @override
  String get journalKicker => 'JOURNAL';

  @override
  String get journalTitle => 'Two moments';

  @override
  String get journalIntro =>
      'One for the evening, one for the month. Every Sunday the journal gathers the week by itself.';

  @override
  String everyDayAt(String time) {
    return 'Every day at $time';
  }

  @override
  String get written => 'Written';

  @override
  String get toWrite => 'To write';

  @override
  String get eveningNow => 'It\'s evening: you can write it now.';

  @override
  String opensAt(String time) {
    return 'Opens tonight at $time.';
  }

  @override
  String get theMonth => 'The month';

  @override
  String questionsFrom(String date) {
    return 'Review the month · ends $date';
  }

  @override
  String get open => 'Open';

  @override
  String get questionsHint =>
      'What felt good, what you would change, a small intention for the future.';

  @override
  String get timeline => 'Timeline';

  @override
  String week(String span) {
    return 'The week · $span';
  }

  @override
  String get weekNoSpending => 'A week without spending.';

  @override
  String get backToToday => 'Back to Today';

  @override
  String get choosePillar => 'Choose a pillar';

  @override
  String get reminderHint => 'Today\'s expenses and one happy thought';

  @override
  String get weekSame => 'Much like the week before.';

  @override
  String weekMore(String amount, String pillar) {
    return '$amount more than the week before, mostly $pillar.';
  }

  @override
  String weekLess(String amount, String pillar) {
    return '$amount less than the week before, mostly $pillar.';
  }

  @override
  String get availableLabel => 'Available';

  @override
  String get spentLabel => 'Spent';

  @override
  String spentOf(String month, String spent, String available) {
    return '$month: $spent of $available';
  }

  @override
  String questionsOf(String month) {
    return 'Reflections · $month';
  }

  @override
  String sealedSaved(String amount) {
    return 'Sealed · $amount saved';
  }

  @override
  String resolutionFor(String month, String goal) {
    return 'Resolution for $month: $goal';
  }

  @override
  String get backToJournal => '← Journal';

  @override
  String get reviewKicker => 'END OF MONTH';

  @override
  String get reviewTitle => 'Looking back on the month';

  @override
  String get residualNow => 'Current balance';

  @override
  String residualNote(String goal, String left) {
    return 'Income minus fixed costs and the expenses you wrote down. Take away the $goal goal and $left is left to spend.';
  }

  @override
  String question(int n) {
    return 'Question $n';
  }

  @override
  String goalFor(String month) {
    return 'Your goal for $month';
  }

  @override
  String get acrossPillars => 'Across the four pillars';

  @override
  String plan(String month) {
    return 'Plan $month →';
  }

  @override
  String sealMonth(String month) {
    return 'Close $month with the seal';
  }

  @override
  String sealsFrom(String month, String date) {
    return 'You can seal $month from $date, once it is over.';
  }

  @override
  String sealsItself(String date) {
    return 'If you don\'t, it seals itself on $date, with its figures.';
  }

  @override
  String closeBy(String date) {
    return 'To close by $date';
  }

  @override
  String get toClose => 'To close';

  @override
  String monthOver(String month) {
    return '$month is over: look back on it and seal it.';
  }

  @override
  String get calendarKicker => 'CALENDAR';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get quietDay => 'A quiet day. No expenses written down.';

  @override
  String get dayShade => 'Deeper: more wants, culture and the unexpected';

  @override
  String get spentInPillars => 'Spent in the pillars';

  @override
  String get savedLabel => 'Saved';

  @override
  String get goal => 'Goal';

  @override
  String get monthAhead => 'A month still to live.';

  @override
  String get monthEmpty => 'No expenses written down this month.';

  @override
  String get monthNow =>
      'Month in progress: the seal comes with the end-of-month review.';

  @override
  String get monthReached =>
      'Goal reached: the branch has bloomed and the month bears the seal.';

  @override
  String missedBy(String amount) {
    return 'Goal missed by $amount.';
  }

  @override
  String get savedGoodnight => 'Saved in your journal. Good night.';

  @override
  String get edit => 'Edit';

  @override
  String get breathFirst => 'First, a breath';

  @override
  String get followCircle => 'Follow the circle for three breaths, then write.';

  @override
  String get ready => 'Write now';

  @override
  String get sound => 'Bowl sound';

  @override
  String get smallThing => 'Even something small. Take a breath, then write.';

  @override
  String get todayHint => 'Today…';

  @override
  String get later => 'Later';

  @override
  String get keepThought => 'Keep the thought';

  @override
  String get close => 'Close';

  @override
  String get breatheIn => 'Breathe in';

  @override
  String get breatheOut => 'Breathe out';

  @override
  String get channel => 'Evening';

  @override
  String get channelInfo => 'The evening thought and the expense note';

  @override
  String get noteTitle => 'The evening note';

  @override
  String get noteBody =>
      'Write down today\'s expenses, then what made you happy.';

  @override
  String get ledgerGroup => 'LEDGER';

  @override
  String get monthStartLabel => 'Start of the month';

  @override
  String get monthStartHint => 'For example, your payday';

  @override
  String startDay(int day) {
    return 'Day $day';
  }

  @override
  String get monthStartDialog => 'The month starts on day';

  @override
  String get incomeFixed => 'Income and fixed costs';

  @override
  String get incomeFixedHint => 'Income, recurring costs, savings and budgets';

  @override
  String fixedValue(String amount) {
    return '$amount fixed ›';
  }

  @override
  String get rhythm => 'RHYTHM';

  @override
  String get weekly => 'Sunday summary';

  @override
  String get weeklyHint => 'The week gathered in the journal, nothing to write';

  @override
  String get proverb => 'Saying of the day';

  @override
  String get proverbHint =>
      'A thought for today under the greeting; tap for the original and its source';

  @override
  String get tapToChange => 'Tap to change';

  @override
  String get evenings => 'EVENINGS';

  @override
  String get thoughtNotice => 'Evening reminder';

  @override
  String get time => 'Time';

  @override
  String get thoughtTimeDialog => 'Time of the evening thought';

  @override
  String get precise => 'Exact time';

  @override
  String get preciseOn => 'Notifications arrive on the minute';

  @override
  String get preciseOff =>
      'Without it, Android may delay them by up to an hour';

  @override
  String get active => 'On';

  @override
  String get activate => 'Turn on ›';

  @override
  String get meditation => 'Meditation before the thought';

  @override
  String get meditationHint => 'Three guided breaths before writing';

  @override
  String get writeToday => 'Write today\'s thought';

  @override
  String get writeTodayHint => 'A screen without distractions';

  @override
  String get data => 'DATA';

  @override
  String get exportLedger => 'Export ledger';

  @override
  String get exportHint => 'A CSV file to open in a spreadsheet';

  @override
  String get ledgerSaved => 'Ledger saved';

  @override
  String get backupSave => 'Save a backup';

  @override
  String get backupHint => 'All your data in one file, also for a new phone';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String get restore => 'Restore a backup';

  @override
  String get restoreHint => 'Replaces the current data with the file';

  @override
  String get restoreAsk => 'Restore the backup?';

  @override
  String get restoreWarn => 'The current data will be replaced by the file.';

  @override
  String get restoreYes => 'Restore';

  @override
  String get restored => 'Backup restored';

  @override
  String get notABackup => 'This file is not a Kakebo backup';

  @override
  String get wipe => 'Delete all data';

  @override
  String get wipeHint =>
      'Expenses, thoughts and settings. This cannot be undone';

  @override
  String get wipeAsk => 'Delete everything?';

  @override
  String get wipeWarn =>
      'Expenses, fixed costs, thoughts, seals and settings will be removed from this phone. To keep them, save a backup first.';

  @override
  String get other => 'OTHER';

  @override
  String get replayIntro => 'See the introduction again';

  @override
  String get replayIntroHint => 'The pillars and the questions';

  @override
  String get licenses => 'Licenses';

  @override
  String get licensesHint => 'Fonts, prints and libraries used';

  @override
  String get prints => 'Prints (public domain, Wikimedia Commons)';

  @override
  String get printsList =>
      'Utagawa Hiroshige, Plum Park in Kameido (One Hundred Famous Views of Edo), 1857.\nZheng Xie, Bamboo and Rocks. Google Art Project.\nZheng Xie, Orchids. Princeton University Art Museum, 2014-128.\nKatsushika Hokusai, Chrysanthemums and Bee, c. 1832.\n\nPublic domain works, reproduced from Wikimedia Commons.';

  @override
  String get pillarNeeds => 'Needs';

  @override
  String get pillarNeedsVirtue => 'Bamboo: it bends but does not break';

  @override
  String get pillarWants => 'Wants';

  @override
  String get pillarWantsVirtue => 'Plum blossom: it flowers when joy is needed';

  @override
  String get pillarCulture => 'Culture';

  @override
  String get pillarCultureVirtue => 'Orchid: it feeds the mind in silence';

  @override
  String get pillarUnexpected => 'Unexpected';

  @override
  String get pillarUnexpectedVirtue =>
      'Chrysanthemum: it stands up to sudden cold';

  @override
  String get seasonWinter => 'Winter';

  @override
  String get seasonWinterPlant => 'Nandina';

  @override
  String get seasonSpring => 'Spring';

  @override
  String get seasonSpringPlant => 'Cherry blossom';

  @override
  String get seasonSummer => 'Summer';

  @override
  String get seasonSummerPlant => 'Goldfish';

  @override
  String get seasonAutumn => 'Autumn';

  @override
  String get seasonAutumnPlant => 'Full moon';

  @override
  String get japaneseSaying => 'Japanese saying';

  @override
  String get phrase1 => 'Even dust, piled up, becomes a mountain.';

  @override
  String get phrase2 => 'Know when you have enough.';

  @override
  String get phrase2Source => 'Laozi, Tao Te Ching, 33';

  @override
  String get phrase3 => 'If you are in a hurry, take the long way round.';

  @override
  String get phrase4 => 'Every day is a good day.';

  @override
  String get phrase4Source => 'Yunmen, from the Blue Cliff Record, 6';

  @override
  String get phrase5 =>
      'Even a stone grows warm if you sit on it for three years.';

  @override
  String get phrase6 => 'There is luck in what is left.';

  @override
  String get phrase7 => 'Fall seven times, get up eight.';

  @override
  String get phrase8 =>
      'Are blossoms only for full bloom, and the moon only for a cloudless sky?';

  @override
  String get phrase8Source => 'Yoshida Kenkô, Tsurezuregusa, 137';

  @override
  String get phrase9 => 'Be prepared and there is nothing to worry about.';

  @override
  String get phrase10 => 'Even the longest road begins with one step.';

  @override
  String get phrase11 => 'Every meeting happens only once.';

  @override
  String get phrase11Source => 'Ii Naosuke, Chanoyu ichie shû, 1858';

  @override
  String get phrase12 => 'Good fortune comes to the house that laughs.';

  @override
  String get phrase13 => 'Too much is as bad as too little.';

  @override
  String get phrase13Source => 'Confucius, Analects, XI';

  @override
  String get phrase14 => 'Tomorrow\'s wind will blow tomorrow.';

  @override
  String get phrase15 => 'Farm when it is sunny, read when it rains.';

  @override
  String get phrase16 => 'Doing it is easier than worrying about it.';

  @override
  String get phrase17 => 'Revisit the old to understand the new.';

  @override
  String get phrase17Source => 'Confucius, Analects, II';

  @override
  String get phrase18 => 'After the rain, the ground grows firmer.';

  @override
  String get phrase19 => 'Take the walking stick before you fall.';

  @override
  String get phrase20 => 'Never forget the spirit of beginnings.';

  @override
  String get phrase20Source => 'Zeami, Kakyô';

  @override
  String get phrase21 => 'Wherever you live becomes your capital.';

  @override
  String get phrase22 => 'Even monkeys fall from trees.';

  @override
  String get phrase23 =>
      'The river flows on without end, and its water is never the same.';

  @override
  String get phrase23Source => 'Kamo no Chômei, Hôjôki';

  @override
  String get phrase24 => 'Wait, and the weather turns fair for sailing.';

  @override
  String get phrase25 => 'Good and bad fortune often trade places.';

  @override
  String get phrase26 => 'Dripping rain wears through stone.';

  @override
  String get phrase27 => 'The highest good is like water.';

  @override
  String get phrase27Source => 'Laozi, Tao Te Ching, 8';

  @override
  String get phrase28 => 'Awake you need half a mat, asleep a whole one.';

  @override
  String get phrase29 => 'Do all you can, then leave the rest to heaven.';

  @override
  String get phrase30 => 'If one god turns away, another takes you in.';

  @override
  String get defaultFixed1 => 'Rent';

  @override
  String get defaultFixed2 => 'Electricity and gas';

  @override
  String get defaultFixed3 => 'Internet and phone';

  @override
  String get defaultFixed4 => 'Subscriptions';

  @override
  String get defaultFixed5 => 'Insurance';

  @override
  String get csvDate => 'date';

  @override
  String get csvNote => 'note';

  @override
  String get csvAmount => 'amount';

  @override
  String get csvPillar => 'pillar';

  @override
  String get step1Title => 'A ledger for the home';

  @override
  String get step1Body =>
      'Born in Japan in 1904: you write down every expense, pause for a moment, and see where the money goes.';

  @override
  String get step2Title => 'Four pillars, four gentlemen';

  @override
  String get step2Body =>
      'Every expense goes into one of four pillars, each with its own plant.';

  @override
  String get step3Title => 'Four questions';

  @override
  String get step3Body =>
      'At the start and end of every month you answer the same four.';

  @override
  String get next => 'Next';

  @override
  String get scrollMore => 'Scroll to continue';

  @override
  String get setupFirst =>
      'Three answers and the month is ready: what is left is yours to spend mindfully.';

  @override
  String introProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get fourQuestion1 => 'How much comes in this month?';

  @override
  String get fourQuestion2 => 'How much would you like to save?';

  @override
  String get fourQuestion3 => 'How much are you spending?';

  @override
  String get fourQuestion4 => 'How can you improve?';

  @override
  String get tabToday => 'Today';

  @override
  String get tabLedger => 'Ledger';

  @override
  String get tabJournal => 'Journal';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String perDay(String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'about $amount a day for the next $days days',
      one: 'about $amount a day for tomorrow',
    );
    return '$_temp0';
  }

  @override
  String flowers(int n) {
    return '$n of 10 flowers';
  }
}
