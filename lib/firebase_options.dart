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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyB7o9PZHYyXYqv6oFKazRHWAfLqgL9ERoE',
    appId: '1:1086497575018:web:dceabb84a632c0e957fa13',
    messagingSenderId: '1086497575018',
    projectId: 'book-catalog-bd83b',
    authDomain: 'book-catalog-bd83b.firebaseapp.com',
    storageBucket: 'book-catalog-bd83b.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBOw6L79G_Hl7kDgENL0C41EH38uolNWcg',
    appId: '1:1086497575018:android:4880dc9b395e7d3357fa13',
    messagingSenderId: '1086497575018',
    projectId: 'book-catalog-bd83b',
    storageBucket: 'book-catalog-bd83b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC9Fvi8R0qF6zz-RHArXoWBPJ09m_7Eveo',
    appId: '1:1086497575018:ios:5f180cffd3b8f63357fa13',
    messagingSenderId: '1086497575018',
    projectId: 'book-catalog-bd83b',
    storageBucket: 'book-catalog-bd83b.firebasestorage.app',
    iosBundleId: 'com.example.flutterPrj',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC9Fvi8R0qF6zz-RHArXoWBPJ09m_7Eveo',
    appId: '1:1086497575018:ios:5f180cffd3b8f63357fa13',
    messagingSenderId: '1086497575018',
    projectId: 'book-catalog-bd83b',
    storageBucket: 'book-catalog-bd83b.firebasestorage.app',
    iosBundleId: 'com.example.flutterPrj',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB7o9PZHYyXYqv6oFKazRHWAfLqgL9ERoE',
    appId: '1:1086497575018:web:3e9c95613e65f99857fa13',
    messagingSenderId: '1086497575018',
    projectId: 'book-catalog-bd83b',
    authDomain: 'book-catalog-bd83b.firebaseapp.com',
    storageBucket: 'book-catalog-bd83b.firebasestorage.app',
  );
}
