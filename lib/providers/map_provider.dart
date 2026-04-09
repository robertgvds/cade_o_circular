import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../data/bus_route_data.dart';
import '../data/live_bus_repository.dart';
import '../models/bus_stop.dart';
import '../models/upcoming_bus.dart';

class MapProvider with ChangeNotifier {
  // Dados
  List<BusStop> _allBusStops = [];
  List<BusStop> _filteredBusStops = [];
  List<UpcomingBus> _liveBuses = [];
  final List<LatLng> _routePoints = busRoutePolyline;

  // Estado da Pesquisa
  String _searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  
  // Estado de Visualização
  bool _isSearchFocused = false;
  bool _showFavoritesOnly = false;
  
  BusStop? _selectedStop;
  final Set<int> _favoriteStops = {};

  final LiveBusRepository _busRepo = LiveBusRepository();
  Timer? _busUpdateTimer;

  // Getters
  List<BusStop> get filteredBusStops => _filteredBusStops;
  List<UpcomingBus> get liveBuses => _liveBuses;
  List<LatLng> get routePoints => _routePoints;
  BusStop? get selectedStop => _selectedStop;
  Set<int> get favoriteStops => _favoriteStops;
  String get searchQuery => _searchQuery;
  bool get showFavoritesOnly => _showFavoritesOnly;

  
  // ... getters ...

  // Getter Ajustado
  List<BusStop> get displayStops {
    // 1. Tem busca? Retorna filtro.
    if (_searchQuery.isNotEmpty) {
      return _filteredBusStops;
    }
    // 2. Modo favoritos? Retorna favoritos.
    if (_showFavoritesOnly) {
      return _allBusStops.where((stop) => _favoriteStops.contains(stop.id)).toList();
    }
    // 3. Padrão: Retorna TUDO (para a lista do BottomSheet não ficar vazia quando aberta)
    return _allBusStops;
  }

  MapProvider(String busStopsJson) {
    _loadBusStops(busStopsJson);
    _startBusUpdates();
    
    searchController.addListener(() {
      updateFilteredStops(searchController.text);
    });
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

  // --- MÉTODOS DE AÇÃO ---

  void setSearchFocus(bool hasFocus) {
    // Só notificamos se houver mudança real para evitar loops
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
      searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: searchController.text.length));
    }

    if (query.isEmpty) {
      _filteredBusStops = List.from(_allBusStops);
    } else {
      _filteredBusStops = _allBusStops
          .where((stop) => stop.parada.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void toggleFavoritesMode() {
    _showFavoritesOnly = !_showFavoritesOnly;
    if (_showFavoritesOnly) {
      clearSearch(keepFocus: true);
      _isSearchFocused = true; // Garante que a lista abra
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

  void selectStop(BusStop stop) {
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

  void toggleFavoriteStop(BusStop stop, BuildContext context) {
    if (_favoriteStops.contains(stop.id)) {
      _favoriteStops.remove(stop.id);
    } else {
      _favoriteStops.add(stop.id);
    }
    notifyListeners();
  }

  // ETA Logic
  Future<List<UpcomingBus>> fetchBusesForStop(BusStop stop) async {
    final List<UpcomingBus> busesWithEta = [];
    for (final bus in _liveBuses) {
      final etaMinutes = _calculateETAMinutes(bus.latLng, stop.latLng);
      busesWithEta.add(bus.copyWith(arrivalTime: etaMinutes));
    }
    busesWithEta.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    return Future.value(busesWithEta);
  }

  int _calculateETAMinutes(LatLng busPosition, LatLng stopPosition) {
    const double averageBusSpeedKmh = 20.0;
    // (Cálculo simplificado, use o completo se tiver a rota)
    double distanceMeters = Geolocator.distanceBetween(
        busPosition.latitude, busPosition.longitude,
        stopPosition.latitude, stopPosition.longitude
    );
    double distanceKm = distanceMeters / 1000;
    double timeHours = distanceKm / averageBusSpeedKmh;
    int timeMinutes = (timeHours * 60).round();
    return timeMinutes > 0 ? timeMinutes : 1;
  }
  
  // Helpers
  int _findClosestPointIndexOnRoute(LatLng point) => 0; 
  
  @override
  void dispose() {
    _busUpdateTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }
}

extension UpcomingBusCopyWith on UpcomingBus {
  UpcomingBus copyWith({int? arrivalTime}) {
    return UpcomingBus(
      id: id, name: name, arrivalTime: arrivalTime ?? this.arrivalTime,
      latitude: latitude, longitude: longitude,
    );
  }
}