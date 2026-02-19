import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:provider/provider.dart';
import '../models/claim_data.dart';
import '../providers/app_state.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/gps_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/header_widget.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';

class FieldBoundaryScreen extends StatefulWidget {
  const FieldBoundaryScreen({super.key});

  @override
  State<FieldBoundaryScreen> createState() => _FieldBoundaryScreenState();
}

class _FieldBoundaryScreenState extends State<FieldBoundaryScreen> {
  bool _boundaryDefined = false;
  int _requiredImages = 3;
  bool _isLoading = false;
  bool _isDrawingMode = false; // Manual draw mode active

  // Map controller and GPS location
  final MapController _mapController = MapController();
  ll.LatLng _center = ll.LatLng(18.5204, 73.8567);
  List<ll.LatLng> _boundaryPoints = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  void _initLocation() async {
    final location = await GPSService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _center = ll.LatLng(location.latitude, location.longitude);
      });
      try {
        _mapController.move(_center, 16.0);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final t = AppLocalizations(locale.languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(t.get('field_boundary'))),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderWidget(
                title: t.get('define_boundary'),
                subtitle: t.get('field_boundary'),
              ),

              const SizedBox(height: 24),

              // Real OpenStreetMap view
              Expanded(
                child: Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        // OpenStreetMap
                        _buildOSMMap(),

                        // Drawing mode banner
                        if (_isDrawingMode)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              color: AppTheme.accentColor.withOpacity(0.9),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.touch_app,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${t.get('boundary_points_status')} (${_boundaryPoints.length} ${t.get('points_placed')}, ${t.get('need_3_plus')})',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Boundary defined badge
                        if (_boundaryDefined && !_isDrawingMode)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    t.get('boundary_defined'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // GPS status badge
                        if (!_isDrawingMode)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: GPSService.isRealGPS
                                    ? Colors.green
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    GPSService.isRealGPS
                                        ? Icons.gps_fixed
                                        : Icons.gps_not_fixed,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    GPSService.isRealGPS
                                        ? t.get('gps_status')
                                        : t.get('demo_mode'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Bottom controls — changes based on mode
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: _isDrawingMode
                              ? _buildDrawingControls()
                              : _buildNormalControls(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Capture requirements info
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.camera_alt, color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Text(
                            t.get('photo_requirements'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• ${t.get('photo_req_1')}\n'
                        '• ${t.get('minimum_prefix')} $_requiredImages ${t.get('photo_req_2')}\n'
                        '• ${t.get('photo_req_3')}\n'
                        '• ${t.get('photo_req_4')}',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Proceed button
              CustomButton(
                text: t.get('proceed_capture'),
                icon: Icons.arrow_forward,
                isEnabled: _boundaryDefined && !_isDrawingMode,
                onPressed: () {
                  Navigator.pushNamed(context, '/guided-capture');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Normal mode controls: Auto-Fetch and Draw Manual buttons
  Widget _buildNormalControls() {
    final t = AppLocalizations(
      Provider.of<LocaleProvider>(context, listen: false).languageCode,
    );
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _autoFetchBoundary,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.gps_fixed),
            label: Text(_isLoading ? t.get('detecting') : t.get('auto_fetch')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _startManualDraw,
            icon: const Icon(Icons.edit_location),
            label: Text(t.get('draw_manual')),
          ),
        ),
      ],
    );
  }

  /// Drawing mode controls: Undo, Cancel, Done
  Widget _buildDrawingControls() {
    final t = AppLocalizations(
      Provider.of<LocaleProvider>(context, listen: false).languageCode,
    );
    return Row(
      children: [
        // Undo last point
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _boundaryPoints.isEmpty ? null : _undoLastPoint,
            icon: const Icon(Icons.undo),
            label: Text(t.get('undo_action')),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
        ),
        const SizedBox(width: 8),
        // Cancel drawing
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _cancelDraw,
            icon: const Icon(Icons.close),
            label: Text(t.get('cancel_action')),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ),
        const SizedBox(width: 8),
        // Done — finalize boundary (need 3+ points)
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _boundaryPoints.length >= 3 ? _finalizeDraw : null,
            icon: const Icon(Icons.check),
            label: Text(t.get('done')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Build the OpenStreetMap widget
  Widget _buildOSMMap() {
    if (kIsWeb) {
      return Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                AppLocalizations(
                  Provider.of<LocaleProvider>(
                    context,
                    listen: false,
                  ).languageCode,
                ).get('map_demo'),
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _center,
        initialZoom: 16.0,
        onTap: _isDrawingMode ? _onMapTap : null,
      ),
      children: [
        // OpenStreetMap tile layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.flutter_application_1',
        ),

        // Boundary polygon (show when 3+ points)
        if (_boundaryPoints.length >= 3)
          PolygonLayer(
            polygons: [
              Polygon(
                points: _boundaryPoints,
                color: AppTheme.accentColor.withOpacity(0.2),
                borderStrokeWidth: 3.0,
                borderColor: AppTheme.primaryColor,
              ),
            ],
          ),

        // Boundary point markers (numbered)
        if (_boundaryPoints.isNotEmpty)
          MarkerLayer(
            markers: [
              for (int i = 0; i < _boundaryPoints.length; i++)
                Marker(
                  point: _boundaryPoints[i],
                  width: 30,
                  height: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

        // Current location marker
        MarkerLayer(
          markers: [
            Marker(
              point: _center,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.my_location,
                color: Colors.blue,
                size: 36,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Map tap handler for manual drawing ──

  void _onMapTap(TapPosition tapPosition, ll.LatLng point) {
    setState(() {
      _boundaryPoints.add(point);
    });
  }

  // ── Manual draw controls ──

  void _startManualDraw() {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final t = AppLocalizations(locale.languageCode);

    setState(() {
      _isDrawingMode = true;
      _boundaryDefined = false;
      _boundaryPoints = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.get('boundary_points_info')),
        backgroundColor: AppTheme.accentColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _undoLastPoint() {
    if (_boundaryPoints.isNotEmpty) {
      setState(() {
        _boundaryPoints.removeLast();
      });
    }
  }

  void _cancelDraw() {
    setState(() {
      _isDrawingMode = false;
      _boundaryPoints = [];
    });
  }

  void _finalizeDraw() {
    if (_boundaryPoints.length < 3) return;

    final appState = Provider.of<AppState>(context, listen: false);

    // Convert flutter_map points to app model
    final modelPoints = _boundaryPoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    // Calculate area from the polygon (approximate)
    double area = _calculatePolygonArea(_boundaryPoints);
    // If user entered an area in claim details, use that instead
    double landArea = appState.claimData.landArea;
    if (landArea <= 0) {
      landArea = area;
    }

    final boundary = FieldBoundary(points: modelPoints, areaInAcres: landArea);
    appState.setFieldBoundary(boundary);

    setState(() {
      _isDrawingMode = false;
      _boundaryDefined = true;
      _requiredImages = appState.requiredCaptureCount;
    });

    // Fit map to boundary
    try {
      final bounds = LatLngBounds.fromPoints(_boundaryPoints);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    } catch (_) {}

    final t = AppLocalizations(
      Provider.of<LocaleProvider>(context, listen: false).languageCode,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${t.get('boundary_defined')} • ${_boundaryPoints.length} ${t.get('points_placed')} • $_requiredImages ${t.get('photo_req_2')}',
        ),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  /// Approximate polygon area in acres using Shoelace formula
  double _calculatePolygonArea(List<ll.LatLng> points) {
    if (points.length < 3) return 0;
    double area = 0;
    int n = points.length;
    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      // Convert to meters first
      double xi =
          points[i].longitude * 111320 * cos(points[i].latitude * pi / 180);
      double yi = points[i].latitude * 110540;
      double xj =
          points[j].longitude * 111320 * cos(points[j].latitude * pi / 180);
      double yj = points[j].latitude * 110540;
      area += xi * yj - xj * yi;
    }
    area = area.abs() / 2.0;
    // Convert sq meters to acres (1 acre = 4046.86 sq meters)
    return area / 4046.86;
  }

  // ── Auto-fetch boundary ──

  void _autoFetchBoundary() async {
    setState(() {
      _isLoading = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    final landArea = appState.claimData.landArea;

    // Generate boundary centered on real GPS location
    final boundary = await GPSService.generateBoundary(landArea);
    appState.setFieldBoundary(boundary);

    // Convert to flutter_map LatLng for polygon display
    final mapPoints = boundary.points
        .map((p) => ll.LatLng(p.latitude, p.longitude))
        .toList();

    setState(() {
      _boundaryDefined = true;
      _boundaryPoints = mapPoints;
      _requiredImages = appState.requiredCaptureCount;
      _isLoading = false;
    });

    // Move map to show the boundary
    if (_boundaryPoints.isNotEmpty) {
      try {
        final bounds = LatLngBounds.fromPoints(_boundaryPoints);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
        );
      } catch (_) {}
    }

    if (mounted) {
      final locale = Provider.of<LocaleProvider>(context, listen: false);
      final t = AppLocalizations(locale.languageCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.get('boundary_auto_success')),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }
}
