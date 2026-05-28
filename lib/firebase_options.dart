import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDJslfTxRLintcipd_A6xqa4079EYS00Z4',
        authDomain: 'turnigym.firebaseapp.com',
        projectId: 'turnigym',
        storageBucket: 'turnigym.firebasestorage.app',
        messagingSenderId: '918998557634',
        appId: '1:918998557634:web:d01c2543420a661de9ac5b',
      );
    }

    // Web dışı platformlar için geçici boş şablon (Hata vermemesi için)
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: '',
          appId: '',
          messagingSenderId: '',
          projectId: '',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: '',
          appId: '',
          messagingSenderId: '',
          projectId: '',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
