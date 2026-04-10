import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../data/bus_route_data.dart';
import '../data/repositories/api_bus_repository.dart';
import '../data/repositories/mock_bus_repository.dart';
import '../data/models/bus_stop_model.dart';
import '../data/models/bus_location_model.dart';

class MapProvider with ChangeNotifier {
  final ApiBusRepository _repository;

  List<BusStopModel> _allBusStops = [];
  List<BusStopModel> _filteredBusStops = [];
  List<BusLocationModel> _liveBuses = [];
  final List<LatLng> _routePoints = busRoutePolyline;

  String _searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  
  bool _isSearchFocused = false;
  bool _showFavoritesOnly = false;
  
  BusStopModel? _selectedStop;
  final Set<String> _favoriteStops = {}; // Mudou para String
  Timer? _busUpdateTimer;

  // Getters
  List<BusStopModel> get filteredBusStops => _filteredBusStops;
  List<BusLocationModel> get liveBuses => _liveBuses;
  List<LatLng> get routePoints => _routePoints;
  BusStopModel? get selectedStop => _selectedStop;
  Set<String> get favoriteStops => _favoriteStops;
  String get searchQuery => _searchQuery;
  bool get showFavoritesOnly => _showFavoritesOnly;

  List<BusStopModel> get displayStops {
    if (_searchQuery.isNotEmpty) return _filteredBusStops;
    if (_showFavoritesOnly) return _allBusStops.where((stop) => _favoriteStops.contains(stop.id)).toList();
    return _allBusStops;
  }

  MapProvider(this._repository) {
    _loadInitialData();
    searchController.addListener(() => updateFilteredStops(searchController.text));
  }

  Future<void> _loadInitialData() async {
    _allBusStops = await _repository.getBusStops();
    _filteredBusStops = List.from(_allBusStops);
    notifyListeners();
    _startBusUpdates();
  }

  Timer? _apiTimer;
  Timer? _animationTimer;
  List<BusLocationModel> _targetBuses = []; // A posição real que vem da API

  void _startBusUpdates() {
    _fetchLiveBuses();
    
    // 1. Cronômetro da API (Bate no servidor a cada 1 segundo)
    _apiTimer = Timer.periodic(const Duration(seconds: 1), (_) => _fetchLiveBuses());
    
    // 2. Cronômetro de Animação (Roda a 60 quadros por segundo)
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => _animateBuses());
  }

  Future<void> _fetchLiveBuses() async {
    _targetBuses = await _repository.getLiveBuses();
    
    // No primeiro carregamento, coloca os ônibus direto na posição
    if (_liveBuses.isEmpty) {
      _liveBuses = List.from(_targetBuses);
      notifyListeners();
    }
  }

  void _animateBuses() {
    if (_targetBuses.isEmpty || _liveBuses.isEmpty) return;

    bool needsUpdate = false;
    
    for (int i = 0; i < _liveBuses.length; i++) {
      final current = _liveBuses[i];
      final target = _targetBuses.firstWhere(
          (b) => b.licensePlate == current.licensePlate, 
          orElse: () => current);

      // Desliza a coordenada atual 10% da distância em direção ao alvo por quadro
      final double latDiff = target.latitude - current.latitude;
      final double lngDiff = target.longitude - current.longitude;

      if (latDiff.abs() > 0.000001 || lngDiff.abs() > 0.000001) {
        _liveBuses[i] = current.copyWith(
          latitude: current.latitude + (latDiff * 0.1),
          longitude: current.longitude + (lngDiff * 0.1),
        );
        needsUpdate = true;
      }
    }

    if (needsUpdate) {
      notifyListeners(); // Atualiza o mapa suavemente
    }
  }

  // IMPORTANTE: Transformamos isso em síncrono para a UI não "piscar" com os 60FPS
  List<BusLocationModel> getBusesForStop(BusStopModel stop) {
    final List<BusLocationModel> busesWithEta = [];
    for (final bus in _targetBuses) {
      final etaMinutes = _calculateETAMinutes(bus.latLng, stop.latLng);
      busesWithEta.add(bus.copyWith(arrivalTime: etaMinutes));
    }
    busesWithEta.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    return busesWithEta;
  }

  void setSearchFocus(bool hasFocus) {
    if (_isSearchFocused != hasFocus) {
      _isSearchFocused = hasFocus;
      notifyListeners();
    }
  }

  void updateFilteredStops(String query) {
    _searchQuery = query;
    if (query.isNotEmpty) _showFavoritesOnly = false;
    if (searchController.text != query) {
      searchController.text = query;
      searchController.selection = TextSelection.fromPosition(TextPosition(offset: searchController.text.length));
    }

    if (query.isEmpty) {
      _filteredBusStops = List.from(_allBusStops);
    } else {
      _filteredBusStops = _allBusStops.where((stop) => stop.longName.toLowerCase().contains(query.toLowerCase())).toList();
    }
    notifyListeners();
  }

  void toggleFavoritesMode() {
    _showFavoritesOnly = !_showFavoritesOnly;
    if (_showFavoritesOnly) {
      clearSearch(keepFocus: true);
      _isSearchFocused = true;
    }
    notifyListeners();
  }

  void clearSearch({bool keepFocus = false}) {
    searchController.clear();
    if (!keepFocus) {
        _isSearchFocused = false;
        FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void selectStop(BusStopModel stop) {
    _selectedStop = stop;
    _isSearchFocused = false;
    _showFavoritesOnly = false;
    searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    notifyListeners();
  }

  void clearSelectedStop() {
    _selectedStop = null;
    notifyListeners();
  }

  void toggleFavoriteStop(BusStopModel stop, BuildContext context) {
    if (_favoriteStops.contains(stop.id)) {
      _favoriteStops.remove(stop.id);
    } else {
      _favoriteStops.add(stop.id);
    }
    notifyListeners();
  }

  Future<List<BusLocationModel>> fetchBusesForStop(BusStopModel stop) async {
    final List<BusLocationModel> busesWithEta = [];
    for (final bus in _liveBuses) {
      final etaMinutes = _calculateETAMinutes(bus.latLng, stop.latLng);
      busesWithEta.add(bus.copyWith(arrivalTime: etaMinutes));
    }
    busesWithEta.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    return busesWithEta;
  }

  int _calculateETAMinutes(LatLng busPosition, LatLng stopPosition) {
    final route = _routePoints; // O traçado completo da UFJF
    if (route.isEmpty) return 1;

    // 1. Encontra qual o ponto da rota (índice) mais próximo de onde o ônibus está e de onde é a parada
    int busIndex = _getNearestRouteIndex(busPosition, route);
    int stopIndex = _getNearestRouteIndex(stopPosition, route);

    // 2. Calcula a distância real acompanhando as curvas da rua
    double pathDistanceMeters = 0;
    int currentIndex = busIndex;
    int stopsInBetween = 0;

    // Mapeia em quais índices da rota estão as paradas, para podermos contar os pontos de parada
    Set<int> stopRouteIndices = _allBusStops.map((s) => _getNearestRouteIndex(s.latLng, route)).toSet();

    // Faz o trajeto do ônibus até o destino. 
    // Como o circular dá a volta no campus, se o stopIndex for menor, ele vai até o final do array e recomeça (anel)
    while (currentIndex != stopIndex) {
      int nextIndex = (currentIndex + 1) % route.length;
      
      pathDistanceMeters += Geolocator.distanceBetween(
        route[currentIndex].latitude, route[currentIndex].longitude,
        route[nextIndex].latitude, route[nextIndex].longitude,
      );

      // Se nesse pedacinho de rua que acabamos de andar existe uma parada (que não é o destino final), soma uma parada
      if (stopRouteIndices.contains(currentIndex) && currentIndex != busIndex) {
        stopsInBetween++;
      }

      currentIndex = nextIndex;
    }

    // 3. Calcula o tempo total
    const double averageBusSpeedKmh = 20.0; // Velocidade média do circular EM MOVIMENTO nas curvas da UFJF
    double speedMetersPerSecond = (averageBusSpeedKmh * 1000) / 3600;
    
    double timeInMotionSeconds = pathDistanceMeters / speedMetersPerSecond;
    double timeStoppedSeconds = stopsInBetween * 35.0; // Adiciona 35 segundos para cada parada no meio do caminho

    double totalTimeSeconds = timeInMotionSeconds + timeStoppedSeconds;
    int timeMinutes = (totalTimeSeconds / 60).round();

    return timeMinutes > 0 ? timeMinutes : 1;
  }

  // --- FUNÇÕES AUXILIARES ---

  // Acha o ponto exato da polyline que está mais perto de uma coordenada
  int _getNearestRouteIndex(LatLng point, List<LatLng> route) {
    int nearestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < route.length; i++) {
      // Usa uma fórmula matemática super leve para não travar o app (evita cálculos esféricos complexos no loop)
      double distance = _quickSquaredDistance(point, route[i]);
      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }
    return nearestIndex;
  }

  // Fórmula de aproximação plana apenas para comparar distâncias curtas rapidamente
  double _quickSquaredDistance(LatLng p1, LatLng p2) {
    double latDiff = p1.latitude - p2.latitude;
    double lngDiff = p1.longitude - p2.longitude;
    return (latDiff * latDiff) + (lngDiff * lngDiff);
  }
  
  @override
  void dispose() {
    _busUpdateTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }
}