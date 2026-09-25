class Pillar {
  const Pillar(this.key, this.share);
  final String key;
  final double share;
}

const pillars = {
  'needs': Pillar('needs', 600 / 1350),
  'wants': Pillar('wants', 300 / 1350),
  'culture': Pillar('culture', 200 / 1350),
  'unexpected': Pillar('unexpected', 250 / 1350),
};
