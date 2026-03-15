import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/dashboard_screen.dart';
import 'constants/app_constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KhaataApp());
}

class KhaataApp extends StatelessWidget {
  const KhaataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Khaata',
          themeMode: settings.themeMode,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          home: const DashboardScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final cs = ColorScheme.fromSeed(
    seedColor: AppConstants.primaryColor,
    brightness: brightness,
    primary: AppConstants.primaryColor,
    secondary: AppConstants.incomeColor,
    error: AppConstants.expenseColor,
  );

  return ThemeData(
    colorScheme: cs,
    brightness: brightness,
    useMaterial3: true,
    scaffoldBackgroundColor:
        isDark ? AppColors.dark.background : AppColors.light.background,
    extensions: [isDark ? AppColors.dark : AppColors.light],
    cardTheme: CardThemeData(
      elevation: 0,
      color: isDark ? AppColors.dark.surface : AppColors.light.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppConstants.primaryColor, width: 2),
      ),
      filled: true,
      fillColor:
          isDark ? AppColors.dark.background : AppColors.light.background,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark
          ? AppColors.dark.surface
          : const Color(0xFF1A202C),
      contentTextStyle: TextStyle(
          color: isDark ? AppColors.dark.text : Colors.white),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor:
          isDark ? AppColors.dark.surface : AppColors.light.surface,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
