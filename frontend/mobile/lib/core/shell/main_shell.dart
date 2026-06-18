import 'package:flutter/material.dart';
import 'package:asar_field_worker/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/analytics')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final index = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.operationalBlue,
        unselectedItemColor: AppColors.onSurfaceMuted,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 11,
        ),
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/schedule');
            case 1:
              context.go('/map');
            case 2:
              context.go('/analytics');
            case 3:
              context.go('/settings');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.view_agenda_outlined),
            activeIcon: const Icon(Icons.view_agenda_rounded),
            label: l.navSchedule,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map_rounded),
            label: l.navRoute,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart_outlined),
            activeIcon: const Icon(Icons.bar_chart_rounded),
            label: l.navAnalytics,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person_rounded),
            label: l.navSettings,
          ),
        ],
      ),
    );
  }
}
