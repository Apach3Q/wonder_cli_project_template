import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static initialize() async {
    await Firebase.initializeApp(// todo: generate firebase options
        // options: DefaultFirebaseOptions.currentPlatform,
        );
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }
}
