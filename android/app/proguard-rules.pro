# Flutter ProGuard Rules
# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /Users/adimolopir/flutter/packages/flutter_tools/gradle/flutter_proguard_rules.pro
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.

# Keep ML Kit and CameraX classes from being obfuscated or stripped
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**
-keep class dev.datagrove.mobile_scanner.** { *; }
