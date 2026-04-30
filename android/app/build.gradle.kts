plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.antutech.antudrive_lite"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.antutech.antudrive_lite"
        // BLE requires API 21+; runtime BLE permissions require API 23+
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Set these via environment variables or a local keystore.properties file
            // that is NOT committed to version control.
            // Example:
            //   storeFile = file(System.getenv("KEYSTORE_PATH") ?: "keystore.jks")
            //   storePassword = System.getenv("KEYSTORE_PASSWORD") ?: ""
            //   keyAlias = System.getenv("KEY_ALIAS") ?: ""
            //   keyPassword = System.getenv("KEY_PASSWORD") ?: ""
            //
            // Until a keystore is configured, release builds fall back to debug signing.
            storeFile = signingConfigs.getByName("debug").storeFile
            storePassword = signingConfigs.getByName("debug").storePassword
            keyAlias = signingConfigs.getByName("debug").keyAlias
            keyPassword = signingConfigs.getByName("debug").keyPassword
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
