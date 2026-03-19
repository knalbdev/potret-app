import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddStoryProvider extends ChangeNotifier {
  File? _selectedImage;
  LatLng? _selectedLocation;

  File? get selectedImage => _selectedImage;
  LatLng? get selectedLocation => _selectedLocation;

  void setImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

  void setLocation(LatLng? location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void reset() {
    _selectedImage = null;
    _selectedLocation = null;
  }
}
