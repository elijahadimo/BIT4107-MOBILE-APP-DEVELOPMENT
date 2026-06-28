import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/branch_provider.dart';
import 'providers/incident_provider.dart';
import 'providers/shipment_provider.dart';
import 'providers/trip_provider.dart';
import 'providers/user_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/cms_provider.dart';
import 'providers/chat_provider.dart';
import 'theme/app_theme.dart';
import 'utils/router.dart';
import 'services/storage_service.dart';
import 'services/sync_service.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations (Portrait only for mobile)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Use path URL strategy (removes # from URL on web)
  usePathUrlStrategy();
  
  // Initialize Storage Service
  final storageService = await StorageService.init();
  final connectivityProvider = ConnectivityProvider();
  
  // Initialize Sync Service (background syncing)
  SyncService(
    storageService: storageService,
    connectivityProvider: connectivityProvider,
  );

  // Global error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // You could send this to a service like Sentry or Firebase Crashlytics here
  };
  
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: storageService),
        ChangeNotifierProvider.value(value: connectivityProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider(storageService: storageService)),
        ChangeNotifierProvider(create: (_) => BranchProvider(storageService: storageService)),
        ChangeNotifierProvider(create: (_) => ShipmentProvider(storageService: storageService)),
        ChangeNotifierProvider(create: (_) => TripProvider(storageService: storageService)),
        ChangeNotifierProvider(create: (_) => UserProvider(storageService: storageService)),
        ChangeNotifierProvider(create: (_) => IncidentProvider(storageService: storageService)),
        ChangeNotifierProvider(create: (_) => CmsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
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
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.router(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kapoeta Logistics',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final isOnline = context.watch<ConnectivityProvider>().isOnline;
        return Column(
          children: [
            if (!isOnline)
              Material(
                child: Container(
                  color: Colors.redAccent,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Center(
                    child: Text(
                      'No Internet Connection - Offline Mode',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            Expanded(child: child!),
          ],
        );
      },
    );
  }
}
