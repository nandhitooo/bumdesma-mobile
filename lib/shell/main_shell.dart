import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/leave/leave_form_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/scan/scan_select_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // Urutan ditukar: Beranda, Izin, [Scan], Riwayat, Profil.
  final _pages = const [
    DashboardScreen(),
    LeaveFormScreen(),
    SizedBox.shrink(), // placeholder — Scan opens as a full-screen route
    HistoryScreen(),
    ProfileScreen(),
  ];

  void _onTap(int index) {
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ScanSelectScreen()),
      );
      return;
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onTap(2),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 3,
        child: const Icon(Icons.qr_code_scanner_rounded,
            color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavButton(
                icon: Icons.home_rounded,
                label: 'Beranda',
                selected: _index == 0,
                onTap: () => _onTap(0),
              ),
              _NavButton(
                icon: Icons.event_note_rounded,
                label: 'Izin',
                selected: _index == 1,
                onTap: () => _onTap(1),
              ),
              const SizedBox(width: 48), // space for the notched FAB
              _NavButton(
                icon: Icons.history_rounded,
                label: 'Riwayat',
                selected: _index == 3,
                onTap: () => _onTap(3),
              ),
              _NavButton(
                icon: Icons.person_rounded,
                label: 'Profil',
                selected: _index == 4,
                onTap: () => _onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                  horizontal: selected ? 10 : 0, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
