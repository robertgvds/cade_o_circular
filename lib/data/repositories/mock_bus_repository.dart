import 'dart:convert';
import 'package:latlong2/latlong.dart';
import '../models/bus_stop_model.dart';
import '../models/bus_location_model.dart';

import '../bus_route_data.dart';
import '../bus_stops_data.dart';
class MockBusRepository {
  final List<double> _busProgresses = [0.0, 5.0, 10.0];

  List<BusLocationModel> _mockBuses = [
    BusLocationModel(
      licensePlate: "bus1", busStatus: "circulating", 
      latitude: 0, longitude: 0, 
      timestamp: DateTime.now(), speed: 20.0, headingTowards: 0.0
    ),
    BusLocationModel(
      licensePlate: "bus2", busStatus: "circulating", 
      latitude: 0, longitude: 0, 
      timestamp: DateTime.now(), speed: 20.0, headingTowards: 0.0
    ),
    BusLocationModel(
      licensePlate: "bus3", busStatus: "circulating", 
      latitude: 0, longitude: 0, 
      timestamp: DateTime.now(), speed: 20.0, headingTowards: 0.0
    ),
  ];

  Future<List<BusStopModel>> getBusStops() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final parsedJson = jsonDecode(busStopsJsonData);
    final List<dynamic> stopsList = parsedJson['busStops'];
    return stopsList.map((json) => BusStopModel.fromJson(json)).toList();
  }

  Future<List<BusLocationModel>> getLiveBuses() async {
    final route = busRoutePolyline;

    for (int i = 0; i < _mockBuses.length; i++) {
      // Avança um pouquinho a cada 1 segundo
      _busProgresses[i] = (_busProgresses[i] + 0.04) % route.length;

      double progress = _busProgresses[i];
      int currentIndex = progress.floor();
      int nextIndex = (currentIndex + 1) % route.length;
      
      double fraction = progress - currentIndex;

      LatLng p1 = route[currentIndex];
      LatLng p2 = route[nextIndex];

      double newLat = p1.latitude + (p2.latitude - p1.latitude) * fraction;
      double newLng = p1.longitude + (p2.longitude - p1.longitude) * fraction;

      _mockBuses[i] = _mockBuses[i].copyWith(
        latitude: newLat,
        longitude: newLng,
      );
    }
    
    return _mockBuses;
  }
}