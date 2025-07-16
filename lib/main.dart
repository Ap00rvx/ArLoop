import 'package:arloop/bloc/auth/authentication_bloc.dart';
import 'package:arloop/bloc/store_owner/store_owner_bloc.dart';
import 'package:arloop/router/router.dart';
import 'package:arloop/services/firebase_google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/theme_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase Google Auth Service
  final firebaseGoogleAuthService = FirebaseGoogleAuthService();
  await firebaseGoogleAuthService.initialize();

  if (kDebugMode) {
    final clientId = dotenv.env["CLIENT_ID"];
    print("Client ID loaded: ${clientId?.substring(0, 10)}...");
  }
  // remove all token for testing
  // await FlutterSecureStorage().deleteAll();
  runApp(ArLoopApp(firebaseGoogleAuthService: firebaseGoogleAuthService));
}

class ArLoopApp extends StatelessWidget {
  final FirebaseGoogleAuthService? firebaseGoogleAuthService;

  const ArLoopApp({super.key, this.firebaseGoogleAuthService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthenticationBloc()),
        BlocProvider(create: (context) => StoreOwnerBloc()),

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
