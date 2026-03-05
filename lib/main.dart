import 'dart:convert';
import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:ml_test/presentation/router.dart';
import 'package:ml_test/infrastructure/services/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final translations = await _loadJsonTranslations();

  runApp(MyApp(translations: translations));
}

Future<Map<String, Map<String, String>>> _loadJsonTranslations() async {
  final enJson = await rootBundle.loadString('assets/lang/en.json');
  final esJson = await rootBundle.loadString('assets/lang/es.json');

  return {
    'en_US': Map<String, String>.from(json.decode(enJson)),
    'es_ES': Map<String, String>.from(json.decode(esJson)),
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.translations});

  final Map<String, Map<String, String>> translations;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      onGenerateTitle: (context) => AppStrings.appTitle.tr,
      locale: Locale('en', 'US'),
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: AppRouter.initial,
      translations: AppTranslations(translations),
      getPages: AppRouter.routes,
    );
  }
}
