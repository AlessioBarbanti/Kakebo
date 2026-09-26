import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:kakebo/services/storage.dart';
import 'package:kakebo/state/kakebo.dart';

class MemoryStorage implements KakeboStorage {
  String? snapshot;
  int writes = 0;

  @override
  Future<Map<String, dynamic>?> load() async => snapshot == null ? null : jsonDecode(snapshot!) as Map<String, dynamic>;

  @override
  Future<void> save(Map<String, Object> data) async {
    snapshot = jsonEncode(data);
    writes++;
  }
}

void main() {
  test('loading and refreshing do not write; mutations survive a new instance', () async {
    final storage = MemoryStorage();
    final first = await Kakebo.load(storage: storage);
    expect(first.screen, 'onboarding');
    expect(storage.writes, 0);

    first.update(() {
      first.onboarded = true;
      first.monthStart = 27;
    });
    first.addEntry(12.5, 'Spesa', 'needs');
    expect(storage.writes, 2);

    first.editEntry(first.entries.single, 12.5, 'Spesa', 'needs', reflection: 'Una scelta utile');
    first.update(() {
      first.reflections['2026-09'] = {'good': 'Tempo per me'};
      first.weeklyReflections['2026-09-20'] = 'Il pranzo insieme';
      first.improve['2026-09'] = 'Prendermi tempo';
    });

    first.refresh();
    expect(storage.writes, 4);
    final second = await Kakebo.load(storage: storage);
    expect(second.screen, 'home');
    expect(second.monthStart, 27);
    expect(second.entries.single.note, 'Spesa');
    expect(second.entries.single.amt, 12.5);
    expect(second.entries.single.reflection, 'Una scelta utile');
    expect(second.reflections['2026-09']?['good'], 'Tempo per me');
    expect(second.weeklyReflections['2026-09-20'], 'Il pranzo insieme');
    expect(second.improve['2026-09'], 'Prendermi tempo');
    expect(storage.writes, 4);
    first.dispose();
    second.dispose();
  });

  test('invalid backup cannot overwrite persisted data', () async {
    final storage = MemoryStorage();
    final state = await Kakebo.load(storage: storage);
    state.addEntry(4, 'Pane', 'needs');
    final before = storage.snapshot;
    expect(state.restore('{"app":"kakebo","onboarded":true}'), isFalse);
    expect(storage.snapshot, before);
    expect(state.entries.single.note, 'Pane');
    expect(storage.writes, 1);
    state.dispose();
  });
}
