# Novità

Tutte le modifiche di Kakebo che si notano usando l'app, dalla più recente. I numeri di versione seguono il [versionamento semantico](https://semver.org/lang/it/).

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

[1.1.1]: https://github.com/AlessioBarbanti/Kakebo/releases/tag/v1.1.1
[1.1.0]: https://github.com/AlessioBarbanti/Kakebo/releases/tag/v1.1.0
[1.0.0]: https://github.com/AlessioBarbanti/Kakebo/releases/tag/v1.0.0
