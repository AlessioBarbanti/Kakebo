# The text recognition plugin can use ML Kit's Chinese, Devanagari, Japanese and Korean models, which Kakebo leaves out:
# receipts are read with the Latin one only. R8 would stop the release build on the missing classes.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
