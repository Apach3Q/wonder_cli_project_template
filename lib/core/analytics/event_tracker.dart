import 'package:app_template/core/analytics/firebase_service.dart';
import 'package:app_template/tools/log.dart';

class EventTracker {
  static log({
    required String name,
    required Map<String, dynamic> parameters,
  }) {
    FirebaseService.analytics.logEvent(
      name: name,
      parameters: parameters,
    );
    LogUtils.d('Send event name: $name    parameters: $parameters');
  }
}
