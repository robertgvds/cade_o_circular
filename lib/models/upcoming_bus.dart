import 'package:latlong2/latlong.dart';

class UpcomingBus {
  final String id;
  final String name;
  final int arrivalTime;
  final double latitude;
  final double longitude;

  UpcomingBus({
    required this.id,
    required this.name,
    required this.arrivalTime,
    required this.latitude,
    required this.longitude,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  factory UpcomingBus.fromJson(Map<String, dynamic> json) {
    return UpcomingBus(
      id: json['id'],
      name: json['name'],
      arrivalTime: json['arrivalTime'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}