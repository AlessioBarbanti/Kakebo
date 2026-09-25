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

## Struttura

- `lib/kakebo.dart`: dati, calcoli del budget, salvataggio (shared_preferences)
- `lib/ui.dart`: stili, widget condivisi (ramo, sigillo, ensō, respiro)
- `lib/intro.dart`: introduzione e inizio mese
- `lib/shell.dart`: intestazione, schede con swipe, impostazioni
- `lib/home.dart`, `ledger.dart`, `journal.dart`, `calendar.dart`, `thought.dart`: le schermate
- `assets/art/`: stampe di pubblico dominio (Wikimedia Commons)
