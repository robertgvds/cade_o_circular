// Este mapa simula uma resposta de API, onde a chave é o ID da parada.
const Map<int, String> upcomingBusesJsonData = {
  // Dados para a parada "Faculdade de Letras" (id: 0)
  0: '''
  {
    "buses": [
      {"id": "bus1", "name": "Ônibus A", "arrivalTime": 2, "latitude": -21.77560, "longitude": -43.37050},
      {"id": "bus2", "name": "Ônibus B", "arrivalTime": 8, "latitude": -21.77210, "longitude": -43.36890}
    ]
  }
  ''',
  // Dados para a parada "Faculdade de Engenharia" (id: 3)
  3: '''
  {
    "buses": [
      {"id": "bus3", "name": "Ônibus C", "arrivalTime": 5, "latitude": -21.77800, "longitude": -43.37150}
    ]
  }
  ''',
  // Adicione dados para outras paradas aqui...
};