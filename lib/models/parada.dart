import 'package:latlong2/latlong.dart';

class Parada {
  final String id;
  final String nome;
  final LatLng localizacao;

  Parada({
    required this.id,
    required this.nome,
    required this.localizacao,
  });
}
