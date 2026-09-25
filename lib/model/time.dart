/// "21:30" → (21, 30)
(int, int) hm(String t) {
  final [h, m] = t.split(':').map(int.parse).toList();
  return (h, m);
}
