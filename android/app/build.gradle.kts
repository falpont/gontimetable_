import java.util.Properties

// key.properties 파일에서 서명 정보를 로드합니다.
val keystoreProperties = Properties().apply {
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        load(keystorePropertiesFile.inputStream())
    }
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.sunggon.gontimetable"
    compileSdk = 35 // 현재 35로 설정되어 있으며, Android 14 (API 34) 이상 지원에 적합합니다.
    ndkVersion = "27.0.12077973" // NDK 버전은 현재 사용 중인 버전을 유지합니다.

    compileOptions {
        // Java 11 또는 17을 사용하도록 권장합니다.
        // 현재 11로 설정되어 있으므로 그대로 유지합니다.
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // coreLibraryDesugaring 사용을 위해 활성화
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.sunggon.gontimetable"
        minSdk = 21 // 하위 호환성을 위해 21을 유지합니다.
        targetSdk = 35 // compileSdk와 동일하게 35를 유지합니다.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"].toString()
            keyPassword = keystoreProperties["keyPassword"].toString()
            storeFile = file(keystoreProperties["storeFile"].toString())
            storePassword = keystoreProperties["storePassword"].toString()
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BOM (Bill of Materials)은 버전 관리를 용이하게 합니다.
    implementation(platform("com.google.firebase:firebase-bom:33.11.0"))
    // Desugaring 라이브러리 (Java 11+ 기능을 하위 Android 버전에서 사용)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // ★★★ 필수 추가: Material Components 라이브러리 ★★★
    // 'Theme.MaterialComponents.Light.NoActionBar' 오류를 해결합니다.
    // 2025년 5월 현재 기준으로 최신 stable 버전은 1.12.0 입니다.
    implementation("com.google.android.material:material:1.12.0")

    // ★★★ 필수 추가: Android 12+ 스플래시 스크린 라이브러리 ★★★
    // 'Theme.SplashScreen not found' 오류를 해결합니다.
    // 현재 1.0.1 버전이 stable 입니다.
    implementation("androidx.core:core-splashscreen:1.0.1")

    // 기타 의존성들...
    // Flutter 프로젝트 생성 시 기본적으로 포함될 수 있는 테스트 라이브러리
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}