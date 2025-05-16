import 'package:flutter/material.dart';

class BusStopCard extends StatelessWidget {
  final String name;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const BusStopCard({
    super.key,
    required this.name,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: onFavoriteToggle,
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.yellow[700] : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Próximo em 5 min", // futuramente dinâmico
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
