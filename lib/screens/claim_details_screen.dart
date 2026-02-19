import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import '../models/claim_data.dart';
import '../models/damage_type.dart';
import '../providers/app_state.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/gps_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_button.dart';
import '../widgets/header_widget.dart';

class ClaimDetailsScreen extends StatefulWidget {
  const ClaimDetailsScreen({super.key});

  @override
  State<ClaimDetailsScreen> createState() => _ClaimDetailsScreenState();
}

class _ClaimDetailsScreenState extends State<ClaimDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmerNameController = TextEditingController();
  final _policyIdController = TextEditingController();
  final _landAreaController = TextEditingController();
  final _villageController = TextEditingController();

  String _selectedCropType = 'Rice';
  String _village = '';
  bool _isLoadingLocation = true;

  final List<String> _cropTypes = [
    'Rice',
    'Wheat',
    'Cotton',
    'Sugarcane',
    'Maize',
    'Pulses',
    'Oilseeds',
  ];

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  void _fetchLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    // Get real GPS location (triggers permission request on mobile)
    final location = await GPSService.getCurrentLocation();

    // Get real village/locality name via reverse geocoding
    String villageName = 'Unknown';
    try {
      if (!kIsWeb) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          // Try subLocality first (village), then locality (town/city)
          villageName = place.subLocality?.isNotEmpty == true
              ? place.subLocality!
              : place.locality?.isNotEmpty == true
              ? place.locality!
              : place.subAdministrativeArea ?? 'Unknown';
        }
      } else {
        villageName = GPSService.getVillageName(location);
      }
    } catch (e) {
      villageName = GPSService.getVillageName(location);
    }

    if (mounted) {
      setState(() {
        _village = villageName;
        _isLoadingLocation = false;
        _villageController.text = villageName;
      });

      final locale = Provider.of<LocaleProvider>(context, listen: false);
      final t = AppLocalizations(locale.languageCode);

      // Show GPS status on screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            GPSService.isRealGPS
                ? '✅ ${t.get('gps_locked')}: $villageName (${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)})'
                : '⚠️ ${GPSService.lastStatus}',
          ),
          backgroundColor: GPSService.isRealGPS ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final t = AppLocalizations(locale.languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(t.get('claim_details'))),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              HeaderWidget(
                title: t.get('claim_details'),
                subtitle: t.get('farmer_desc'),
              ),

              const SizedBox(height: 24),

              // Cause of Crop Damage - NEW DROPDOWN
              DropdownButtonFormField<DamageType>(
                value: appState.claimData.damageType,
                decoration: InputDecoration(
                  labelText: '${t.get('damage_type')} *',
                  hintText: t.get('damage_type'),
                  prefixIcon: const Icon(Icons.warning_amber_rounded),
                ),
                items: DamageType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.getLocalizedName(t)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    // Get appState from Provider
                    Provider.of<AppState>(
                      context,
                      listen: false,
                    ).claimData.damageType = value;
                    setState(() {}); // Rebuild to show new value
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return t.get('select_damage_type');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Farmer Name
              TextFormField(
                controller: _farmerNameController,
                decoration: InputDecoration(
                  labelText: '${t.get('farmer_name')} *',
                  hintText: t.get('farmer_name'),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.get('enter_farmer_name');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Policy ID / Aadhaar
              TextFormField(
                controller: _policyIdController,
                decoration: InputDecoration(
                  labelText: '${t.get('policy_id_aadhaar')} *',
                  hintText: t.get('enter_policy_aadhaar'),
                  prefixIcon: const Icon(Icons.badge),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.get('enter_policy_id');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Crop Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCropType,
                decoration: InputDecoration(
                  labelText: '${t.get('crop_type_label')} *',
                  prefixIcon: const Icon(Icons.grass),
                ),
                items: _cropTypes.map((crop) {
                  return DropdownMenuItem(
                    value: crop,
                    child: Text(t.get('crop_${crop.toLowerCase()}')),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCropType = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Land Area
              TextFormField(
                controller: _landAreaController,
                decoration: InputDecoration(
                  labelText: '${t.get('land_area_label')} *',
                  hintText: t.get('land_area_hint'),
                  prefixIcon: const Icon(Icons.landscape),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.get('enter_land_area');
                  }
                  final area = double.tryParse(value);
                  if (area == null || area <= 0) {
                    return t.get('valid_area');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Village (auto-filled from GPS reverse geocoding)
              TextFormField(
                controller: _villageController,
                decoration: InputDecoration(
                  labelText: t.get('village_label'),
                  hintText: t.get('auto_detected_gps'),
                  prefixIcon: const Icon(Icons.location_on),
                  suffixIcon: _isLoadingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.check_circle, color: Colors.green),
                ),
                enabled: false,
              ),

              const SizedBox(height: 32),

              // Info card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.get('gps_fraud_info'),
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit button
              CustomButton(
                text: t.get('define_boundary'),
                icon: Icons.arrow_forward,
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);

      appState.updateClaimData(
        ClaimData(
          farmerName: _farmerNameController.text,
          policyId: _policyIdController.text,
          cropType: _selectedCropType,
          landArea: double.parse(_landAreaController.text),
          village: _village,
          damageType: appState.claimData.damageType, // Preserve user selection
        ),
      );

      Navigator.pushNamed(context, '/field-boundary');
    }
  }

  @override
  void dispose() {
    _farmerNameController.dispose();
    _policyIdController.dispose();
    _landAreaController.dispose();
    _villageController.dispose();
    super.dispose();
  }
}
