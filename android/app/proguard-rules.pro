# Flutter-specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**
-dontwarn com.google.**

# Syncfusion PDF Viewer
-keep class syncfusion_flutter_pdfviewer.** { *; }
-keep class com.syncfusion.** { *; }
-dontwarn com.syncfusion.**

# Keep annotation model classes (used via reflection by PDF viewer)
-keep class syncfusion_flutter_pdfviewer.src.annotation.** { *; }
-keep class syncfusion_flutter_pdfviewer.src.common.** { *; }

# General Android
-keepattributes *Annotation*
-keep class * extends java.util.ListResourceBundle {
    protected Object[][] getContents();
}
