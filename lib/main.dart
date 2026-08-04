import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/env/env.dart';
import 'core/theme/app_theme.dart';
import 'screens/login/login_screen.dart';
import 'services/attendance_service.dart';
import 'services/auth_service.dart';
import 'services/http_attendance_service.dart';
import 'services/http_auth_service.dart';
import 'services/http_leave_service.dart';
import 'services/http_settings_service.dart';
import 'services/leave_service.dart';
import 'services/settings_service.dart';
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

  // Swap the mock services for the real Node.js/Express backend
  // (bumdesma-backend). Comment these four lines out to fall back to the
  // in-memory mocks, e.g. for UI work with no backend running.
  AuthService.instance = HttpAuthService();
  AttendanceService.instance = HttpAttendanceService();
  LeaveService.instance = HttpLeaveService();
  SettingsService.instance = HttpSettingsService();

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
