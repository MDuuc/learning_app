// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAQeIjAkppCjk9rXjudWdn-xbeWYBIr6YM',
    appId: '1:525196951020:web:923dc51ebd2487996494c9',
    messagingSenderId: '525196951020',
    projectId: 'e-learning-2626e',
    authDomain: 'e-learning-2626e.firebaseapp.com',
    storageBucket: 'e-learning-2626e.firebasestorage.app',
    measurementId: 'G-WZ603LDXCK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNJEgfSwbmtgDfLLs3j8WfiJSmz8bUFoI',
    appId: '1:525196951020:android:2cc86e26709df1646494c9',
    messagingSenderId: '525196951020',
    projectId: 'e-learning-2626e',
    storageBucket: 'e-learning-2626e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCYBuHBzqLKcIFUI0oVtow_bYNBO6luVkw',
    appId: '1:525196951020:ios:18bb89f3c32041246494c9',
    messagingSenderId: '525196951020',
    projectId: 'e-learning-2626e',
    storageBucket: 'e-learning-2626e.firebasestorage.app',
    iosBundleId: 'com.example.raccoonLearning',
  );
}

// firebase.json including web, i want t delete that, when it require re-capcha, in the furture i will add it later
//{"firestore":{"rules":"firestore.rules","indexes":"firestore.indexes.json"},"flutter":{"platforms":{"android":{"default":{"projectId":"e-learning-2626e","appId":"1:525196951020:android:2cc86e26709df1646494c9","fileOutput":"android/app/google-services.json"}},"dart":{"lib/firebase_options.dart":{"projectId":"e-learning-2626e","configurations":{"android":"1:525196951020:android:2cc86e26709df1646494c9","ios":"1:525196951020:ios:18bb89f3c32041246494c9","web":"1:525196951020:web:923dc51ebd2487996494c9"}}}}}}

// without web
// {"firestore":{"rules":"firestore.rules","indexes":"firestore.indexes.json"},"flutter":{"platforms":{"android":{"default":{"projectId":"e-learning-2626e","appId":"1:525196951020:android:2cc86e26709df1646494c9","fileOutput":"android/app/google-services.json"}},"dart":{"lib/firebase_options.dart":{"projectId":"e-learning-2626e","configurations":{"android":"1:525196951020:android:2cc86e26709df1646494c9","ios":"1:525196951020:ios:18bb89f3c32041246494c9"}}}}}}
