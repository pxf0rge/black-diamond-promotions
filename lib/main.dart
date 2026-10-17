import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/di/app_dependencies.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/event_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/transaction_provider.dart';
import 'theme/app_theme.dart';
import 'utils/formatters.dart';
import 'widgets/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.card,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final deps = await AppDependencies.create();
  runApp(TicketTrackerApp(deps: deps));
}

class TicketTrackerApp extends StatelessWidget {
  const TicketTrackerApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authRepository: deps.authRepository,
            biometricService: deps.biometricService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => EventProvider(eventRepository: deps.eventRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(
            categoryRepository: deps.categoryRepository,
            productRepository: deps.productRepository,
            eventRepository: deps.eventRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(
            cartRepository: deps.cartRepository,
            eventRepository: deps.eventRepository,
            settingsRepository: deps.settingsRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(
            transactionRepository: deps.transactionRepository,
            dashboardRepository: deps.dashboardRepository,
            eventRepository: deps.eventRepository,
            settingsRepository: deps.settingsRepository,
            exportService: deps.exportService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            settingsRepository: deps.settingsRepository,
            exportService: deps.exportService,
            backupService: deps.backupService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'Black Diamond',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AppBootstrap(),
      ),
    );
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final authProvider = context.read<AuthProvider>();
    final eventProvider = context.read<EventProvider>();
    final catalogProvider = context.read<CatalogProvider>();
    final cartProvider = context.read<CartProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    await authProvider.init();
    await eventProvider.init();
    await catalogProvider.init();
    await cartProvider.init();
    await transactionProvider.init();
    await settingsProvider.init();

    final settings = settingsProvider.settings;
    if (settings != null) {
      Formatters.setCurrencySymbol(settings.currencySymbol);
    }
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AppShell()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💎', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Loading Ticket Tracker...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
