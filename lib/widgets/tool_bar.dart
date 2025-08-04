import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const FloatingToolbarPage(),
  ));
}

class FloatingToolbarPage extends StatefulWidget {
  const FloatingToolbarPage({super.key});

  @override
  State<FloatingToolbarPage> createState() => _FloatingToolbarPageState();
}

class _FloatingToolbarPageState extends State<FloatingToolbarPage> {
  bool _showToolbar = true;

  Future<void> _openBottomSheet() async {
    setState(() {
      _showToolbar = false;
    });

    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 15,
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.place),
            title: Text("Parada ${i + 1}"),
            subtitle: const Text("Horário estimado: 5 min"),
          ),
        );
      },
    );

    // Quando fechar a BottomSheet, mostrar a toolbar de novo
    setState(() {
      _showToolbar = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Toolbar Flutuante M3")),
      body: Stack(
        children: [
          const Center(
            child: Text("Arraste a toolbar para cima para abrir a BottomSheet"),
          ),
          if (_showToolbar)
            Positioned(
              left: 16,
              right: 16,
              bottom: 32,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta! < -10) {
                    _openBottomSheet();
                  }
                },
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(24),
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: SearchBar(
                                hintText: "Pesquisar...",
                                elevation: const MaterialStatePropertyAll(0),
                                padding: const MaterialStatePropertyAll(
                                    EdgeInsets.symmetric(horizontal: 16)),
                                onChanged: (value) {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton.filled(
                              onPressed: () {},
                              icon: const Icon(Icons.directions_bus),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
