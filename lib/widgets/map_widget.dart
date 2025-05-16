import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapController _mapController;
  LatLng? _currentPosition;
  final Map<int, Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
    _loadBusStops();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o serviço de localização está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Serviços de localização desativados
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissão negada
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissão negada permanentemente
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(pos.latitude, pos.longitude);
      _mapController.move(_currentPosition!, 17);
      // Adiciona marcador do usuário
      _markers[-1] = Marker(
        point: _currentPosition!,
        width: 40,
        height: 40,
        builder: (context) => const Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 40,
        ),
      );
    });
  }

  void _loadBusStops() {
    // Exemplo simples com dados fixos, futuramente será JSON
    final stops = [
      {'id': 0, 'nome': 'Faculdade de Letras', 'lat': -21.774639, 'lng': -43.370316},
      {'id': 1, 'nome': 'Parada 2', 'lat': -21.775, 'lng': -43.369},
    ];

    for (var stop in stops) {
      _markers[stop['id']] = Marker(
        point: LatLng(stop['lat'] as double, stop['lng'] as double),
        width: 40,
        height: 40,
        builder: (context) => GestureDetector(
          onTap: () {
            // Aqui pode abrir BottomSheet da parada
          },
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: _currentPosition,
        zoom: 17,
        maxZoom: 20,
        minZoom: 10,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(markers: _markers.values.toList()),
      ],
    );
  }
}
