import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../../../l10n/app_localizations.dart';

/// Shows a bottom sheet for picking an external navigation app.
/// Falls back to browser via [MapLauncher.open] if the native app is absent.
Future<void> showNavigationSheet(
  BuildContext context, {
  required double lat,
  required double lng,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _NavigationSheet(lat: lat, lng: lng),
  );
}

class _NavigationSheet extends StatelessWidget {
  final double lat;
  final double lng;

  const _NavigationSheet({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l.openNavigationIn,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _NavTile(
              label: 'Google Maps',
              hint: 'maps.google.com',
              color: const Color(0xFF4285F4),
              icon: Icons.map_rounded,
              onTap: () {
                Navigator.pop(context);
                MapLauncher.open(lat, lng, 'google');
              },
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            _NavTile(
              label: '2GIS',
              hint: '2gis.com',
              color: const Color(0xFF00A84F),
              icon: Icons.location_city_rounded,
              onTap: () {
                Navigator.pop(context);
                MapLauncher.open(lat, lng, '2gis');
              },
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            _NavTile(
              label: 'Yandex Maps',
              hint: 'maps.yandex.ru',
              color: const Color(0xFFFC3F1D),
              icon: Icons.navigation_rounded,
              onTap: () {
                Navigator.pop(context);
                MapLauncher.open(lat, lng, 'yandex');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final String hint;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _NavTile({
    required this.label,
    required this.hint,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        hint,
        style: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 12,
          color: AppColors.onSurfaceMuted,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.onSurfaceMuted,
        size: 20,
      ),
    );
  }
}
