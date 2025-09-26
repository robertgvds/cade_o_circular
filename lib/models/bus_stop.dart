import 'package:latlong2/latlong.dart';

class BusStop {
  final int id;
  final String parada;
  final double latitude;
  final double longitude;

  BusStop({
    required this.id,
    required this.parada,
    required this.latitude,
    required this.longitude,
  });

  // Construtor para criar um BusStop a partir de um mapa (JSON)
  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      id: json['id'],
      parada: json['parada'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  // Getter para facilitar o acesso à coordenada como um objeto LatLng
  LatLng get latLng => LatLng(latitude, longitude);
}