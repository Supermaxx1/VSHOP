import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';

import 'providers/auth_provider.dart';
// REMOVED: import 'providers/inventory_provider.dart';
// REMOVED: import 'providers/sales_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/printer_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_colors.dart';
import 'utils/app_constants.dart';
import 'firebase_options.dart';
import 'services/database_service.dart'; // ADDED: Our DatabaseService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase FIRST
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    // Initialize Firebase Database with status check
    bool dbStatus = await DatabaseService.checkDatabaseStatus();
    if (dbStatus) {
      print('Database ready and accessible');
    } else {
      print('Database initialization issues detected');
    }

    // Initialize Hive local database
    await Hive.initFlutter();
    await Hive.openBox(AppConstants.settingsBox);
    await Hive.openBox(AppConstants.cacheBox);
    await Hive.openBox(AppConstants.offlineBox);
    print('Hive databases initialized');

    // Configure system UI - FORCE LIGHT MODE
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.dark, // DARK ICONS ON LIGHT STATUS BAR
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark, // DARK ICONS
      ),
    );

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    print('System UI configured');
  } catch (e) {
    print('Initialization error: $e');
  }

  runApp(const VShopApp());
}

class VShopApp extends StatelessWidget {
  const VShopApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // REMOVED: ChangeNotifierProvider(create: (_) => InventoryProvider()),
        // REMOVED: ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => PrinterProvider()),
      ],
      child: GetMaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(), // LIGHT THEME
        darkTheme: _buildLightTheme(), // FORCE LIGHT THEME FOR DARK MODE TOO
        themeMode: ThemeMode.light, // ALWAYS LIGHT MODE
        home: const SplashScreen(),
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light, // FORCE LIGHT
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        brightness: Brightness.light, // FORCE LIGHT
      ),
      scaffoldBackgroundColor: Colors.grey[50], // LIGHT GREY BACKGROUND
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ).apply(bodyColor: AppColors.textDark, displayColor: AppColors.textDark),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        color: Colors.white, // FORCE WHITE CARDS
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white, // FORCE WHITE INPUT BACKGROUND
      ),
    );
  }
}
