import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/bus_stop.dart';
import '../models/upcoming_bus.dart';

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
        initialCenter: currentPosition ?? const LatLng(-21.775, -43.370),
        initialZoom: 17.5, // Zoom inicial aumentado
        onMapReady: onMapReady,
        enableMultiFingerGestureRace: true,
      ),
      children: [
        TileLayer(
          // Voltando para o Stadia (Cinza suave) no modo escuro e Voyager (Colorido) no claro
          urlTemplate: isDarkTheme
              ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png?api_key=dbe29069-000a-4e4e-9443-e148af835ff6'
              : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.cadeocircular.app',
        ),

        // Marcadores de PARADA
        MarkerLayer(
          markers: busStops.map((stop) {
            return Marker(
              point: stop.latLng,
              width: 45,
              height: 45,
              child: GestureDetector(
                onTap: () => onStopMarkerTap?.call(stop),
                child: _buildShadowedMarker(
                  icon: Icons.place_rounded,
                  color: const Color(0xFFFF3B30),
                  size: 45,
                ),
              ),
            );
          }).toList(),
        ),

        // Marcadores de ÔNIBUS
        MarkerLayer(
          markers: activeBuses.map((bus) {
            return Marker(
              point: bus.latLng,
              width: 50,
              height: 50,
              child: _buildShadowedMarker(
                icon: Icons.directions_bus_rounded,
                color: const Color(0xFF34C759),
                size: 40,
                hasGlow: true,
              ),
            );
          }).toList(),
        ),

        if (currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: currentPosition!,
                width: 25,
                height: 25,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildShadowedMarker({
    required IconData icon,
    required Color color,
    required double size,
    bool hasGlow = false,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 2,
          child: Container(
            width: 20,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(blurRadius: 4)],
            ),
          ),
        ),
        if (hasGlow)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.6), blurRadius: 20, spreadRadius: -5),
              ],
            ),
          ),
        Icon(icon, color: color, size: size),
      ],
    );
  }
}