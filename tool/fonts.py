# Rebuilds the font subsets in assets/fonts from the full Google Fonts files (OFL, no reserved names).
# Run again whenever new Japanese text (or a new language) appears in lib/ or lib/l10n/, or those characters fall back to the system font.
#   pip install fonttools
#   python tool/fonts.py path/to/full/fonts   (ShipporiMincho-*.ttf, ZenKakuGothicNew-*.ttf from github.com/google/fonts)
import glob, os, sys
from fontTools import subset

src = sys.argv[1]
texts = glob.glob('lib/**/*.dart', recursive=True) + glob.glob('lib/l10n/*.arb')  # the translations live in the ARB files
used = {c for f in texts for c in open(f, encoding='utf-8').read() if ord(c) > 0x7e}
latin = [*range(0x20, 0x7f), *range(0xa0, 0x180), *range(0x2010, 0x2028), *range(0x2030, 0x203b), 0x20ac]  # incl. accents, “” … – € for notes

for name in ['ShipporiMincho-Medium', 'ShipporiMincho-SemiBold', 'ShipporiMincho-Bold',
             'ZenKakuGothicNew-Regular', 'ZenKakuGothicNew-Medium', 'ZenKakuGothicNew-Bold']:
    opts = subset.Options()
    opts.hinting = False
    font = subset.load_font(os.path.join(src, name + '.ttf'), opts)
    s = subset.Subsetter(opts)
    s.populate(unicodes=latin + [ord(c) for c in used])
    s.subset(font)
    out = f'assets/fonts/{name}.ttf'
    subset.save_font(font, out, opts)
    print(out, os.path.getsize(out) // 1024, 'KB')
