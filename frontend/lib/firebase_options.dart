import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return ios;
      case TargetPlatform.windows:
        return web;
      case TargetPlatform.linux:
        return web;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCw_AcxZ8tI-mkwdxN6J92jVPjHgF0NWgk',
    appId: '1:554358282265:web:abfaf26281d32696363288',
    messagingSenderId: '554358282265',
    projectId: 'assettrack-ea5ba',
    storageBucket: 'assettrack-ea5ba.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCw_AcxZ8tI-mkwdxN6J92jVPjHgF0NWgk',
    appId: '1:554358282265:android:abfaf26281d32696363288',
    messagingSenderId: '554358282265',
    projectId: 'assettrack-ea5ba',
    storageBucket: 'assettrack-ea5ba.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCw_AcxZ8tI-mkwdxN6J92jVPjHgF0NWgk',
    appId: '1:554358282265:ios:abfaf26281d32696363288',
    messagingSenderId: '554358282265',
    projectId: 'assettrack-ea5ba',
    storageBucket: 'assettrack-ea5ba.firebasestorage.app',
  );
}
