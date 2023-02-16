import 'package:app_template/core/store/const.dart';
import 'package:app_template/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferencesService>(
    (ref) => throw Exception('service error'));

final sharedPreferencesService =
    Providers.instance.providerContainer.read(sharedPreferencesProvider);

class SharedPreferencesService {
  SharedPreferences sharedPreferences;
  SharedPreferencesService({
    required this.sharedPreferences,
  });

  Future<void> setInternalHost(bool isInternal) async {
    await sharedPreferences.setBool(storeInternalHostKey, isInternal);
  }

  bool getIsInternalHost() =>
      sharedPreferences.getBool(storeInternalHostKey) ?? false;

  Future<void> setIsFirstLaunch(bool isInternal) async {
    await sharedPreferences.setBool(storeFirstLaunchKey, isInternal);
  }

  bool getIsFirstLaunch() =>
      sharedPreferences.getBool(storeFirstLaunchKey) ?? true;
}
