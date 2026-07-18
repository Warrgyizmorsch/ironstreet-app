import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/routes/app_pages.dart';
import 'app/bindings/initial_binding.dart';

import 'app/data/local/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => SessionManager().init());
  runApp(const IronStreetApp());
}

class IronStreetApp extends StatelessWidget {
  const IronStreetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Iron Street',
      initialBinding: InitialBinding(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        primaryColor: const Color(0xFFF37021),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFF37021),
          secondary: const Color(0xFFF37021),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
