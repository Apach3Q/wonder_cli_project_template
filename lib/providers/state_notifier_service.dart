import 'package:app_template/tools/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StateNotifierService<T> extends StateNotifier<T> {
  StateNotifierService(super.state) {
    LogUtils.d('State notifier class ${runtimeType.toString()} init');
  }

  @override
  void dispose() {
    LogUtils.d('State notifier class ${runtimeType.toString()} disposed');
    super.dispose();
  }

  @override
  set state(T value) {
    if (mounted) super.state = value;
  }
}
