import 'package:latlong2/latlong.dart';

class BusStopModel {
  final String id;
  final String longName;
  final String shortName;
  final double latitude;
  final double longitude;
  final bool isActive;

  BusStopModel({
    required this.id,
    required this.longName,
    required this.shortName,
    required this.latitude,
    required this.longitude,
    this.isActive = true,
  });

  factory BusStopModel.fromJson(Map<String, dynamic> json) {
    // Tenta ler o formato do Vapor primeiro (position array), senão cai pro formato antigo
    final position = json['position'] as List<dynamic>?;
    
    return BusStopModel(
      id: json['id'].toString(),
      longName: json['longName'] ?? json['parada'] ?? 'Parada Desconhecida',
      shortName: json['shortName'] ?? '',
      latitude: position != null ? position[0] : json['latitude'],
      longitude: position != null ? position[1] : json['longitude'],
      isActive: json['isActive'] ?? true,
    );
  }

  LatLng get latLng => LatLng(latitude, longitude);
}