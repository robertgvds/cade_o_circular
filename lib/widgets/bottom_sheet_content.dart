import 'package:flutter/material.dart';
import 'carousel_item.dart';

class BottomSheetContent extends StatelessWidget {
  final ScrollController scrollController;

  const BottomSheetContent({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        controller: scrollController,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar parada...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Buscar"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: PageView(
              children: const [
                CarouselItem("Parada 1"),
                CarouselItem("Parada 2"),
                CarouselItem("Parada 3"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
