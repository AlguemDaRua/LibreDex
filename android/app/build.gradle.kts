import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

apply(plugin = "kotlin-android")

// Release signing is optional so that a plain checkout still builds. Create
// android/key.properties (git-ignored, never committed) with:
//
//   storeFile=../keystore.jks
//   storePassword=...
//   keyAlias=libredex
//   keyPassword=...
//
// Without it, release builds fall back to the debug key, which is NOT
// distributable — the Play Store rejects debug-signed APKs/AABs.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}
val hasReleaseKeystore = keystorePropertiesFile.exists()
val releaseStoreFile =
    keystoreProperties["storeFile"]?.let { rootProject.file(it as String) }

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

configure<com.android.build.api.dsl.ApplicationExtension> {
    namespace = "com.alguemdarua.libredex"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.alguemdarua.libredex"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore && releaseStoreFile != null) {
            create("release") {
                storeFile = releaseStoreFile
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseKeystore && releaseStoreFile != null) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // Unsigned-by-design fallback: keeps local `flutter build
                // apk --release` working, but the output is NOT distributable.
                logger.warn(
                    "No android/key.properties found — signing release with " +
                        "the debug key. Do not distribute this build.",
                )
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
