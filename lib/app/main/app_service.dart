import 'package:app_template/core/http/api_ping.dart';
import 'package:app_template/core/http/wonder_http.dart';
import 'package:app_template/providers/state_notifier_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appProvider = StateNotifierProvider<AppService, int>((ref) {
  return AppService()..initialized();
});

class AppService extends StateNotifierService<int> {
  AppService() : super(0);

  Future<void> initialized() async {
    _initApi();
    _initPayment();
  }

  void _initApi() {
    ApiPing.init();
    WonderHttp.init();
  }

  // todo: init payment
  Future<void> _initPayment() async {}

  updateTab(int tab) {
    state = tab;
  }
}
