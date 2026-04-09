import 'package:latlong2/latlong.dart';

class BusLocationModel {
  final String licensePlate;
  final String busStatus;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double speed;
  final double headingTowards;
  
  // Propriedade calculada no app, não vem da API
  final int arrivalTime; 

  BusLocationModel({
    required this.licensePlate,
    required this.busStatus,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.speed,
    required this.headingTowards,
    this.arrivalTime = 0,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  BusLocationModel copyWith({int? arrivalTime, double? latitude, double? longitude}) {
    return BusLocationModel(
      licensePlate: licensePlate,
      busStatus: busStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp,
      speed: speed,
      headingTowards: headingTowards,
      arrivalTime: arrivalTime ?? this.arrivalTime,
    );
  }
}