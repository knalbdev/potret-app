import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, this.initialLocation});

  final LatLng? initialLocation;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const LatLng _defaultLocation = LatLng(-6.2088, 106.8456); // Jakarta

  LatLng? _pickedLocation;
  String? _address;
  bool _fetchingAddress = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _pickedLocation = widget.initialLocation;
      _fetchAddress(widget.initialLocation!);
    }
  }

  Future<void> _fetchAddress(LatLng position) async {
    setState(() {
      _fetchingAddress = true;
      _address = null;
    });
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.country,
        ].where((s) => s != null && s.isNotEmpty).toList();
        setState(() => _address = parts.join(', '));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _address = null);
      }
    } finally {
      if (mounted) setState(() => _fetchingAddress = false);
    }
  }

  void _onMapTap(LatLng position) {
    setState(() => _pickedLocation = position);
    _fetchAddress(position);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pickLocation),
        actions: [
          if (_pickedLocation != null)
            TextButton(
              onPressed: () => context.pop(_pickedLocation),
              child: Text(
                l10n.confirm,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation ?? _defaultLocation,
              zoom: 14,
            ),
            onTap: _onMapTap,
            markers: _pickedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('picked'),
                      position: _pickedLocation!,
                      infoWindow: InfoWindow(
                        title: _address ?? l10n.fetchingAddress,
                      ),
                    ),
                  }
                : {},
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),
          // Instruction banner
          if (_pickedLocation == null)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Material(
                borderRadius: BorderRadius.circular(12),
                elevation: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.creamLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.touch_app_outlined,
                        color: AppColors.warmGold,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.tapToPickLocation,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Address info panel
          if (_pickedLocation != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Material(
                borderRadius: BorderRadius.circular(16),
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.warmGoldLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.warmGold,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _fetchingAddress
                            ? Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.warmGold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.fetchingAddress,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                _address ?? l10n.noAddress,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
