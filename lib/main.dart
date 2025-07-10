import 'package:arloop/router/router.dart';
import 'package:flutter/material.dart';
import 'theme/theme_data.dart';

void main() {
  runApp(const ArLoopApp());
}

class ArLoopApp extends StatelessWidget {
  const ArLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'ArLoop',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
    );
  }
}
