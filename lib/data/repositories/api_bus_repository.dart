import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/bus_stop_model.dart';
import '../models/bus_location_model.dart';

class ApiBusRepository {
  // ATENÇÃO PARA O ENDEREÇO BASE DA API:
  // - Emulador Android: 'http://10.0.2.2:8080'
  // - Simulador iOS: 'http://localhost:8080'
  // - Celular Físico: Coloque o IP da sua máquina na rede Wi-Fi (ex: 'http://192.168.1.15:8080')
  final String baseUrl;

  ApiBusRepository({this.baseUrl = 'http://10.0.2.2:8080'}); 

  Future<List<BusStopModel>> getBusStops() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/bus-stop'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BusStopModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha na API. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar paradas: $e');
      // Retorna vazio para não quebrar a tela caso o servidor esteja desligado
      return []; 
    }
  }

  Future<List<BusLocationModel>> getLiveBuses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/bus-location'));

      if (response.statusCode == 200) {
        // O backend Swift retorna um Dictionary<String, BusLocation> onde a chave é a placa
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        final List<BusLocationModel> liveBuses = [];
        
        data.forEach((key, value) {
          // Ignora a chave "error" se ela vier no JSON (como previsto no schema.yaml)
          if (key != 'error' && value is Map<String, dynamic>) {
            // A chave do dicionário (key) é a placa do ônibus (ex: "ABC1234")
            liveBuses.add(BusLocationModel.fromJson(key, value));
          }
        });
        
        return liveBuses;
      } else {
        throw Exception('Falha na API. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar localização dos ônibus: $e');
      return [];
    }
  }
}