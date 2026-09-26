import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/app/app_scope.dart';
import 'package:kakebo/features/expenses/add_sheet.dart';
import 'package:kakebo/l10n/formatters.dart';
import 'package:kakebo/l10n/localization.dart';
import 'package:kakebo/state/kakebo.dart';

void main() {
  setUpAll(initL10n);
  setUp(() => setLocale(const Locale('it', 'IT')));

  testWidgets('modal uses the nearest scope even when it is below the navigator', (tester) async {
    final outer = Kakebo(), inner = Kakebo();
    await tester.pumpWidget(
      AppScope(
        notifier: outer,
        child: MaterialApp(
          home: AppScope(
            notifier: inner,
            child: Scaffold(
              body: Builder(
                builder: (context) => TextButton(onPressed: () => openAdd(context), child: const Text('open')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5'));
    await tester.tap(find.text('Cultura')); // a new expense starts with no pillar
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(inner.entries.single.amt, 5);
    expect(outer.entries, isEmpty);
    await tester.pumpWidget(const SizedBox());
    inner.dispose();
    outer.dispose();
  });

  testWidgets('consumers follow a replacement scope and stop observing the old state', (tester) async {
    final first = Kakebo()..income = 2800, second = Kakebo()..income = 4000;
    Widget tree(Kakebo state) => AppScope(
      notifier: state,
      child: MaterialApp(home: Builder(builder: (context) => Text('${AppScope.watch(context).income}'))),
    );
    await tester.pumpWidget(tree(first));
    expect(find.text('2800.0'), findsOneWidget);
    first.update(() => first.income = 3000);
    await tester.pump();
    expect(find.text('3000.0'), findsOneWidget);
    await tester.pumpWidget(tree(second));
    first.update(() => first.income = 9000);
    await tester.pump();
    expect(find.text('4000.0'), findsOneWidget);
    expect(find.text('9000.0'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    first.dispose();
    second.dispose();
  });
}
