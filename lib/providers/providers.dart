import 'package:app_template/core/store/shared_preferences_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Providers {
  static final Providers _instance = Providers._();
  Providers._();
  static Providers get instance => _instance;

  late ProviderContainer providerContainer;

  initialized() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    providerContainer = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          SharedPreferencesService(sharedPreferences: sharedPreferences),
        ),
      ],
    );
  }
}
