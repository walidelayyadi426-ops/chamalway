import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/themes/app_theme.dart';
import 'core/routes/app_router.dart';
import 'data/repositories/destination_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: ChamalWayApp(),
    ),
  );
}

class ChamalWayApp extends ConsumerWidget {
  const ChamalWayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return MaterialApp.router(
      title: 'ChamalWay - Northern Morocco Tourism',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
