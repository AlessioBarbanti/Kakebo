# Bakes the runtime artwork in assets/art from the masters in assets/src/botanical (see PROMPTS.md there)
# and assets/src/prints:
#   pip install pillow
#   python tool/art.py
from PIL import Image, ImageChops, ImageEnhance, ImageStat

src, prints, out = 'assets/src/botanical/', 'assets/src/prints/', 'assets/art/'

# Intro prints: Hiroshige, One Hundred Famous Views of Edo (1857), public domain, from Wikimedia Commons
# (suruga: "100 views edo 008.jpg", kyobashi: "100 views edo 076.jpg", mama: "100 views edo 094.jpg";
# plum: Plum Park in Kameido, already trimmed).
# Cropped inside the printed border; the brighter scans are desaturated to one level so they read as a set.
for name, box in [('suruga', (28, 62, 740, 1168)), ('plum', (16, 16, 749, 1128)), ('kyobashi', (50, 90, 742, 1156)),
                  ('mama', (31, 65, 752, 1151))]:
    im = Image.open(prints + name + '.jpg').convert('RGB').crop(box)
    saturation = ImageStat.Stat(im.convert('HSV')).mean[1]
    ImageEnhance.Color(im).enhance(min(1, 46 / saturation)).save(out + 'print_' + name + '.webp', quality=85, method=6)
    print(out + 'print_' + name + '.webp')

# Pillar sprigs: shown at 56–96 px, so 384 px covers a 4× screen; WebP keeps the real alpha.
for master, name in [('bamboo_needs', 'sprig_bamboo'), ('plum_wants', 'sprig_plum'),
                     ('orchid_culture', 'sprig_orchid'), ('chrysanthemum_unexpected', 'sprig_chrys')]:
    Image.open(src + master + '.png').resize((384, 384), Image.LANCZOS).save(out + name + '.webp', quality=85, method=6)

# Background: full size (it covers the screen), paper lifted by (3, 4, 6) so it matches the app's bg (243, 249, 241)
# and fading it in or out never shifts the tone.
paper = Image.open(src + 'ink_background.png').convert('RGB')
ImageChops.add(paper, Image.new('RGB', paper.size, (3, 4, 6))).save(out + 'paper.webp', quality=82, method=6)

for name in ['sprig_bamboo', 'sprig_plum', 'sprig_orchid', 'sprig_chrys', 'paper']:
    print(out + name + '.webp')
