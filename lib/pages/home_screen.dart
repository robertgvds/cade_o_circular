import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/bus_stop.dart';
import '../models/upcoming_bus.dart';
import '../providers/map_provider.dart';
import '../theme/theme_provider.dart';
import '../widgets/floating_toolbar.dart';
import '../widgets/map_widget.dart';
import '../widgets/search_sheet_content.dart';
import '../widgets/stop_detail_sheet_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // O estado do HomeScreen agora é mínimo!
  // Apenas controladores de UI e de localização.
  LatLng? _currentPosition;
  String _status = 'Obtendo localização...';
  final MapController _mapController = MapController();
  bool _isMapControllerReady = false;

  final TextEditingController _toolbarSearchController = TextEditingController();
  final TextEditingController _bottomSheetSearchController = TextEditingController();
  final FocusNode _toolbarFocusNode = FocusNode();
  
  bool _showToolbar = true;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }
  
  @override
  void dispose() {
    _toolbarSearchController.dispose();
    _bottomSheetSearchController.dispose();
    _toolbarFocusNode.dispose();
    super.dispose();
  }

  Future<void> _startLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _status = 'Serviço de localização desativado.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _status = 'Permissão negada.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _status = 'Permissão permanentemente negada.');
      return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((Position position) {
      if (!mounted) return;
      final newPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        if (_currentPosition == null) {
           _animateToLocation(newPosition);
        }
        _currentPosition = newPosition;
        _status = 'Localização atualizada!';
      });
    });
  }

  void _animateToLocation(LatLng target, {double? zoom}) {
    if (!_isMapControllerReady) return;
    
    final camera = _mapController.camera;
    final latTween = Tween<double>(begin: camera.center.latitude, end: target.latitude);
    final lngTween = Tween<double>(begin: camera.center.longitude, end: target.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: zoom ?? camera.zoom);

    final controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) controller.dispose();
    });

    controller.forward();
  }

  void _selectStopAndShowDetails(BusStop stop) {
    // Usa `context.read` para chamar uma função do provider
    final mapProvider = context.read<MapProvider>();
    mapProvider.selectStop(stop);
    
    final offsetLatLng = LatLng(stop.latitude - 0.0015, stop.longitude);
    _animateToLocation(offsetLatLng, zoom: 17.0);

    if (_showToolbar) {
      _openBottomSheet();
    }
  }

  Future<void> _openBottomSheet() async {
    setState(() { _showToolbar = false; });
    final mapProvider = context.read<MapProvider>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            // Usa Consumer para reconstruir o conteúdo quando o provider notificar
            return Consumer<MapProvider>(
              builder: (context, provider, child) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.25,
                  maxChildSize: 0.9,
                  expand: false,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: provider.selectedStop == null
                          ? SearchSheetContent(
                              scrollController: scrollController,
                              searchController: _bottomSheetSearchController,
                              onSearchChanged: provider.updateFilteredStops,
                              filteredStops: provider.filteredBusStops,
                              onStopTap: _selectStopAndShowDetails,
                            )
                          : FutureBuilder<List<UpcomingBus>>(
                              future: provider.fetchBusesForStop(provider.selectedStop!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                return StopDetailSheetContent(
                                  scrollController: scrollController,
                                  stop: provider.selectedStop!,
                                  buses: snapshot.data ?? [],
                                  onBack: provider.clearSelectedStop,
                                );
                              },
                            ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      if (mounted) {
        setState(() => _showToolbar = true);
        mapProvider.clearSelectedStop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usa `context.watch` para ouvir mudanças no estado e reconstruir a UI
    final themeProvider = context.watch<ThemeProvider>();
    final mapProvider = context.watch<MapProvider>();
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkTheme = themeProvider.themeMode == ThemeMode.system
        ? brightness == Brightness.dark
        : themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadê o Circular?'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDarkTheme ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => context.read<ThemeProvider>().toggle(),
          ),
        ],
      ),
      body: _currentPosition == null
          ? Center(child: Text(_status))
          : Stack(
              children: [
                MapWidget(
                  mapController: _mapController,
                  currentPosition: _currentPosition,
                  isDarkTheme: isDarkTheme,
                  busStops: mapProvider.filteredBusStops,
                  activeBuses: mapProvider.liveBuses,
                  routePoints: mapProvider.routePoints,
                  onMapReady: () => _isMapControllerReady = true,
                  onStopMarkerTap: _selectStopAndShowDetails,
                ),
                if (_showToolbar)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 32,
                    child: FloatingToolbar(
                      onToggleBottomSheet: _openBottomSheet,
                      searchController: _toolbarSearchController,
                      onSearchChanged: mapProvider.updateFilteredStops,
                      onSearchSubmitted: _openBottomSheet,
                      suggestions: mapProvider.filteredBusStops.map((s) => s.parada).toList(),
                      focusNode: _toolbarFocusNode,
                    ),
                  ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      if (_currentPosition != null) {
                        _animateToLocation(_currentPosition!, zoom: 16);
                      }
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
    );
  }
}