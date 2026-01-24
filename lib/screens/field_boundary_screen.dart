import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/gps_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/header_widget.dart';
import '../widgets/mock_map_view.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';

class FieldBoundaryScreen extends StatefulWidget {
  const FieldBoundaryScreen({super.key});

  @override
  State<FieldBoundaryScreen> createState() => _FieldBoundaryScreenState();
}

class _FieldBoundaryScreenState extends State<FieldBoundaryScreen> {
  bool _boundaryDefined = false;
  int _requiredImages = 10;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Field Boundary')),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderWidget(
                title: 'Define Field Boundary',
                subtitle:
                    'Mark the boundary of your field for accurate assessment',
              ),

              const SizedBox(height: 24),

              // Mock map view
              Expanded(
                child: Card(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        // Mock map visualization with realistic UI
                        MockMapView(
                          boundaryDefined: _boundaryDefined,
                          requiredImages: _requiredImages,
                        ),

                        // Controls overlay
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _autoFetchBoundary,
                                  icon: const Icon(Icons.gps_fixed),
                                  label: const Text('Auto-Fetch'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _manualDrawBoundary,
                                  icon: const Icon(Icons.edit_location),
                                  label: const Text('Draw Manual'),
                                ),
                              ),
                            ],
                          ),
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
                            'Photo Requirements',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• 1 image required per 2 acres\n'
                        '• Minimum $_requiredImages images required\n'
                        '• Photos must be spread across the field\n'
                        '• Minimum 20 meters between captures',
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
                text: 'Proceed to Damage Capture',
                icon: Icons.arrow_forward,
                isEnabled: _boundaryDefined,
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

  void _autoFetchBoundary() {
    final appState = Provider.of<AppState>(context, listen: false);
    final landArea = appState.claimData.landArea;

    // Generate mock boundary
    final boundary = GPSService.generateMockBoundary(landArea);
    appState.setFieldBoundary(boundary);

    setState(() {
      _boundaryDefined = true;
      _requiredImages = appState.requiredCaptureCount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Field boundary auto-detected successfully'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _manualDrawBoundary() {
    // In real app, would allow manual drawing
    // For prototype, same as auto-fetch
    _autoFetchBoundary();
  }
}
