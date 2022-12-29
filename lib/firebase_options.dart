// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyBPxvhk7IgkPqMG6ChjLHxHqSipx9b-rXk',
    appId: '1:193901987670:web:c08fb00c33492b2c39b8f7',
    messagingSenderId: '193901987670',
    projectId: 'sorun-takip-191307028',
    authDomain: 'sorun-takip-191307028.firebaseapp.com',
    storageBucket: 'sorun-takip-191307028.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC95iw9mgcn6WqdbCyIHghEzvXMzWRSMtw',
    appId: '1:193901987670:android:148bbb73d9cbe02f39b8f7',
    messagingSenderId: '193901987670',
    projectId: 'sorun-takip-191307028',
    storageBucket: 'sorun-takip-191307028.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD8VCk1IykziU9yXOW6ey_ZmH5fkAy8A_k',
    appId: '1:193901987670:ios:debc9cd2650b562339b8f7',
    messagingSenderId: '193901987670',
    projectId: 'sorun-takip-191307028',
    storageBucket: 'sorun-takip-191307028.appspot.com',
    iosClientId: '193901987670-vmg3obfiplpgl1e52p4q459dbinoq54q.apps.googleusercontent.com',
    iosBundleId: 'com.example.sorunTakipSistemi',
  );
}
