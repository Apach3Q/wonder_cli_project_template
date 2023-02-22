import 'dart:async';

import 'package:app_template/app/main/app_service.dart';
import 'package:app_template/tools/utils/log_utils.dart';
import 'package:app_template/tools/mixin/post_frame_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_links/uni_links.dart';

class AppScreen extends StatelessWidget {
  AppScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabbarScreen();
  }
}

class TabbarScreen extends ConsumerStatefulWidget {
  const TabbarScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TabbarScreen> createState() => _TabbarScreenState();
}

bool _initialUriIsHandled = false;

class _TabbarScreenState extends ConsumerState<TabbarScreen>
    with PostFrameMixin {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();

    _listenIncomingDeepLinks();
    _handleDeepLinkUri();
    postFrame(() {
      ref.read(appProvider.notifier);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();

    super.dispose();
  }

  void _listenIncomingDeepLinks() {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      if (uri == null) return;
      String uriString = uri.toString();
      // todo: deeplink route actions
    }, onError: (Object err) {
      if (!mounted) return;
      LogUtils.d('=======get err: $err');
    });
  }

  Future<void> _handleDeepLinkUri() async {
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        final uri = await getInitialUri();
        if (uri == null) return;
        String uriString = uri.toString();
        // todo: deeplink route actions
      } on PlatformException {
        LogUtils.d('=======falied to get initial uri');
      } on FormatException catch (err) {
        if (!mounted) return;
        LogUtils.d('=======malformed initial uri');
        // setState(() => _err = err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
