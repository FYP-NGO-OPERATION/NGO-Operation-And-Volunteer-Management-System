import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _appLinks = AppLinks();

    // Handle link when app is in cold state
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri, navigatorKey);
      }
    });

    // Handle link when app is in background/foreground
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri, navigatorKey);
    }, onError: (err) {
      debugPrint('Deep Link Error: $err');
    });
  }

  void _handleDeepLink(Uri uri, GlobalKey<NavigatorState> navigatorKey) {
    debugPrint('Received Deep Link: $uri');
    // Assuming format: https://ngo-app.com/campaign/123
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'campaign') {
      if (uri.pathSegments.length > 1) {
        final campaignId = uri.pathSegments[1];
        // In a real app we'd navigate to the campaign screen.
        // For now just logging it to simulate native routing
        debugPrint('Navigating natively to Campaign ID: $campaignId');
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
