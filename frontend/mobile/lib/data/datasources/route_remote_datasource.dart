import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

/// Fetches driving routes from the public OSRM demo API (no API key required).
/// Supports both single-destination and multi-stop routes.
final class RouteRemoteDataSource {
  final Dio _osrm;

  RouteRemoteDataSource()
      : _osrm = Dio(BaseOptions(
          baseUrl: 'http://router.project-osrm.org',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ));

  /// Single-stop convenience wrapper.
  Future<RouteResult> fetchRoute(LatLng from, LatLng to) =>
      fetchMultiStopRoute(from, [to]);

  /// Builds a chained route: worker → stop[0] → stop[1] → … → stop[n-1].
  /// Stop order is preserved as received from the backend.
  Future<RouteResult> fetchMultiStopRoute(
    LatLng from,
    List<LatLng> stops,
  ) async {
    if (stops.isEmpty) {
      return const RouteResult(
          points: [], distanceMeters: 0, durationSeconds: 0);
    }

    final coordStr = [from, ...stops]
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');

    final response = await _osrm.get<Map<String, dynamic>>(
      '/route/v1/driving/$coordStr',
      queryParameters: {
        'overview': 'full',
        'geometries': 'geojson',
        'steps': 'false',
      },
    );

    final data = response.data!;
    if (data['code'] != 'Ok' || (data['routes'] as List).isEmpty) {
      return const RouteResult(
          points: [], distanceMeters: 0, durationSeconds: 0);
    }

    final route = (data['routes'] as List).first as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>;

    final coords = (geometry['coordinates'] as List).map((c) {
      final p = c as List;
      return LatLng((p[1] as num).toDouble(), (p[0] as num).toDouble());
    }).toList();

    return RouteResult(
      points: coords,
      distanceMeters: (route['distance'] as num).toDouble(),
      durationSeconds: (route['duration'] as num).toDouble(),
      stopCount: stops.length,
    );
  }
}

class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final int stopCount;

  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    this.stopCount = 1,
  });

  String get distanceLabel {
    if (distanceMeters < 1000) return '${distanceMeters.round()} m';
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  String get durationLabel {
    final mins = (durationSeconds / 60).round();
    if (mins < 60) return '$mins min';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }
}
