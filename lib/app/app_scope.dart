import 'package:flutter/widgets.dart';

import 'package:kakebo/state/kakebo.dart';

/// Provides one app state to a widget subtree, without a global singleton.
class AppScope extends InheritedNotifier<Kakebo> {
  const AppScope({super.key, required Kakebo super.notifier, required super.child});

  static Kakebo watch(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static Kakebo read(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
