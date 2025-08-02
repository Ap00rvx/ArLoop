import 'package:arloop/bloc/auth/authentication_bloc.dart';
import 'package:arloop/bloc/cart/cart_bloc.dart';
import 'package:arloop/bloc/location/location_bloc.dart';
import 'package:arloop/bloc/medicine/medicine_bloc.dart';
import 'package:arloop/bloc/cart/cart_bloc.dart';
import 'package:arloop/bloc/store_owner/store_owner_bloc.dart';
import 'package:arloop/languages/l10n/app_localizations.dart';
import 'package:arloop/router/router.dart';
import 'package:arloop/services/cart_service.dart';
import 'package:arloop/services/firebase_google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'bloc/shop/shop_bloc.dart';
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

  await FlutterSecureStorage().readAll().then((allTokens) {
    allTokens.forEach((key, value) {
      print("Key: $key, Value: $value");
    });
  });
  // await FlutterSecureStorage().deleteAll();
  // system orientation

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(ArLoopApp(firebaseGoogleAuthService: firebaseGoogleAuthService));
}

class ArLoopApp extends StatefulWidget {
  final FirebaseGoogleAuthService? firebaseGoogleAuthService;

  const ArLoopApp({super.key, this.firebaseGoogleAuthService});

  @override
  State<ArLoopApp> createState() => _ArLoopAppState();
}

class _ArLoopAppState extends State<ArLoopApp> {
  @override
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthenticationBloc()),
        BlocProvider(create: (context) => StoreOwnerBloc()),
        BlocProvider(create: (context) => ShopBloc()),
        BlocProvider(create: (context) => MedicineBloc()),
        BlocProvider(create: (context) => LocationBloc()),
        BlocProvider(create: (context) => CartBloc(cartService: CartService())),

        // Add other providers here
      ],
      child: MaterialApp.router(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'), // English
          Locale('hi'), // Hindi
        ],
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
