# Flutter embedding & plugins are kept by the Flutter Gradle plugin.
# Keep ML Kit barcode scanning models used by mobile_scanner.
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
# flutter_local_notifications uses Gson with reflection.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
