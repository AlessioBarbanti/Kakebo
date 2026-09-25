# Kakebo

Il registro di casa giapponese, per Android (Flutter). Implementa il design *Kakebo Mobile v3*.

## Avvio

```sh
flutter run                      # telefono collegato o emulatore
flutter build apk --release      # APK in build/app/outputs/flutter-apk/app-release.apk
flutter test
```

Dati di esempio del design, con data fissa (utile per provare tutte le schermate):

```sh
flutter run --dart-define=DEMO=true --dart-define=TODAY=2026-09-24T21:30
```

## Lingue

L'app segue la lingua del telefono: italiano, altrimenti inglese. Valuta, numeri e date seguono il paese del telefono (it_IT → "1.650 €", en_GB → "£1,650"), l'orario le sue 24 ore o AM/PM.

I testi sono in `lib/l10n/app_it.arb` (il riferimento) e `lib/l10n/app_en.arb`: file JSON con un identificativo per ogni frase, per esempio `"leftFor": "Ti restano per {month}"`. A ogni build Flutter ne genera `lib/l10n/app_localizations.dart` (a mano: `flutter gen-l10n`), e nel codice si scrive `tr.leftFor(mese)`.

Per aggiungere una lingua, per esempio il francese:

1. copia `app_it.arb` in `app_fr.arb`, metti `"@@locale": "fr"` e traduci i valori (non le chiavi e non i `{segnaposto}`);
2. aggiungi `fr` alla scelta della lingua in `setLocale` (`lib/l10n.dart`) e a `supportedLocales` (`lib/main.dart`);
3. rigenera i font con `python tool/fonts.py <cartella dei font completi>`, se la lingua usa caratteri nuovi.

Le frasi non ancora tradotte finiscono in `build/untranslated-messages.json`.

## Struttura

- `lib/kakebo.dart`: dati, budget e periodo (il mese può partire dal giorno dello stipendio), salvataggio (shared_preferences)
- `lib/l10n.dart`: lingua, formati di valuta e date; `lib/l10n/`: le traduzioni
- `lib/ui.dart`: stili, widget condivisi (ramo, sigillo, ensō, respiro)
- `lib/intro.dart`: introduzione e inizio mese
- `lib/shell.dart`: intestazione, schede con swipe, impostazioni
- `lib/home.dart`, `ledger.dart`, `journal.dart`, `calendar.dart`, `thought.dart`: le schermate
- `lib/notify.dart`: notifiche della sera
- `assets/art/`: stampe di pubblico dominio (Wikimedia Commons)
- `assets/sounds/`: campane tibetane sintetizzate da `dart run tool/bowl.dart` (note, volume e durata sono in cima al file)
- `assets/fonts/`: Shippori Mincho e Zen Kaku Gothic New (OFL), ridotti ai soli caratteri usati nel codice e nelle traduzioni. Se aggiungi testo giapponese o una lingua nuova, rigenerali con `python tool/fonts.py <cartella dei font completi>`
- `assets/art/ink_plum_wash.png`: lo sfondo a inchiostro già elaborato da `dart run tool/wash.dart` (sorgente in `assets/src/`)
- `assets/icon/`: icona dipinta (`source.png`); `dart run tool/icon.dart && dart run flutter_launcher_icons` crea le icone Android e quella delle notifiche

Per misurare la fluidità su un telefono: `flutter run --release --dart-define=FRAMES=true`, poi `adb logcat -s flutter` mostra i tempi di ogni fotogramma (build, raster, totale in µs).
