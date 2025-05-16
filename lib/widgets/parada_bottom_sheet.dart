import 'package:flutter/material.dart';
import '../models/parada.dart';

class ParadaBottomSheet extends StatelessWidget {
  final Parada parada;

  const ParadaBottomSheet({Key? key, required this.parada}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parada.nome,
            style: Theme.of(context).textTheme.titleLarge, // <-- aqui
          ),
          const SizedBox(height: 8),
          const Text("Aqui você poderá ver os próximos ônibus que passam por essa parada."),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {
                // Navegação futura
              },
              child: const Text("Ver mais"),
            ),
          ),
        ],
      ),
    );
  }
}
