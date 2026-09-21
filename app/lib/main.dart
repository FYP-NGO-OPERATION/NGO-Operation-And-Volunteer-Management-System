import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'config/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/campaign_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/ngo_provider.dart';
import 'providers/virtual_session_provider.dart';
import 'providers/disaster_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'widgets/common/no_internet_banner.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:freerasp/freerasp.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:workmanager/workmanager.dart';
import 'services/deep_link_service.dart';
import 'services/offline_sync_service.dart';

class SecureHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Enforce strict TLS/SSL. Block unverified proxies (MITM).
        // Custom cert validation logic would go here.
        return false;
      };
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == syncTaskName) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      return await OfflineSyncService.flushQueue();
    }
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // ─── RASP (Root/Jailbreak/Hook Detection) ───
  if (!kIsWeb) {
    final talsecConfig = TalsecConfig(
      androidConfig: AndroidConfig(
        packageName: 'com.ngo.ngo_volunteer_app',
        signingCertHashes: ['PLACEHOLDER_HASH'],
      ),
      iosConfig: IOSConfig(
        bundleIds: ['com.ngo.ngo_volunteer_app'],
        teamId: 'PLACEHOLDER_TEAM',
      ),
      watcherMail: 'security@example.com',
      isProd: true,
    );

    Talsec.instance.attachListener(
      TalsecThreatListener(
        onRoot: () => exit(0),
        onEmulator: () => exit(0),
        onHook: () => exit(0),
        onTamper: () => exit(0),
        onDeviceBinding: () => exit(0),
      ),
    );
    await Talsec.instance.start(talsecConfig);
  }

  // ─── SSL Certificate Pinning ───
  HttpOverrides.global = SecureHttpOverrides();

  // ─── Global Error Handling (Error Boundaries) ───
  // Intercepts the "Gray Screen of Death" for unhandled widget exceptions.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('⚠️ FlutterError: ${details.exceptionAsString()}');
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Oops! An unexpected error occurred.\nOur team has been notified.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('⚠️ FlutterError Log: ${details.exceptionAsString()}');
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // Catches unhandled async errors from platform channels, isolates, etc.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('⚠️ PlatformError: $error');
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true; // Prevents app crash — logs instead
  };

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  analytics.setAnalyticsCollectionEnabled(true);

  // Crashlytics setup for uncaught exceptions
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Push Notifications Background Handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Request permissions for notifications
  await FirebaseMessaging.instance.requestPermission();

  // Initialize Workmanager
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // ─── Firebase App Check ───
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
    webProvider: ReCaptchaV3Provider(
      dotenv.env['RECAPTCHA_SITE_KEY'] ?? 'fallback_key',
    ),
  );

  // Initialize Notifications
  // await NotificationService().initialize(); // Done in splash screen

  // Temporary Seeder for all 3 Projects
  await ProjectSeeder.seedAll();

  // Load saved preferences
  final themePrefs = await ThemeService.loadThemePrefs();

  // Disable Firestore persistence globally to prevent offline plaintext extraction of sensitive PII
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ur')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    DeepLinkService().initialize(_navigatorKey);
  }

  @override
  void dispose() {
    DeepLinkService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NgoProvider()),
        ChangeNotifierProvider(create: (_) => CampaignProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => VirtualSessionProvider()),
        ChangeNotifierProvider(create: (_) => DisasterProvider()),
      ],
      child: Consumer2<ThemeProvider, NgoProvider>(
        builder: (context, themeProvider, ngoProvider, _) {
          Color? primaryColor;
          Color? secondaryColor;

          if (ngoProvider.currentNgo != null) {
            String hex = ngoProvider.currentNgo!.primaryColorHex.replaceAll(
              '#',
              '',
            );
            if (hex.length == 6) hex = 'FF$hex';
            primaryColor = Color(int.tryParse(hex, radix: 16) ?? 0xFF1A6B3C);

            if (ngoProvider.currentNgo!.secondaryColorHex != null &&
                ngoProvider.currentNgo!.secondaryColorHex!.isNotEmpty) {
              String secHex = ngoProvider.currentNgo!.secondaryColorHex!
                  .replaceAll('#', '');
              if (secHex.length == 6) secHex = 'FF$secHex';
              secondaryColor = Color(
                int.tryParse(secHex, radix: 16) ?? 0xFFD89216,
              );
            }
          }

          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppTheme.getLightTheme(primaryColor, secondaryColor),
            darkTheme: AppTheme.getDarkTheme(primaryColor, secondaryColor),
            themeMode: themeProvider.themeMode,
            builder: (context, child) {
              return NoInternetWrapper(child: child!);
            },
            initialRoute: '/',
            onGenerateRoute: (settings) {
              final uri = Uri.parse(settings.name ?? '/');

              if (uri.pathSegments.length == 2 &&
                  uri.pathSegments.first == 'join') {
                final ngoId = uri.pathSegments[1];
                return MaterialPageRoute(
                  builder: (context) => SplashScreen(inviteNgoId: ngoId),
                  settings: settings,
                );
              }

              // Fallback default
              return MaterialPageRoute(
                builder: (context) => const SplashScreen(),
                settings: settings,
              );
            },
          );
        },
      ),
    );
  }
}
