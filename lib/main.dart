import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/env/env.dart';
import 'core/theme/app_theme.dart';
import 'screens/login/login_screen.dart';
import 'state/attendance_provider.dart';
import 'state/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Loads MAPS_API_ANDROID / MAPS_API_IOS / API_BASE_URL / geofencing
  // defaults from the bundled .env (see pubspec.yaml assets).
  await Env.load();

  // Enables 'id_ID' locale for all DateFormat calls used across the app
  // (Riwayat, Dashboard, notification timestamps, scan result screens).
  await initializeDateFormatting('id_ID', null);

  runApp(const AbsensiBumdesmaApp());
}

class AbsensiBumdesmaApp extends StatelessWidget {
  const AbsensiBumdesmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: MaterialApp(
        title: 'Absensi BUMDESMA Podo Rukun LKD',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const LoginScreen(),
      ),
    );
  }
}
