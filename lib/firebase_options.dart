// File: lib/firebase_options.dart

// ignore_for_file: lines_longer_than_80_chars
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configurações do Firebase para cada plataforma (Android, iOS, Web, etc.)
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Configuração do Firebase não disponível para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBbBmTG0Iqt11xIN5Bi6qZQCY1uqWV8u9c",
    appId: "1:28028152887:android:a6822e6d1f22b73faa63b2",
    messagingSenderId: "28028152887",
    projectId: "publicidade-tropical",
    storageBucket: "publicidade-tropical.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyA-EXEMPLO-IOS",
    appId: "1:28028152887:android:7161469b8d9c159caa63b2",
    messagingSenderId: "28028152887",
    projectId: "publicidade-tropical",
    storageBucket: "meu-projeto.appspot.com",
    iosClientId: "1234567890-abc123.apps.googleusercontent.com",
    iosBundleId: "com.exemplo.app",
  );
}
