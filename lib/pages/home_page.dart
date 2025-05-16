import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/paradas_mock.dart';

import '../widgets/parada_bottom_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadê o Circular')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(-21.7659, -43.3496), // UFJF
          initialZoom: 16,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.cade_o_circular',
          ),
          MarkerLayer(
            markers:
                paradasMock.map((parada) {
                  return Marker(
                    point: parada.localizacao,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return ParadaBottomSheet(parada: parada);
                          },
                        );
                      },
                      child: Icon(
                        Icons.location_on,
                        color: Colors.teal,
                        size: 32,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
