import 'dart:convert';
import 'dart:math';
import '../models/bus_stop_model.dart';
import '../models/bus_location_model.dart';
import '../bus_stops_data.dart'; // O seu arquivo de dados antigos

class MockBusRepository {
  List<BusLocationModel> _mockBuses = [
    BusLocationModel(
      licensePlate: "bus1", busStatus: "circulating", 
      latitude: -21.77560, longitude: -43.37050, 
      timestamp: DateTime.now(), speed: 20.0, headingTowards: 0.0
    ),
    BusLocationModel(
      licensePlate: "bus2", busStatus: "circulating", 
      latitude: -21.77210, longitude: -43.36890, 
      timestamp: DateTime.now(), speed: 20.0, headingTowards: 0.0
    ),
    BusLocationModel(
      licensePlate: "bus3", busStatus: "circulating", 
      latitude: -21.77800, longitude: -43.37150, 
      timestamp: DateTime.now(), speed: 20.0, headingTowards: 0.0
    ),
  ];

  final Random _random = Random();

  Future<List<BusStopModel>> getBusStops() async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    final parsedJson = jsonDecode(busStopsJsonData);
    final List<dynamic> stopsList = parsedJson['busStops'];
    return stopsList.map((json) => BusStopModel.fromJson(json)).toList();
  }

  Future<List<BusLocationModel>> getLiveBuses() async {
    // Simula o movimento aleatório dos mockados
    _mockBuses = _mockBuses.map((bus) {
      return bus.copyWith(
        latitude: bus.latitude + (_random.nextDouble() - 0.5) * 0.00015,
        longitude: bus.longitude + (_random.nextDouble() - 0.5) * 0.00015,
      );
    }).toList();
    
    return _mockBuses;
  }
}