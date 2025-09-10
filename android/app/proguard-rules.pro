# NDIS Connect Flutter App - ProGuard Rules
# ProGuard configuration for production builds

# --- Flutter core and plugin classes ---
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.app.** { *; }

# --- Firebase and Google Play Services ---
-keep class com.google.firebase.** { *; }
-keep class com.google.firebase.iid.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.play.core.** { *; }

# --- ML Kit and Generative AI ---
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_** { *; }
-keep class com.google.android.gms.internal.mlkit_common.** { *; }
-keep class com.google.generativeai.** { *; }

# --- App-specific classes ---
-keep class com.ndisconnect.app.** { *; }

# --- Serialization and Reflection ---
-keep class * implements java.io.Serializable { *; }
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
-keepclassmembers class * {
    public <init>(...);
}
-keepclassmembers class * {
    public *;
}
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes RuntimeVisibleAnnotations,RuntimeInvisibleAnnotations

# --- Native methods and enums ---
-keepclasseswithmembernames class * {
    native <methods>;
}
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# --- Remove logging in release builds ---
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# --- JSON serialization/deserialization (json_serializable, Gson, etc.) ---
-keep class *.model.** { *; }
-keep class *.models.** { *; }
-keep class *.entity.** { *; }
-keep class *.entities.** { *; }
-keep class *.dto.** { *; }
-keep class *.data.** { *; }

# --- Hive (if used) ---
-keep class **.hive.** { *; }
-keep class * extends hive_generator.TypeAdapter { *; }

# --- go_router (if used) ---
-keep class **.go_router.** { *; }

# --- url_launcher plugin ---
-keep class io.flutter.plugins.urllauncher.** { *; }

# --- Google Maps plugin ---
-keep class com.google.maps.android.** { *; }
-keep class com.google.android.gms.maps.** { *; }

# --- WorkManager and background tasks ---
-keep class androidx.work.** { *; }
-keep class io.flutter.plugins.workmanager.** { *; }

# --- Notifications ---
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# --- In-app purchase ---
-keep class com.android.billingclient.** { *; }

# --- PDF and printing ---
-keep class com.itextpdf.** { *; }
-keep class net.sf.jasperreports.** { *; }

# --- Timezone ---
-keep class org.threeten.bp.** { *; }

# --- Geolocator ---
-keep class com.baseflow.geolocator.** { *; }

# --- Speech to text and TTS ---
-keep class com.csdcorp.speech_to_text.** { *; }
-keep class com.tundralabs.fluttertts.** { *; }

# --- Animation plugins (Lottie, Confetti, etc.) ---
-keep class com.airbnb.lottie.** { *; }
-keep class com.github.jinatonic.confetti.** { *; }

# --- Provider (if using code generation) ---
-keep class **.provider.** { *; }

# --- Dart entrypoints for plugins ---
-keepclassmembers class * {
    @io.flutter.embedding.engine.plugins.FlutterPlugin void onAttachedToEngine(...);
    @io.flutter.embedding.engine.plugins.FlutterPlugin void onDetachedFromEngine(...);
}

# --- Do not obfuscate or shrink Flutter generated files ---
-keep class io.flutter.** { *; }
-dontshrink

# --- Optimization settings ---
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify