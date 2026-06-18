import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/route_remote_datasource.dart';
import '../../../data/datasources/task_remote_datasource.dart';
import '../../../data/models/task_model.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/map_bottom_panel.dart';
import 'widgets/task_info_card.dart';
import 'widgets/task_marker.dart';
import 'widgets/worker_marker.dart';

/// Astana city center — fallback when GPS is unavailable.
const _kAstanaCenter = LatLng(51.1801, 71.4460);
const _kDefaultZoom = 13.0;
const _kTaskZoom = 14.5;

/// How often the worker position is silently refreshed in the background.
const _kLocationRefreshSec = 20;

class MapScreen extends StatefulWidget {
  final List<TaskEntity> assignedTasks;
  final LatLng? workerLocation;

  const MapScreen({
    super.key,
    required this.assignedTasks,
    this.workerLocation,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final _mapController = MapController();
  final _routeDs = RouteRemoteDataSource();
  final _taskDs = TaskRemoteDataSource();

  // Location
  LatLng? _workerPos;
  double? _workerAccuracyM;

  // Task data
  List<TaskModel> _tasks = [];

  // Route
  List<LatLng> _routePoints = [];
  RouteResult? _routeResult;

  // Selection
  TaskEntity? _selectedTask;
  int _selectedIndex = 0;

  // Loading flags
  bool _locating = true;
  bool _routeLoading = false;
  bool _routeError = false;

  // Timers / animations
  Timer? _locationTimer;
  AnimationController? _cameraCtrl;

  //  Lifecycle ─

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _cameraCtrl?.dispose();
    _mapController.dispose();
    super.dispose();
  }

  //  Initialization 

  Future<void> _init() async {
    await _fetchTasks();
    await _fetchLocation();
    if (_workerPos != null && _tasks.isNotEmpty) {
      await _fetchRoute();
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitAll());
    }
    _startLocationTimer();
  }

  //  Data 

  Future<void> _fetchTasks() async {
    try {
      final models = await _taskDs.fetchTodaySchedule();
      if (mounted) setState(() => _tasks = models);
    } catch (_) {}
  }

  Future<void> _fetchLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) setState(() => _locating = false);
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _locating = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (mounted) {
        setState(() {
          _workerPos = LatLng(pos.latitude, pos.longitude);
          _workerAccuracyM = pos.accuracy;
          _locating = false;
        });
        _mapController.move(_workerPos!, _kDefaultZoom);
      }
    } catch (_) {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _fetchRoute() async {
    if (_workerPos == null) return;
    final stops = _tasks
        .where((t) => t.latitude != null && t.longitude != null)
        .map((t) => LatLng(t.latitude!, t.longitude!))
        .toList();
    if (stops.isEmpty) return;

    setState(() {
      _routeLoading = true;
      _routeError = false;
    });
    try {
      final result = await _routeDs.fetchMultiStopRoute(_workerPos!, stops);
      if (mounted) {
        setState(() {
          _routePoints = result.points;
          _routeResult = result;
          _routeLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _routeLoading = false;
          _routeError = true;
        });
      }
    }
  }

  //  Periodic location refresh 

  void _startLocationTimer() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(
      const Duration(seconds: _kLocationRefreshSec),
      (_) async {
        try {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.high),
          );
          if (mounted) {
            setState(() {
              _workerPos = LatLng(pos.latitude, pos.longitude);
              _workerAccuracyM = pos.accuracy;
            });
          }
        } catch (_) {}
      },
    );
  }

  //  Camera helpers 

  /// Smoothly animates the camera to [target] over 500 ms.
  void _animateTo(LatLng target, {double zoom = _kTaskZoom}) {
    _cameraCtrl?.stop();
    _cameraCtrl?.dispose();

    final fromCenter = _mapController.camera.center;
    final fromZoom = _mapController.camera.zoom;

    _cameraCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final curve =
        CurvedAnimation(parent: _cameraCtrl!, curve: Curves.easeInOutCubic);

    final latT =
        Tween<double>(begin: fromCenter.latitude, end: target.latitude);
    final lngT =
        Tween<double>(begin: fromCenter.longitude, end: target.longitude);
    final zoomT = Tween<double>(begin: fromZoom, end: zoom);

    _cameraCtrl!.addListener(() {
      if (mounted) {
        _mapController.move(
          LatLng(latT.evaluate(curve), lngT.evaluate(curve)),
          zoomT.evaluate(curve),
        );
      }
    });
    _cameraCtrl!.forward();
  }

  void _fitAll() {
    final points = <LatLng>[
      if (_workerPos != null) _workerPos!,
      ..._tasks
          .where((t) => t.latitude != null && t.longitude != null)
          .map((t) => LatLng(t.latitude!, t.longitude!)),
    ];

    if (points.length < 2) {
      if (_workerPos != null) _mapController.move(_workerPos!, _kDefaultZoom);
      return;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(64),
      ),
    );
  }

  //  Interaction ─

  void _selectTask(TaskModel task, int oneBasedIndex) {
    final entity = task.toEntity();
    setState(() {
      _selectedTask = entity;
      _selectedIndex = oneBasedIndex;
    });
    if (entity.latitude != null && entity.longitude != null) {
      _animateTo(LatLng(entity.latitude!, entity.longitude!));
    }
  }

  void _clearSelection() {
    if (_selectedTask != null) setState(() => _selectedTask = null);
  }

  //  Build ─

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tasksWithCoords = _tasks
        .where((t) => t.latitude != null && t.longitude != null)
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          //  Map layers 
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _workerPos ?? _kAstanaCenter,
              initialZoom: _kDefaultZoom,
              onTap: (_, __) => _clearSelection(),
            ),
            children: [
              // CartoDB Positron: clean light basemap, free, no API key
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.asar.field_worker',
                retinaMode: MediaQuery.devicePixelRatioOf(context) > 1,
              ),

              // Route polyline
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: AppColors.operationalBlue,
                      strokeWidth: 4.5,
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                  ],
                ),

              // GPS accuracy circle
              if (_workerPos != null && _workerAccuracyM != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _workerPos!,
                      radius: _workerAccuracyM!,
                      useRadiusInMeter: true,
                      color:
                          AppColors.operationalBlue.withValues(alpha: 0.10),
                      borderColor:
                          AppColors.operationalBlue.withValues(alpha: 0.30),
                      borderStrokeWidth: 1,
                    ),
                  ],
                ),

              // Worker position
              if (_workerPos != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _workerPos!,
                      width: 48,
                      height: 48,
                      child: const WorkerMarker(),
                    ),
                  ],
                ),

              // Task pins
              MarkerLayer(
                markers: tasksWithCoords.asMap().entries.map((e) {
                  final t = e.value;
                  final entity = t.toEntity();
                  final isSelected = _selectedTask?.id == entity.id;
                  return Marker(
                    point: LatLng(t.latitude!, t.longitude!),
                    width: 54,
                    height: 54,
                    child: GestureDetector(
                      onTap: () => _selectTask(t, e.key + 1),
                      child: TaskMarker(
                        task: entity,
                        index: e.key + 1,
                        isSelected: isSelected,
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Attribution required by CartoDB / OSM
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© CartoDB'),
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          //  Top chips ─
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  _MapChip(
                    icon: _locating
                        ? Icons.gps_not_fixed
                        : Icons.my_location_rounded,
                    label: _locating ? l.locating : l.myLocation,
                    onTap: _workerPos != null
                        ? () => _animateTo(_workerPos!, zoom: 15)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  if (_routeLoading)
                    _MapChip(
                      icon: Icons.route_outlined,
                      label: l.loadingRoute,
                    )
                  else if (_routeResult != null && !_routeError)
                    _MapChip(
                      icon: Icons.route_outlined,
                      label:
                          '${_routeResult!.distanceLabel} · ${_routeResult!.durationLabel}',
                    )
                  else if (_routeError)
                    _MapChip(
                      icon: Icons.warning_amber_rounded,
                      label: 'Route error — tap to retry',
                      onTap: _fetchRoute,
                    ),
                ],
              ),
            ),
          ),

          //  FABs (fit-all + center-on-me) — top-right gutter ─
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 12, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MapFab(
                      icon: Icons.fit_screen_rounded,
                      tooltip: 'Fit all',
                      onTap: _fitAll,
                    ),
                    const SizedBox(height: 8),
                    _MapFab(
                      icon: Icons.my_location_rounded,
                      tooltip: l.myLocation,
                      onTap: _workerPos != null
                          ? () => _animateTo(_workerPos!, zoom: 15)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),

          //  Selected task card 
          if (_selectedTask != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 220,
              child: TaskInfoCard(
                key: ValueKey(_selectedTask!.id),
                task: _selectedTask!,
                taskIndex: _selectedIndex,
                workerLocation: _workerPos,
              ),
            ),

          //  Bottom panel 
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.10,
            maxChildSize: 0.55,
            builder: (_, scrollCtrl) => MapBottomPanel(
              tasks: _tasks,
              routeResult: _routeResult,
              routeLoading: _routeLoading,
              routeError: _routeError,
              scrollController: scrollCtrl,
              onTaskTap: _selectTask,
              onRetryRoute: _fetchRoute,
            ),
          ),
        ],
      ),
    );
  }
}

//  Shared overlay widgets 

class _MapChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MapChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 8),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.operationalBlue),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'IBMPlexSans',
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _MapFab({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Color(0x22000000), blurRadius: 8),
            ],
          ),
          child: Icon(
            icon,
            size: 18,
            color: onTap != null
                ? AppColors.operationalBlue
                : AppColors.onSurfaceMuted,
          ),
        ),
      ),
    );
  }
}
