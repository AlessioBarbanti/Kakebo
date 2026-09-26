# Contribuire a Kakebo

Come è fatto il progetto e come si lavora sul codice. Per cos'è l'app e come installarla, vedi il [README](README.md).

## Avvio

Servono Flutter 3.47 (canale stable) e l'Android SDK.

```sh
flutter run                       # telefono collegato o emulatore
flutter build apk --release       # APK in build/app/outputs/flutter-apk/app-release.apk
flutter build appbundle --release # per Google Play, in build/app/outputs/bundle/release/app-release.aab
flutter test
```

Le build di release sono firmate con la chiave di caricamento per Google Play se `android/key.properties` esiste (vedi [Rilascio](#rilascio)), altrimenti con la chiave di debug: vanno bene per provare sul telefono, ma il Play Store non le accetta.

Dati di esempio, con data fissa (utile per provare tutte le schermate):

```sh
flutter run --dart-define=DEMO=true --dart-define=TODAY=2026-09-24T21:30
```

Screenshot di tutte le schermate, parte superiore e (se scorre) inferiore, in `screenshots/<schermata>/` (formato Pixel 9, dati di esempio, italiano; la cartella viene svuotata a ogni esecuzione e non è in git):

```sh
flutter test tool/screenshots_test.dart
```

Per aggiungere una schermata o uno stato, aggiungi una riga alla lista `_shots` in cima al file. La striscia di schermate del README (`docs/readme/schermate.webp`) è composta da cinque di questi screenshot: rifalla quando le schermate cambiano molto.

Per misurare la fluidità su un telefono: `flutter run --release --dart-define=FRAMES=true`, poi `adb logcat -s flutter` mostra i tempi di ogni fotogramma (build, raster, totale in µs).

## Prima di un commit

```sh
flutter gen-l10n   # se hai cambiato i file .arb
flutter analyze
flutter test
dart format -l 160 <file modificati>
```

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
- `tool/`: strumenti per screenshot, immagini, icona, font e suoni (vedi sotto)

Le schermate leggono lo stato con `AppScope.watch(context)` durante il build e con `AppScope.read(context)` nei callback. Non esiste uno stato globale `app`. Le finestre modali ricevono lo scope della schermata che le apre. I modelli non importano la UI: colori e nomi tradotti dei pilastri sono estensioni di presentazione in `shared/theme/`.

`Kakebo.load(storage: ...)` accetta un `KakeboStorage` sostituibile nei test; nell'app usa `PreferencesStorage`. La chiave di salvataggio `kakebo`, lo schema JSON e il formato dei backup restano compatibili con i dati esistenti.

## Immagini, icona, suoni e caratteri

- `assets/art/`: generata da `python tool/art.py`. Stampe dell'introduzione (`print_*.webp`: Hiroshige, *Cento vedute di Edo*, pubblico dominio da Wikimedia Commons) ritagliate e portate alla stessa saturazione dai master in `assets/src/prints/`; rametti dei pilastri (`sprig_*.webp`) e fondo a inchiostro (`paper.webp`) dai master in `assets/src/botanical/` (prompt in `PROMPTS.md`). Si modificano i master e si rigenera; i WebP non si toccano a mano.
- `assets/icon/`: icona dipinta (`source.png`). `dart run tool/icon.dart && dart run flutter_launcher_icons` crea l'icona in negativo sul verde, le icone Android, quella delle notifiche e `playstore.png` (512 px, per la scheda del Play Store).
- `assets/sounds/`: campane tibetane sintetizzate da `dart run tool/bowl.dart` (note, volume e durata sono in cima al file).
- `assets/fonts/`: Shippori Mincho e Zen Kaku Gothic New (OFL), ridotti ai soli caratteri usati nel codice e nelle traduzioni. Se aggiungi testo giapponese o una lingua nuova, rigenerali con `python tool/fonts.py <cartella dei font completi>`.

## Lingue

L'app segue la lingua del telefono: italiano, altrimenti inglese. Valuta, numeri e date seguono il paese del telefono (it_IT → "1.650 €", en_GB → "£1,650"), l'orario le sue 24 ore o AM/PM.

I testi sono in `lib/l10n/app_it.arb` (il riferimento) e `lib/l10n/app_en.arb`: file JSON con un identificativo per ogni frase, per esempio `"leftFor": "Ti restano per {month}"`. A ogni build Flutter genera i file in `lib/l10n/generated/` (a mano: `flutter gen-l10n`), e nel codice si scrive `tr.leftFor(mese)`. I file generati non si modificano a mano.

Per aggiungere una lingua, per esempio il francese:

1. copia `app_it.arb` in `app_fr.arb`, metti `"@@locale": "fr"` e traduci i valori (non le chiavi e non i `{segnaposto}`);
2. aggiungi `fr` alla scelta della lingua in `setLocale` (`lib/l10n/localization.dart`) e alla configurazione delle lingue in `lib/app/kakebo_app.dart` (`supportedLocales` e `localeResolutionCallback`);
3. rigenera i font con `python tool/fonts.py <cartella dei font completi>`, se la lingua usa caratteri nuovi.

Le frasi non ancora tradotte finiscono in `build/untranslated-messages.json`.

## Rilascio

1. Aggiorna `version` in `pubspec.yaml`: il nome (`1.0.1`) per le persone, il numero dopo `+` per Android e Google Play, che deve crescere a ogni caricamento.
2. Fai commit su `main`, poi crea e invia il tag con lo stesso nome: `git tag v1.0.1 && git push origin v1.0.1`.
3. La GitHub Action *Release* (`.github/workflows/release.yml`) esegue analisi e test, compila APK e app bundle firmati e pubblica la release su GitHub con i due file. L'APK si installa direttamente; il file `-play.aab` va caricato nella Play Console. Avviata a mano da GitHub (Actions → Release → Run workflow) compila soltanto, senza pubblicare.

La chiave di caricamento (upload key) di Google Play non è nel repository:

- in locale il file `.jks` sta fuori dal repository; il suo percorso, la password e l'alias sono in `android/key.properties`, ignorato da git;
- per la Action sta nei secret del repository `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD` e `ANDROID_KEY_PASSWORD` (l'alias, `upload`, non è segreto ed è scritto nel workflow).

Conserva una copia del file `.jks` e della password fuori da questo computer, per esempio in un gestore di password. Con la firma delle app di Google Play una chiave di caricamento persa si può sostituire, ma serve una richiesta dalla Play Console.

Un'app firmata con un'altra chiave non si aggiorna sopra quella installata: passando dalle build di debug a quelle firmate va reinstallata, quindi prima salva un backup dall'app (Impostazioni → Salva un backup).
