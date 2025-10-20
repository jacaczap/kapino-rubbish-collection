# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat { *; }
-keep class androidx.core.app.NotificationCompat$* { *; }

# Preserve generic type information for SharedPreferences
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep Gson-related classes used by plugins
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type

# Keep SharedPreferences classes
-keep class androidx.preference.** { *; }

