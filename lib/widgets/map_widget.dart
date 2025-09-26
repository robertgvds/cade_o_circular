import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/bus_stop.dart';
import '../models/upcoming_bus.dart'; // Importe o modelo do ônibus

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng? currentPosition;
  final bool isDarkTheme;
  final List<BusStop> busStops;
  final List<LatLng> routePoints;
  final List<UpcomingBus> activeBuses;
  final VoidCallback? onMapReady;
  final ValueChanged<BusStop>? onStopMarkerTap;

  const MapWidget({
    super.key,
    required this.mapController,
    required this.currentPosition,
    required this.isDarkTheme,
    required this.busStops,
    required this.routePoints,
    this.activeBuses = const [],
    this.onMapReady,
    this.onStopMarkerTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentPosition!,
        initialZoom: 16,
        onMapReady: onMapReady, 
        enableMultiFingerGestureRace: true,
      ),
      children: [
        TileLayer(
          urlTemplate:
              isDarkTheme
                  ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png?api_key=dbe29069-000a-4e4e-9443-e148af835ff6'
                  : 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key=dbe29069-000a-4e4e-9443-e148af835ff6',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.app',
        ),

        /*
        PolylineLayer(
          polylines: [
            Polyline(
              points: routePoints,
              strokeWidth: 4.0,
              color: Colors.grey,
            ),
          ],
        ),
        */
        
        // Camada para as PARADAS (ícones azuis)
        MarkerLayer(
          markers: busStops.map((stop) {
            return Marker(
              point: stop.latLng,
              width: 40,
              height: 40,
              // NOVO: GestureDetector para detectar o toque no ícone
              child: GestureDetector(
                onTap: () => onStopMarkerTap?.call(stop),
                child: const Icon(
                  Icons.place,
                  color: Colors.redAccent,
                  size: 30,
                ),
              ),
            );
          }).toList(),
        ),

        // NOVO: Camada para os ÔNIBUS ATIVOS (ícones verdes)
        MarkerLayer(
          markers: activeBuses.map((bus) {
            return Marker(
              point: bus.latLng,
              width: 40,
              height: 40,
              child: const Icon(Icons.directions_bus, color: Colors.green, size: 30),
            );
          }).toList(),
        ),

        // Camada para a localização do usuário (ícone vermelho)
        if (currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: currentPosition!,
                width: 20,
                height: 20,
                child: const Icon(Icons.circle, color: Colors.blueAccent, size: 20),
              ),
            ],
          ),
      ],
    );
  }
}

        