# Bakes the runtime artwork in assets/art from the masters in assets/src/botanical (see PROMPTS.md there):
#   pip install pillow
#   python tool/art.py
from PIL import Image, ImageChops

src, out = 'assets/src/botanical/', 'assets/art/'

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
