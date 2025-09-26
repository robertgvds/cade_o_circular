import 'package:flutter/material.dart';
import '../models/bus_stop.dart';

class SearchSheetContent extends StatelessWidget {
  final ScrollController scrollController;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<BusStop> filteredStops;
  final ValueChanged<BusStop> onStopTap;

  const SearchSheetContent({
    super.key,
    required this.scrollController,
    required this.searchController,
    required this.onSearchChanged,
    required this.filteredStops,
    required this.onStopTap,
  });

  @override
  Widget build(BuildContext context) {
    // Linha de depuração opcional que você pode remover
    // print('Construindo a lista no BottomSheet com ${filteredStops.length} itens.');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Pesquisar parada...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.zero, // O padding já está no Column
              itemCount: filteredStops.length,
              itemBuilder: (context, index) {
                final stop = filteredStops[index];
                return ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(stop.parada),
                  subtitle: const Text("Clique para ver no mapa"),
                  onTap: () => onStopTap(stop),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}