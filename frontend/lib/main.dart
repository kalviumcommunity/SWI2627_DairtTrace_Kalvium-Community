import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/collections_screen.dart';
import 'screens/farmers_screen.dart';
import 'screens/batches_screen.dart';
import 'screens/reconciliation_screen.dart';

void main() {
  runApp(const DairyTraceApp());
}

class DairyTraceApp extends StatelessWidget {
  const DairyTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DairyTrace',

      debugShowCheckedModeBanner: false,

      initialRoute: AppRoutes.login,

      routes: {
  AppRoutes.login: (context) => const LoginScreen(),
  AppRoutes.dashboard: (context) => const DashboardScreen(),
  AppRoutes.collections: (context) => const CollectionsScreen(),
  AppRoutes.farmers: (context) => const FarmersScreen(),
  AppRoutes.batches: (context) => const BatchesScreen(),
  AppRoutes.reconciliation: (context) =>
      const ReconciliationScreen(),
},
    );
  }
}