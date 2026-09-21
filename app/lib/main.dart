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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // ─── Global Error Handling ───
  // Catches unhandled Flutter framework errors (widget build failures, etc.)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('⚠️ FlutterError: ${details.exceptionAsString()}');
  };

  // Catches unhandled async errors from platform channels, isolates, etc.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('⚠️ PlatformError: $error');
    return true; // Prevents app crash — logs instead
  };

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Notifications
  // await NotificationService().initialize(); // Done in splash screen

  // Temporary Seeder for all 3 Projects
  await ProjectSeeder.seedAll();

  // Load saved preferences
  final themePrefs = await ThemeService.loadThemePrefs();

  // Disable Firestore persistence on the web to avoid hot-restart assertion errors
  if (kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ur')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
