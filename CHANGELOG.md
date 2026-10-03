# Novità

Tutte le modifiche di Kakebo che si notano usando l'app, dalla più recente. I numeri di versione seguono il [versionamento semantico](https://semver.org/lang/it/).

## [1.2.1] - 2026-10-04

### Correzioni

- **La tastiera si chiude con un tocco.** Nell'introduzione e in "Prepara il mese" basta toccare fuori dai campi per chiudere la tastiera; passando da un campo all'altro resta aperta.
- **Indietro non salta un passo.** Nell'introduzione, chiudere la tastiera con il gesto Indietro dal bordo dello schermo a volte riportava al passo precedente. Ora non succede più.
- **L'invito a scorrere non copre il campo.** Mentre scrivi in un campo, l'invito a scorrere per vedere il resto aspetta: prima finiva sopra il campo lasciato in vista dalla tastiera.

## [1.2.0] - 2026-09-27

### Modifiche

- **Un diario con due momenti.** Il diario resta com'è presentato: il pensiero della sera e il mese. Spariscono il riepilogo della domenica nella cronologia, la domanda sulla settimana nascosta sotto di esso e la sua voce nelle impostazioni. Le parole già scritte per una settimana restano nei dati e nei backup, anche se non si vedono più.
- **Il pensiero della sera, solo la sera.** Si scrive dall'orario scelto (21:00 se non lo cambi) fino alle 4 del mattino; fuori da quelle ore la card, il pulsante del Diario e le Impostazioni dicono quando si apre, e il pulsante del Diario annota una spesa. Dopo mezzanotte è ancora la sera prima: un pensiero scritto all'una va nel giorno precedente, e le parole iniziate prima delle 4 restano alla loro sera anche se le salvi dopo.
- **Quattro domande, come promesso.** Nella revisione le parole del mese rispondono ora alla "Domanda 4 · Come puoi migliorare?", come nell'introduzione. Finché il mese è in corso la revisione si chiama "Il mese", non "Fine mese".

### Correzioni

- **Obiettivo e ramo restano separati.** Nella vista Anno, un mese che raggiunge l'obiettivo non dice più che "il ramo è fiorito": il ramo misura il ritmo della spesa, non il risparmio.
- **Indietro porta dove eri.** "Entrate e spese fisse" torna alle Impostazioni o alla revisione da cui l'hai aperta (prima diceva "Torna al registro" e portava a Oggi); lo stesso fa il tasto indietro di Android.
- **Il primo del mese.** In italiano le date scrivono "1° ott" invece di "1 ott".

## [1.1.3] - 2026-09-26

### Modifiche

- **Download più leggeri.** Su GitHub ci sono ora due APK, uno per tipo di processore, da circa 20 MB invece di un unico file da 55: `-arm64` per quasi tutti i telefoni, `-armv7` per quelli più vecchi. Le note di ogni versione spiegano quale scegliere. Da Google Play ogni telefono riceve già solo la parte che gli serve.

## [1.1.2] - 2026-09-26

### Modifiche

- **Una prima domanda più chiara.** "Quanto denaro hai?" diventa "Quanto entra questo mese?": lo stipendio e le altre entrate, non quello che c'è sul conto. Nella revisione del mese la risposta sono ora le entrate, con quanto resta tolte le spese fisse.
- **Campi vuoti invece di numeri d'esempio.** Alla prima apertura entrate, risparmio e spese fisse partono vuoti, con un suggerimento in grigio che sparisce quando scrivi. Prima c'erano 2.800 € e 300 € da cancellare, che rischiavano di restare come se fossero veri. In tutta l'app, uno zero si mostra come campo vuoto.
- **Un invito a scorrere.** Nell'introduzione, quando sotto c'è altro (come la domanda sul risparmio in "Prepara il mese"), la pagina sfuma in fondo e un pulsante "Scorri per continuare" lo segnala.

### Correzioni

- **Swipe nell'introduzione.** Si passa da una schermata all'altra scorrendo in qualsiasi punto, anche nella parte bassa con i puntini e i pulsanti: prima lì lo swipe non veniva preso.
- **Registro senza entrate.** Aprire il Registro prima di aver indicato le entrate non dà più errore.

## [1.1.1] - 2026-09-26

### Correzioni

- **Ogni mese ricorda i suoi conti.** Cambiare entrate, spese fisse o obiettivo di risparmio non modifica più le cifre dei mesi già finiti: se a ottobre aumenta l'affitto, settembre si chiude con le sue spese fisse. Vale per la revisione del mese, per la chiusura automatica e per la vista annuale del calendario. I mesi registrati prima di questa versione usano ancora i valori attuali.

## [1.1.0] - 2026-09-26

### Novità

- **Spese dimenticate.** Nella scheda della spesa, accanto ad "Annulla", un piccolo pulsante con il calendario cambia la data: una spesa di ieri si annota anche oggi e va al suo posto nel Registro. Si possono scegliere i giorni dei mesi ancora aperti, mai quelli futuri, e la data si cambia anche modificando una spesa.
- **Chiudere il mese quando è finito.** Il sigillo si mette dal primo giorno del mese dopo: per tutto quel mese il Diario ricorda che il mese precedente è da chiudere, con le sue cifre e le sue domande. Durante il mese si possono già scrivere le riflessioni.
- **Nessun mese resta in sospeso.** Se ti dimentichi di chiudere un mese, alla fine del mese successivo si chiude da solo, con le sue cifre e senza riflessioni. Vale anche a cavallo dell'anno e con il mese che comincia il giorno dello stipendio.
- **Un avviso sul risparmio.** Se l'obiettivo supera quello che resta dopo le spese fisse, o se le spese fisse superano le entrate, un avviso sotto il campo lo dice. Non blocca niente.

### Modifiche

- **Prepara il mese, alla prima apertura.** Le spese fisse diventano il punto 2, sempre in vista, con una riga pronta da compilare e la × per toglierla; il risparmio diventa il punto 3. Prima erano nascoste sotto le entrate.
- **Si parte da zero.** Un'installazione nuova comincia con una sola spesa fissa vuota, invece di cinque voci d'esempio da cancellare.

### Correzioni

- **Introduzione.** Le stampe ora sfumano davvero l'una nell'altra: prima quella che se ne andava restava visibile sotto la nuova e spariva di colpo alla fine del passaggio.

## [1.0.0] - 2026-09-26

La prima versione.

- **Il metodo kakebo:** ogni spesa in uno dei quattro pilastri (Necessità, Desideri, Cultura, Imprevisti) e le quattro domande a inizio e fine mese.
- **Prepara il mese:** entrate, spese fisse e obiettivo di risparmio, con la regola 50/30/20 facoltativa e il mese che può cominciare il giorno dello stipendio.
- **Oggi:** quanto resta, circa quanto al giorno e il ramo di susino che fiorisce se tieni il ritmo del mese.
- **Registro e Calendario:** la settimana e il mese per pilastro; i giorni sfumati secondo le spese libere; l'anno, mese per mese, accanto al disponibile.
- **Diario:** il pensiero della sera con la meditazione facoltativa, il riepilogo della domenica, la revisione del mese e il sigillo.
- **Una frase al giorno** e **un promemoria serale**.
- **I dati restano sul telefono:** nessun account e nessun permesso Internet; backup in un file ed esportazione in CSV.
- **In italiano e in inglese.**

[1.2.1]: https://github.com/AlessioBarbanti/Kakebo/releases/tag/v1.2.1
[1.2.0]: https://github.com/AlessioBarbanti/Kakebo/releases/tag/v1.2.0
[1.1.3]: https://github.com/AlessioBarbanti/Kakebo/releases/tag/v1.1.3
[1.1.2]: https://github.com/AlessioBarbanti/Kakebo/releases/tag/v1.1.2
[1.1.1]: https://github.com/AlessioBarbanti/Kakebo/releases/tag/v1.1.1
[1.1.0]: https://github.com/AlessioBarbanti/Kakebo/releases/tag/v1.1.0
[1.0.0]: https://github.com/AlessioBarbanti/Kakebo/releases/tag/v1.0.0
