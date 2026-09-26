import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing with the Google Play upload key. CI passes it through the environment (GitHub secrets, see
// .github/workflows/release.yml); locally it comes from android/key.properties, which git ignores. Without either,
// release builds use the debug key, fine for trying on a phone but not accepted by the Play Store.
val keyProperties = Properties().apply {
    rootProject.file("key.properties").takeIf { it.exists() }?.inputStream()?.use { load(it) }
}
fun signing(env: String, property: String): String? = System.getenv(env) ?: keyProperties.getProperty(property)
val uploadStore = signing("ANDROID_KEYSTORE_PATH", "storeFile")

android {
    namespace = "com.alessiobarbanti.kakebo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications needs java.time on older Android versions.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        if (uploadStore != null) {
            create("upload") {
                storeFile = file(uploadStore)
                storePassword = signing("ANDROID_KEYSTORE_PASSWORD", "storePassword")
                keyAlias = signing("ANDROID_KEY_ALIAS", "keyAlias")
                keyPassword = signing("ANDROID_KEY_PASSWORD", "keyPassword")
            }
        }
    }

    defaultConfig {
        // Final: the Play Store identifies the app by it, and it can never change once published.
        applicationId = "com.alessiobarbanti.kakebo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("upload") ?: signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
