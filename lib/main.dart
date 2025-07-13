import 'package:arloop/bloc/auth/authentication_bloc.dart';
import 'package:arloop/router/router.dart';
import 'package:arloop/services/google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/theme_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Google Auth Service
  final googleAuthService = GoogleAuthService();
  await googleAuthService.initialize();

  if (kDebugMode) {
    final clientId = dotenv.env["CLIENT_ID"];
    print("Client ID loaded: ${clientId?.substring(0, 10)}...");
  }

  runApp(ArLoopApp(googleAuthService: googleAuthService));
}

class ArLoopApp extends StatelessWidget {
  final GoogleAuthService? googleAuthService;

  const ArLoopApp({super.key, this.googleAuthService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthenticationBloc()),
        // Add other providers here
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
