import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        return androidOptions;
      case TargetPlatform.iOS:
        return iosOptions;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get androidOptions {
    String apiKey = dotenv.env['ANDROID_API_KEY']!;
    return FirebaseOptions(
      apiKey: apiKey,
      appId: '1:887496562203:android:4598788d4ed169c5478abe',
      messagingSenderId: '887496562203',
      projectId: 'swear-jar-61683',
      storageBucket: 'swear-jar-61683.appspot.com',
    );
  }

  static FirebaseOptions get iosOptions {
    String apiKey = dotenv.env['IOS_API_KEY']!;
    return FirebaseOptions(
      apiKey: apiKey,
      appId: '1:887496562203:ios:9ff12e3ccbc71b16478abe',
      messagingSenderId: '887496562203',
      projectId: 'swear-jar-61683',
      storageBucket: 'swear-jar-61683.appspot.com',
      iosBundleId: 'com.example.swearJar',
    );
  }
}
