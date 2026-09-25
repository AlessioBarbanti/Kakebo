const _kw = {
  // Italian and English stems, so a note in either language works on any phone.
  'needs': [
    'spes',
    'supermerc',
    'affitt',
    'bollett',
    'farmac',
    'treno',
    'benzin',
    'medic',
    'bus',
    'riso',
    'verdur',
    'grocer',
    'rent',
    'bill',
    'pharma',
    'train',
    'fuel',
    'doctor',
    'vegetab',
  ],
  'wants': [
    'cena',
    'ristor',
    'bar',
    'caff',
    'vestit',
    'regal',
    'fiori',
    'aperitiv',
    'pizza',
    'dinner',
    'restaurant',
    'coffee',
    'cloth',
    'gift',
    'flower',
    'drink',
  ],
  'culture': ['libr', 'cinema', 'muse', 'concert', 'teatr', 'corso', 'mostra', 'quadern', 'book', 'movie', 'theat', 'course', 'exhibit', 'notebook'],
  'unexpected': ['ripara', 'multa', 'dentist', 'guast', 'veterin', 'rott', 'repair', 'broke', 'fix'],
};

/// Pillar guessed from the note: a word that starts like one of the pillar's stems ("spesa" → spes), or null.
String? suggest(String t) {
  final words = t.toLowerCase().split(RegExp(r'[^\p{L}]+', unicode: true));
  for (final e in _kw.entries) {
    if (words.any((w) => e.value.any(w.startsWith))) return e.key;
  }
  return null;
}
