# The text recognition plugin can use ML Kit's Chinese, Devanagari, Japanese and Korean models, which Kakebo leaves out:
# receipts are read with the Latin one only. R8 would stop the release build on the missing classes.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# ML Kit finds its parts by creating the registrars named in the manifest through their empty constructor. The rule its
# firebase-components library brings keeps the classes only, and R8's full mode then drops the constructors: ML Kit starts
# with nothing registered and every receipt fails with a NullPointerException ("Non riesco a leggere lo scontrino").
-keep class * implements com.google.firebase.components.ComponentRegistrar { <init>(); }
