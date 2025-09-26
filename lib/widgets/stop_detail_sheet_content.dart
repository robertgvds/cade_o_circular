import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bus_stop.dart';
import '../models/upcoming_bus.dart';
import '../providers/map_provider.dart';

class StopDetailSheetContent extends StatelessWidget {
  final BusStop stop;
  final List<UpcomingBus> buses;
  final VoidCallback onBack;
  final ScrollController scrollController;

  const StopDetailSheetContent({
    super.key,
    required this.stop,
    required this.buses,
    required this.onBack,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // Acessa o provider para saber se a parada é favorita
    final mapProvider = context.watch<MapProvider>();
    final isFavorited = mapProvider.favoriteStops.contains(stop.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com botão de voltar, nome da parada e botão de favoritar
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              ),
              Expanded(
                child: Text(
                  stop.parada,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorited ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isFavorited ? Colors.amber : Colors.grey,
                  size: 30,
                ),
                onPressed: () {
                  // Chama a função do provider para favoritar/desfavoritar
                  // Usamos context.read aqui porque estamos dentro de um callback de evento
                  context.read<MapProvider>().toggleFavoriteStop(stop, context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Placeholder para a imagem da parada
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                height: 150,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Ônibus Próximos",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),

          // Lista de ônibus
          Expanded(
            child: buses.isEmpty
                ? const Center(
                    child: Text("Nenhum ônibus próximo no momento."),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: buses.length,
                    itemBuilder: (context, index) {
                      final bus = buses[index];
                      return ListTile(
                        leading: const Icon(Icons.directions_bus),
                        title: Text(bus.name),
                        subtitle: Text(bus.arrivalTime <= 1
                            ? "Chegando agora"
                            : "Chega em ~${bus.arrivalTime} minutos"),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}