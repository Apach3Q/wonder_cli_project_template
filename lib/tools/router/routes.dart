import 'package:app_template/app/main/app_screen.dart';
import 'package:app_template/app/main/splash/splash_screen.dart';
import 'package:app_template/tools/router/const.dart';
import 'package:app_template/core/store/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> routes = <GoRoute>[
  GoRoute(
    path: appRoutePath,
    builder: (BuildContext context, GoRouterState state) {
      return sharedPreferencesService.getIsFirstLaunch()
          ? const SplashScreen()
          : AppScreen();
    },
  ),
];
