import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';
import '../widgets/floating_toolbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  LatLng? _currentPosition;
  String _status = 'Obtendo localização...';
  final MapController _mapController = MapController();

  bool _showToolbar = true;
  List<String> _allStops = List.generate(15, (i) => "Parada ${i + 1}");
  List<String> _filteredStops = [];

  final TextEditingController _toolbarSearchController = TextEditingController();
  final TextEditingController _bottomSheetSearchController = TextEditingController();

  final FocusNode _toolbarFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _filteredStops = List.from(_allStops);
    _startLocationUpdates();
  }

  Future<void> _startLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _status = 'Serviço de localização desativado.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _status = 'Permissão negada.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _status = 'Permissão permanentemente negada.');
      return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      final newPosition = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = newPosition;
        _status = 'Localização atualizada!';
      });

      _animateToLocation(newPosition);
    });
  }

  void _animateToLocation(LatLng target, {double? zoom}) {
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
      final lat = latTween.evaluate(animation);
      final lng = lngTween.evaluate(animation);
      final z = zoomTween.evaluate(animation);
      _mapController.move(LatLng(lat, lng), z);
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _filterStops(String query) {
    setState(() {
      _filteredStops = _allStops
          .where((stop) => stop.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _onToolbarSearchChanged(String value) {
    _filterStops(value);
  }

  void _onToolbarSearchSubmitted() {
    _filterStops(_toolbarSearchController.text);
    _openBottomSheet();
  }

Future<void> _openBottomSheet() async {
  setState(() {
    _showToolbar = false;
    _bottomSheetSearchController.text = _toolbarSearchController.text;
    _filterStops(_bottomSheetSearchController.text);
  });

  // Aqui abrimos o BottomSheet
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _showToolbar = true;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Barra falsa que abre a toolbar e foca nela
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();

                    setState(() {
                      _showToolbar = true;
                    });

                    // Delay para garantir que o BottomSheet esteja fechado antes de focar
                    Future.delayed(const Duration(milliseconds: 250), () {
                      if (mounted) {
                        // Aqui usamos o contexto da tela para focar a toolbar
                        FocusScope.of(this.context).requestFocus(_toolbarFocusNode);
                      }
                    });
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _bottomSheetSearchController.text.isEmpty
                                ? "Pesquisar paradas..."
                                : _bottomSheetSearchController.text,
                            style: TextStyle(
                              color: _bottomSheetSearchController.text.isEmpty
                                  ? Colors.grey
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredStops.length,
                  itemBuilder: (_, i) => ListTile(
                    leading: const Icon(Icons.place),
                    title: Text(_filteredStops[i]),
                    subtitle: const Text("Horário estimado: 5 min"),
                    onTap: () {
                      _toolbarSearchController.text = _filteredStops[i];
                      Navigator.of(context).pop();
                      setState(() {
                        _showToolbar = true;
                      });

                      // Aqui também foca a toolbar após fechar BottomSheet
                      Future.delayed(const Duration(milliseconds: 250), () {
                        if (mounted) {
                          FocusScope.of(this.context).requestFocus(_toolbarFocusNode);
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );

  setState(() {
    _showToolbar = true;
  });
}

  void _toggleBottomSheet() {
    if (_showToolbar) {
      _onToolbarSearchSubmitted();
    } else {
      Navigator.of(context).pop();
      setState(() {
        _showToolbar = true;
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            FocusScope.of(context).requestFocus(_toolbarFocusNode);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _toolbarFocusNode.dispose();
    _toolbarSearchController.dispose();
    _bottomSheetSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkMode;
    final textColor = isDarkTheme ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Cadê o Circular?'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggle(),
          ),
        ],
      ),
      body: _currentPosition == null
          ? Center(
              child: Text(
                _status,
                style: TextStyle(color: textColor, fontSize: 18),
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition!,
                    initialZoom: 16,
                    enableMultiFingerGestureRace: true,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: isDarkTheme
                          ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png?api_key=dbe29069-000a-4e4e-9443-e148af835ff6'
                          : 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key=dbe29069-000a-4e4e-9443-e148af835ff6',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPosition!,
                          width: 50,
                          height: 50,
                          child: const Icon(Icons.my_location, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),

                if (_showToolbar)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 32,
                    child: FloatingToolbar(
                      onToggleBottomSheet: _toggleBottomSheet,
                      searchController: _toolbarSearchController,
                      onSearchChanged: _onToolbarSearchChanged,
                      onSearchSubmitted: _onToolbarSearchSubmitted,
                      suggestions: _filteredStops,
                      focusNode: _toolbarFocusNode,
                    ),
                  ),

                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      if (_currentPosition != null) {
                        _animateToLocation(_currentPosition!);
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
