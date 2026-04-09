import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bus_stop.dart';
import '../models/upcoming_bus.dart';
import '../providers/map_provider.dart';
import '../theme/theme.dart'; // Importante para pegar o kAppShape

class StopDetailSheetContent extends StatelessWidget {
  final BusStop stop;
  final List<UpcomingBus> buses;
  final VoidCallback onBack;
  final ScrollController scrollController;
  final Function(UpcomingBus) onBusTap; // Novo callback

  const StopDetailSheetContent({
    super.key,
    required this.stop,
    required this.buses,
    required this.onBack,
    required this.scrollController,
    required this.onBusTap, // Obrigatório agora
  });

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();
    final isFavorited = mapProvider.favoriteStops.contains(stop.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Alça
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 50,
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        // Conteúdo
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              // Cabeçalho da Parada
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryRed.withOpacity(0.1), // Vermelho forte diluído
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.place_rounded, color: primaryRed, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.parada,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.1),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Ponto de ônibus",
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => mapProvider.toggleFavoriteStop(stop, context),
                    icon: Icon(
                      isFavorited ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isFavorited ? Colors.amber : Colors.grey,
                      size: 32,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              Text(
                "CHEGADAS EM TEMPO REAL",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 16),

              if (buses.isEmpty)
                _buildEmptyState(context)
              else
                ...buses.map((bus) => _buildBusCard(bus, context)),
                
              const SizedBox(height: 50),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        shape: kAppShape, // Padronizado
      ),
      child: Column(
        children: [
          Icon(Icons.directions_bus_outlined, size: 48, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text("Nenhuma previsão no momento", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBusCard(UpcomingBus bus, BuildContext context) {
    final bool isArriving = bus.arrivalTime <= 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      // Design Padronizado
      decoration: ShapeDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        shape: kAppShape, // Padronizado
        shadows: appShadows, // Sombra Padronizada
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: kAppShape, // Efeito de toque respeita a borda
          onTap: () => onBusTap(bus), // CLICK NO ÔNIBUS AQUI
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isArriving ? const Color(0xFF34C759) : primaryRed,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isArriving ? const Color(0xFF34C759) : primaryRed).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    isArriving ? "Agora" : "${bus.arrivalTime}'",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (isArriving) 
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(Icons.rss_feed_rounded, size: 14, color: Color(0xFF34C759)),
                            ),
                          Text(
                            isArriving ? "Chegando..." : "Minutos estimados",
                            style: TextStyle(
                              color: isArriving ? const Color(0xFF34C759) : Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}