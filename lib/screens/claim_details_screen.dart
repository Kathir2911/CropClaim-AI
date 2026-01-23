import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/claim_data.dart';
import '../providers/app_state.dart';
import '../services/gps_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/header_widget.dart';
import '../widgets/auth_header.dart';

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

  String _selectedCropType = 'Rice';
  String _village = '';

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

  void _fetchLocation() {
    // Mock GPS fetch
    final location = GPSService.getMockLocation();
    setState(() {
      _village = GPSService.getVillageName(location);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Claim Details')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const HeaderWidget(
                title: 'Enter Claim Information',
                subtitle:
                    'Please provide accurate details for claim processing',
              ),

              const SizedBox(height: 24),

              // Farmer Name
              TextFormField(
                controller: _farmerNameController,
                decoration: const InputDecoration(
                  labelText: 'Farmer Name *',
                  hintText: 'Enter full name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter farmer name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Policy ID / Aadhaar
              TextFormField(
                controller: _policyIdController,
                decoration: const InputDecoration(
                  labelText: 'PMFBY Policy ID / Aadhaar *',
                  hintText: 'Enter policy ID or Aadhaar number',
                  prefixIcon: Icon(Icons.badge),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter policy ID or Aadhaar';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Crop Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCropType,
                decoration: const InputDecoration(
                  labelText: 'Crop Type *',
                  prefixIcon: Icon(Icons.grass),
                ),
                items: _cropTypes.map((crop) {
                  return DropdownMenuItem(value: crop, child: Text(crop));
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
                decoration: const InputDecoration(
                  labelText: 'Total Land Area (acres) *',
                  hintText: 'Enter area in acres',
                  prefixIcon: Icon(Icons.landscape),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter land area';
                  }
                  final area = double.tryParse(value);
                  if (area == null || area <= 0) {
                    return 'Please enter valid area';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Village (auto-filled)
              TextFormField(
                initialValue: _village,
                decoration: InputDecoration(
                  labelText: 'Village',
                  hintText: 'Auto-detected from GPS',
                  prefixIcon: const Icon(Icons.location_on),
                  suffixIcon: _village.isEmpty
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
                          'GPS coordinates are automatically captured to prevent fraud',
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
                text: 'Define Field Boundary',
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
    super.dispose();
  }
}
