import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/bindings/initial_binding.dart';
import 'app/data/local/session_manager.dart';
import 'app/utills/theme/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sessionManager = await Get.putAsync(() => SessionManager().init());

  final savedMode = sessionManager.getThemeMode();
  ThemeMode initialMode = ThemeMode.system;
  if (savedMode == 'light') {
    initialMode = ThemeMode.light;
  } else if (savedMode == 'dark') {
    initialMode = ThemeMode.dark;
  }

  runApp(IronStreetApp(initialThemeMode: initialMode));
}

class IronStreetApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  const IronStreetApp({super.key, this.initialThemeMode = ThemeMode.system});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Iron Street',
      initialBinding: InitialBinding(),
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: initialThemeMode,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
