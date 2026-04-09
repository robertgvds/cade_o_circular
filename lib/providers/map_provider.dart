import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../data/bus_route_data.dart';
import '../data/repositories/mock_bus_repository.dart';
import '../data/models/bus_stop_model.dart';
import '../data/models/bus_location_model.dart';

class MapProvider with ChangeNotifier {
  final MockBusRepository _repository;

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

  void _startBusUpdates() {
    _fetchLiveBuses(); // fetch inicial
    _busUpdateTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchLiveBuses());
  }

  Future<void> _fetchLiveBuses() async {
    _liveBuses = await _repository.getLiveBuses();
    notifyListeners();
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
    const double averageBusSpeedKmh = 20.0;
    double distanceMeters = Geolocator.distanceBetween(busPosition.latitude, busPosition.longitude, stopPosition.latitude, stopPosition.longitude);
    double distanceKm = distanceMeters / 1000;
    double timeHours = distanceKm / averageBusSpeedKmh;
    int timeMinutes = (timeHours * 60).round();
    return timeMinutes > 0 ? timeMinutes : 1;
  }
  
  @override
  void dispose() {
    _busUpdateTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }
}