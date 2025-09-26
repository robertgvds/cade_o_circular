import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../data/bus_route_data.dart';
import '../data/live_bus_repository.dart';
// O import abaixo não é mais necessário para a função de ETA, mas pode ser usado em outros lugares.
// import '../data/upcoming_buses_data.dart'; 
import '../models/bus_stop.dart';
import '../models/upcoming_bus.dart';

class MapProvider with ChangeNotifier {
  // Dados do Mapa
  List<BusStop> _allBusStops = [];
  List<BusStop> _filteredBusStops = [];
  List<UpcomingBus> _liveBuses = [];
  final List<LatLng> _routePoints = busRoutePolyline; // Rota do ônibus

  // Estado da UI
  BusStop? _selectedStop;
  final Set<int> _favoriteStops = {}; // IDs das paradas favoritas

  // Repositório de dados em tempo real
  final LiveBusRepository _busRepo = LiveBusRepository();
  Timer? _busUpdateTimer;

  // Getters para a UI acessar os dados
  List<BusStop> get filteredBusStops => _filteredBusStops;
  List<UpcomingBus> get liveBuses => _liveBuses;
  List<LatLng> get routePoints => _routePoints;
  BusStop? get selectedStop => _selectedStop;
  Set<int> get favoriteStops => _favoriteStops;

  MapProvider(String busStopsJson) {
    _loadBusStops(busStopsJson);
    _startBusUpdates();
  }

  void _loadBusStops(String busStopsJson) {
    final parsedJson = jsonDecode(busStopsJson);
    final List<dynamic> stopsList = parsedJson['busStops'];
    _allBusStops = stopsList.map((json) => BusStop.fromJson(json)).toList();
    _filteredBusStops = List.from(_allBusStops);
    notifyListeners();
  }

  void _startBusUpdates() {
    _busUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _liveBuses = _busRepo.getAllBuses();
      notifyListeners();
    });
  }

  void updateFilteredStops(String query) {
    _filteredBusStops = _allBusStops
        .where((stop) => stop.parada.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void selectStop(BusStop stop) {
    _selectedStop = stop;
    notifyListeners();
  }

  void clearSelectedStop() {
    _selectedStop = null;
    notifyListeners();
  }

  void toggleFavoriteStop(BusStop stop, BuildContext context) {
    bool isFavorited = _favoriteStops.contains(stop.id);
    if (isFavorited) {
      _favoriteStops.remove(stop.id);
    } else {
      _favoriteStops.add(stop.id);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorited
              ? '${stop.parada} removida dos favoritos.'
              : '${stop.parada} adicionada aos favoritos!',
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    notifyListeners();
  }

  // LÓGICA ATUALIZADA AQUI
  Future<List<UpcomingBus>> fetchBusesForStop(BusStop stop) async {
    // Agora, em vez de buscar de um JSON estático, calculamos o ETA
    // para todos os ônibus que estão atualmente no mapa.
    final List<UpcomingBus> busesWithEta = [];

    for (final bus in _liveBuses) {
      final etaMinutes = _calculateETAMinutes(bus.latLng, stop.latLng);
      // Cria uma nova instância do ônibus com o tempo de chegada atualizado
      busesWithEta.add(bus.copyWith(arrivalTime: etaMinutes));
    }

    // Ordena a lista para que os ônibus mais próximos apareçam primeiro
    busesWithEta.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    
    // Retorna a lista completa e ordenada
    return Future.value(busesWithEta);
  }

  // Lógica para o cálculo do ETA
  int _calculateETAMinutes(LatLng busPosition, LatLng stopPosition) {
    const double averageBusSpeedKmh = 20.0; // Velocidade média do ônibus em km/h

    int busStartIndex = _findClosestPointIndexOnRoute(busPosition);
    int stopIndex = _findClosestPointIndexOnRoute(stopPosition);

    double distanceMeters = 0;
    if (busStartIndex <= stopIndex) {
      for (int i = busStartIndex; i < stopIndex; i++) {
        distanceMeters += Geolocator.distanceBetween(
          _routePoints[i].latitude,
          _routePoints[i].longitude,
          _routePoints[i + 1].latitude,
          _routePoints[i + 1].longitude,
        );
      }
    } else {
      for (int i = busStartIndex; i < _routePoints.length - 1; i++) {
        distanceMeters += Geolocator.distanceBetween(
          _routePoints[i].latitude,
          _routePoints[i].longitude,
          _routePoints[i + 1].latitude,
          _routePoints[i + 1].longitude,
        );
      }
      for (int i = 0; i < stopIndex; i++) {
        distanceMeters += Geolocator.distanceBetween(
          _routePoints[i].latitude,
          _routePoints[i].longitude,
          _routePoints[i + 1].latitude,
          _routePoints[i + 1].longitude,
        );
      }
    }

    double distanceKm = distanceMeters / 1000;
    double timeHours = distanceKm / averageBusSpeedKmh;
    int timeMinutes = (timeHours * 60).round();

    return timeMinutes > 0 ? timeMinutes : 1;
  }

  int _findClosestPointIndexOnRoute(LatLng point) {
    double minDistance = double.infinity;
    int closestIndex = 0;
    for (int i = 0; i < _routePoints.length; i++) {
      final distance = Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        _routePoints[i].latitude,
        _routePoints[i].longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }
    return closestIndex;
  }

  @override
  void dispose() {
    _busUpdateTimer?.cancel();
    super.dispose();
  }
}

// Extensão para facilitar a atualização do `arrivalTime`
extension UpcomingBusCopyWith on UpcomingBus {
  UpcomingBus copyWith({int? arrivalTime}) {
    return UpcomingBus(
      id: id,
      name: name,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      latitude: latitude,
      longitude: longitude,
    );
  }
}