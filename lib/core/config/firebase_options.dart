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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static final FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBlfQpkuzgS4SQ_CVHe4OBAdfdRN7MIuxo',
    appId: '1:221286547552:android:588d6a19249cb71d324305',
    messagingSenderId: '221286547552',
    projectId: 'comaslimpio-b3930',
    storageBucket: 'comaslimpio-b3930.firebasestorage.app',
  );

  static final FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBvzcezOhXJyHlglr_VNAz_tm6qxussByw',
    appId: '1:221286547552:ios:05a005f87a3a4315324305',
    messagingSenderId: '221286547552',
    projectId: 'comaslimpio-b3930',
    storageBucket: 'comaslimpio-b3930.firebasestorage.app',
    iosBundleId: 'com.cleancomas.comaslimpio',
  );
}
