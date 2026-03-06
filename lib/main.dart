import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/resource/theme_manager.dart';
import 'core/route/route_import_part.dart';
import 'core/route/route_name.dart';
import 'data/models/scan_history_model.dart';
import 'presentation/settings/viewmodel/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ScanHistoryModelAdapter());
  await Hive.openBox<ScanHistoryModel>('scan_history');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        title: 'AI Vision Toolkit',
        debugShowCheckedModeBanner: false,
        theme: getApplicationTheme(isDark: false),
        darkTheme: getApplicationTheme(isDark: true),
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        onGenerateRoute: AppRouter.getRoute,
        initialRoute: RouteName.splashRoute,
      ),
    );
  }
}
