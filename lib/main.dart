import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'core/env/env.dart';
import 'core/theme/app_theme.dart';
import 'screens/login/login_screen.dart';
import 'services/attendance_service.dart';
import 'services/auth_service.dart';
import 'services/http_attendance_service.dart';
import 'services/http_auth_service.dart';
import 'services/http_leave_service.dart';
import 'services/http_notification_service.dart';
import 'services/http_settings_service.dart';
import 'services/leave_service.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'state/attendance_provider.dart';
import 'state/auth_provider.dart';
import 'state/notification_provider.dart';
import 'state/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.load();
  await initializeDateFormatting('id_ID', null);

  AuthService.instance = HttpAuthService();
  AttendanceService.instance = HttpAttendanceService();
  LeaveService.instance = HttpLeaveService();
  SettingsService.instance = HttpSettingsService();
  NotificationService.instance = HttpNotificationService();

  runApp(
    DevicePreview(
      // Set ke false kalau mau build rilis biasa tanpa frame device.
      enabled: true,
      builder: (context) => const AbsensiBumdesmaApp(),
    ),
  );
}

class AbsensiBumdesmaApp extends StatelessWidget {
  const AbsensiBumdesmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'BUMDESMA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        // Wajib ditambahkan agar DevicePreview bisa mengatur ukuran layar,
        // locale, dan builder-nya sendiri.
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        home: const LoginScreen(),
      ),
    );
  }
}
