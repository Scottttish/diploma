import 'package:flutter/material.dart';
import 'package:asar_field_worker/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class MapLauncher {
  static Future<void> showPicker(BuildContext context, double lat, double lng) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.openNavigationIn ?? 'Open navigation in…',
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              MapLaunchButtons(lat: lat, lng: lng),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> open(double lat, double lng, String app) async {
    final uriStr = switch (app) {
      'google' => 'comgooglemaps://?daddr=$lat,$lng&directionsmode=driving',
      '2gis'   => 'dgis://2gis.ru/routeSearch/to/$lat,$lng/go',
      'yandex' => 'yandexmaps://maps.yandex.ru/?rtext=~$lat,$lng&rtt=auto',
      _        => '',
    };
    if (uriStr.isEmpty) return;
    final uri = Uri.parse(uriStr);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final web = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
      );
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }
}

class MapLaunchButtons extends StatelessWidget {
  final double lat;
  final double lng;

  const MapLaunchButtons({super.key, required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AppButton(
          label: 'Google',
          icon: Icons.map_outlined,
          color: const Color(0xFF4285F4),
          onTap: () => MapLauncher.open(lat, lng, 'google'),
        ),
        const SizedBox(width: 8),
        _AppButton(
          label: '2GIS',
          icon: Icons.location_on_outlined,
          color: const Color(0xFF00A84F),
          onTap: () => MapLauncher.open(lat, lng, '2gis'),
        ),
        const SizedBox(width: 8),
        _AppButton(
          label: 'Yandex',
          icon: Icons.navigation_outlined,
          color: const Color(0xFFFC3F1D),
          onTap: () => MapLauncher.open(lat, lng, 'yandex'),
        ),
      ],
    );
  }
}

class _AppButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AppButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
                fontFamily: 'IBMPlexSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
