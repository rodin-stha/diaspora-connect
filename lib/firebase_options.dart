import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBOJnCMA6AVggCO5Vpjfy_N-Y1VIF1qrsM',
    appId: '1:728008484931:android:32cd89aa2597a649488cf6',
    messagingSenderId: '728008484931',
    projectId: 'diaspora-connect-29809',
    storageBucket: 'diaspora-connect-29809.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAwb3_rRBbFykAIRoM3Gbp2FwVHkAlWdII',
    appId: '1:728008484931:ios:1aebd08ea69ab539488cf6',
    messagingSenderId: '728008484931',
    projectId: 'diaspora-connect-29809',
    storageBucket: 'diaspora-connect-29809.firebasestorage.app',
    iosBundleId: 'com.kumolabs.diasporaConnect',
  );
}
