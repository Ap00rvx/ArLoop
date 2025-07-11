import 'package:arloop/bloc/auth/authentication_bloc.dart';
import 'package:arloop/router/router.dart';
import 'package:arloop/services/google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/theme_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final client = dotenv.env["CLIENT_ID"];
  print("Client ID: $client");
  // Initialize Google Auth Service
  await GoogleAuthService().initialize();
  runApp(const ArLoopApp());
}

class ArLoopApp extends StatelessWidget {
  const ArLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
     providers: [
        BlocProvider(
          create: (context) => AuthenticationBloc(),
        ),
        // Add other
     ],
      child: MaterialApp.router(
        routerConfig: appRouter,
        title: 'ArLoop',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
