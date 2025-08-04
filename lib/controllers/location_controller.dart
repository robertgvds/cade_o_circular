import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationController {
  Future<bool> checkPermissions(Function(String) onError) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onError('Serviço de localização desativado.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        onError('Permissão negada.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      onError('Permissão permanentemente negada.');
      return false;
    }

    return true;
  }

  Stream<LatLng> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).map((position) => LatLng(position.latitude, position.longitude));
  }
}
