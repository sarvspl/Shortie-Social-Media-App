-keep class **.zego.**  { *; }
-keep class **.**.zego_zpns.** { *; }
-keepclassmembers class ai.deepar.ar.DeepAR { *; }
-keepclassmembers class ai.deepar.ar.core.videotexture.VideoTextureAndroidJava { *; }
-keep class ai.deepar.ar.core.videotexture.VideoTextureAndroidJava
  -keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

-keepattributes JavascriptInterface
-keepattributes *Annotation*

-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}

-optimizations !method/inlining/*

-keepclasseswithmembers class * {
  public void onPayment*(...);
}

# Stripe SDK rules
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# Keep all classes in push provisioning packages
-keep class com.stripe.android.pushprovisioning.** { *; }
-keep class com.stripe.android.pushProvisioning.** { *; }

# Keep all inner classes
-keepclassmembers class com.stripe.android.pushProvisioning.**$* { *; }
-keepclassmembers class com.stripe.android.pushprovisioning.**$* { *; }

# Keep all methods and fields
-keepclassmembers class * extends com.stripe.android.pushprovisioning.** {
    <fields>;
    <methods>;
}

-keepclassmembers class * extends com.stripe.android.pushProvisioning.** {
    <fields>;
    <methods>;
}