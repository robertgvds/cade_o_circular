import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationProvider with ChangeNotifier {
  LatLng? _currentPosition;
  String _status = 'Aguardando permissão...';
  bool _isServiceEnabled = false;
  StreamSubscription<Position>? _positionStream;

  LatLng? get currentPosition => _currentPosition;
  String get status => _status;

  LocationProvider() {
    _initLocationService();
  }

  Future<void> _initLocationService() async {
    // 1. Verificar se o serviço (GPS) está ligado
    _isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_isServiceEnabled) {
      _status = 'GPS desativado.';
      notifyListeners();
      return;
    }

    // 2. Verificar Permissões
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _status = 'Permissão de localização negada.';
        notifyListeners();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _status = 'Permissão negada permanentemente. Habilite nas configurações.';
      notifyListeners();
      return;
    }

    // 3. Iniciar o rastreamento
    _status = 'Localizando...';
    notifyListeners();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Só notifica se mover 5 metros
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _status = 'Localização atualizada';
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}