import 'dart:math';
import '../models/upcoming_bus.dart';

// Esta classe simula um serviço que fornece a localização em tempo real de todos os ônibus.
class LiveBusRepository {
  // Posições iniciais de todos os ônibus que estão rodando
  List<UpcomingBus> _buses = [
    UpcomingBus(id: "bus1", name: "Ônibus A", arrivalTime: 2, latitude: -21.77560, longitude: -43.37050),
    UpcomingBus(id: "bus2", name: "Ônibus B", arrivalTime: 8, latitude: -21.77210, longitude: -43.36890),
    UpcomingBus(id: "bus3", name: "Ônibus C", arrivalTime: 5, latitude: -21.77800, longitude: -43.37150),
    UpcomingBus(id: "bus4", name: "Ônibus D", arrivalTime: 12, latitude: -21.78250, longitude: -43.36800),
  ];

  final Random _random = Random();

  // Método para obter as localizações atuais de todos os ônibus
  List<UpcomingBus> getAllBuses() {
    // Em um app real, isso viria de uma API/WebSocket.
    // Aqui, vamos simular o movimento deles.
    _updateBusLocations();
    return _buses;
  }

  // Método privado para simular o movimento dos ônibus
  void _updateBusLocations() {
    _buses = _buses.map((bus) {
      // Move cada ônibus em uma direção aleatória por uma pequena distância
      final newLat = bus.latitude + (_random.nextDouble() - 0.5) * 0.00015;
      final newLng = bus.longitude + (_random.nextDouble() - 0.5) * 0.00015;
      
      return UpcomingBus(
        id: bus.id,
        name: bus.name,
        arrivalTime: max(1, bus.arrivalTime - 1), // O tempo de chegada diminui
        latitude: newLat,
        longitude: newLng,
      );
    }).toList();
  }
}