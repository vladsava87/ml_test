import 'dart:async';
import 'package:ml_test/infrastructure/constants/app_strings.dart';
import 'package:ml_test/domain/interfaces/data/i_db_provider.dart';
import 'package:ml_test/infrastructure/router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _waitForAppSetup();
  }

  void _waitForAppSetup() async {
    try {
      final dbProvider = Get.find<IDbProvider>();
      await dbProvider.init();
    } catch (e) {
      Get.snackbar(
        AppStrings.databaseError.tr,
        '${AppStrings.failedToInitDatabase.tr}$e',
        backgroundColor: Colors.deepPurpleAccent.shade100,
        colorText: Colors.white,
      );
      return;
    } finally {
      await Get.offAllNamed(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppStrings.startingUp.tr),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
