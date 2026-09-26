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

Screenshot di tutte le schermate, parte superiore e (se scorre) inferiore, in `screenshots/<schermata>/` (formato Pixel 9, dati di esempio, italiano; la cartella viene svuotata a ogni esecuzione e non è in git):

```sh
flutter test tool/screenshots_test.dart
```

Per aggiungere una schermata o uno stato, aggiungi una riga alla lista `_shots` in cima al file.

## Lingue

L'app segue la lingua del telefono: italiano, altrimenti inglese. Valuta, numeri e date seguono il paese del telefono (it_IT → "1.650 €", en_GB → "£1,650"), l'orario le sue 24 ore o AM/PM.

I testi sono in `lib/l10n/app_it.arb` (il riferimento) e `lib/l10n/app_en.arb`: file JSON con un identificativo per ogni frase, per esempio `"leftFor": "Ti restano per {month}"`. A ogni build Flutter genera i file in `lib/l10n/generated/` (a mano: `flutter gen-l10n`), e nel codice si scrive `tr.leftFor(mese)`. I file generati non si modificano a mano.

Per aggiungere una lingua, per esempio il francese:

1. copia `app_it.arb` in `app_fr.arb`, metti `"@@locale": "fr"` e traduci i valori (non le chiavi e non i `{segnaposto}`);
2. aggiungi `fr` alla scelta della lingua in `setLocale` (`lib/l10n/localization.dart`) e alla configurazione delle lingue in `lib/app/kakebo_app.dart` (`supportedLocales` e `localeResolutionCallback`);
3. rigenera i font con `python tool/fonts.py <cartella dei font completi>`, se la lingua usa caratteri nuovi.

Le frasi non ancora tradotte finiscono in `build/untranslated-messages.json`.

## Struttura

- `lib/main.dart`: punto d'ingresso; delega l'avvio a `app/bootstrap.dart`
- `lib/app/`: inizializzazione, `MaterialApp`, navigazione, sfondo e `AppScope`
- `lib/model/`: spese, spese fisse, periodi e pilastri; codice Dart senza dipendenze da Flutter o traduzioni
- `lib/state/kakebo.dart`: stato `ChangeNotifier`, calcoli dei budget e operazioni dell'app
- `lib/services/`: persistenza con shared_preferences, formati backup/CSV, dialoghi per i file e notifiche
- `lib/features/`: schermate raggruppate in `home`, `expenses`, `journal`, `calendar`, `onboarding`, `month_setup` e `settings`; aggiunta/modifica spesa vive in `expenses/add_sheet.dart`
- `lib/shared/`: `theme` per colori, tipografia e presentazione dei pilastri; `widgets` per i controlli comuni; `illustrations` per ramo, sigillo ed ensō; `animations` per transizioni e respiro
- `lib/l10n/`: sorgenti ARB, `generated/` per l'output Flutter, `localization.dart` per lingua e testi, `formatters.dart` per date e importi
- `test/`: test suddivisi per modelli, stato, servizi, funzionalità, localizzazione e componenti condivisi
- `assets/art/`: generata da `python tool/art.py`. Stampe dell'introduzione (`print_*.webp`: Hiroshige, *Cento vedute di Edo*, pubblico dominio da Wikimedia Commons) ritagliate e portate alla stessa saturazione dai master in `assets/src/prints/`; rametti dei pilastri (`sprig_*.webp`) e fondo a inchiostro (`paper.webp`) dai master in `assets/src/botanical/` (prompt in `PROMPTS.md`)
- `assets/sounds/`: campane tibetane sintetizzate da `dart run tool/bowl.dart` (note, volume e durata sono in cima al file)
- `assets/fonts/`: Shippori Mincho e Zen Kaku Gothic New (OFL), ridotti ai soli caratteri usati nel codice e nelle traduzioni. Se aggiungi testo giapponese o una lingua nuova, rigenerali con `python tool/fonts.py <cartella dei font completi>`
- `assets/icon/`: icona dipinta (`source.png`); `dart run tool/icon.dart && dart run flutter_launcher_icons` crea le icone Android e quella delle notifiche

Le schermate leggono lo stato con `AppScope.watch(context)` durante il build e con `AppScope.read(context)` nei callback. Non esiste uno stato globale `app`. Le finestre modali ricevono lo scope della schermata che le apre. I modelli non importano la UI: colori e nomi tradotti dei pilastri sono estensioni di presentazione in `shared/theme/`.

`Kakebo.load(storage: ...)` accetta un `KakeboStorage` sostituibile nei test; nell'app usa `PreferencesStorage`. La chiave di salvataggio `kakebo`, lo schema JSON e il formato dei backup restano compatibili con i dati esistenti.

Verifica delle modifiche:

```sh
flutter gen-l10n
flutter analyze
flutter test
```

Per misurare la fluidità su un telefono: `flutter run --release --dart-define=FRAMES=true`, poi `adb logcat -s flutter` mostra i tempi di ogni fotogramma (build, raster, totale in µs).
