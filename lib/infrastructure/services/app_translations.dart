import 'package:get/get.dart';

class AppTranslations extends Translations {
  AppTranslations(this.translations);

  final Map<String, Map<String, String>> translations;

  @override
  Map<String, Map<String, String>> get keys => translations;
}
