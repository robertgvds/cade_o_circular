import 'dart:ui'; // Necessário para o ImageFilter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../models/bus_stop.dart';
import '../theme/theme.dart';

class FloatingSearchBottomSheet extends StatefulWidget {
  final FocusNode focusNode;
  final ValueChanged<BusStop> onStopSelected;

  const FloatingSearchBottomSheet({
    super.key,
    required this.focusNode,
    required this.onStopSelected,
  });

  @override
  State<FloatingSearchBottomSheet> createState() => _FloatingSearchBottomSheetState();
}

class _FloatingSearchBottomSheetState extends State<FloatingSearchBottomSheet> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  final double _minSize = 0.15;
  final double _maxSize = 0.90;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (widget.focusNode.hasFocus) {
      _animateTo(_maxSize);
    }
  }

  void _animateTo(double size) {
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        size,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Definição do estilo "Glass" moderno
    final glassGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF1E1E1E).withOpacity(0.70),
              const Color(0xFF1E1E1E).withOpacity(0.40),
            ]
          : [
              Colors.white.withOpacity(0.70),
              Colors.white.withOpacity(0.40),
            ],
    );

    final glassBorder = Border.all(
      color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
      width: 1.0,
    );

    const smoothShape = kAppShape;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: _minSize,
      minChildSize: _minSize,
      maxChildSize: _maxSize,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          // Sombra precisa ficar fora do Clip/Glass para aparecer no mapa
          decoration: ShapeDecoration(
            shape: smoothShape,
            shadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipPath(
            clipper: ShapeBorderClipper(shape: smoothShape),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // O efeito de vidro real
              child: Container(
                decoration: BoxDecoration(
                  gradient: glassGradient,
                  border: glassBorder,
                  // Não precisa de borderRadius aqui pois o ClipPath já corta
                ),
                child: Consumer<MapProvider>(
                  builder: (context, provider, child) {
                    final displayStops = provider.displayStops;
                    
                    int itemCount = 1 + displayStops.length;
                    if (displayStops.isEmpty && !provider.showFavoritesOnly) {
                      itemCount += 1; 
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.only(bottom: bottomPadding + 20),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        
                        // --- HEADER ---
                        if (index == 0) {
                          return _buildHeader(context, provider);
                        }

                        // --- LISTA ---
                        final listIndex = index - 1;

                        if (displayStops.isEmpty) {
                           if (!provider.showFavoritesOnly) {
                             return const Padding(
                               padding: EdgeInsets.all(32.0),
                               child: Center(
                                 child: Text("Arraste para ver todas as paradas", 
                                   style: TextStyle(color: Colors.grey)),
                               ),
                             );
                           } else {
                             return const SizedBox();
                           }
                        }

                        final stop = displayStops[listIndex];
                        final isFavorite = provider.favoriteStops.contains(stop.id);

                        return Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                isFavorite ? Icons.star_rounded : Icons.place_outlined,
                                color: isFavorite ? Colors.amber : Colors.grey,
                              ),
                              title: Text(stop.parada),
                              onTap: () {
                                widget.focusNode.unfocus();
                                _animateTo(_minSize);
                                widget.onStopSelected(stop);
                              },
                            ),
                            // Divider mais sutil para combinar com o vidro
                            Divider(
                              height: 1, 
                              indent: 16, 
                              endIndent: 16, 
                              color: isDark ? Colors.white12 : Colors.black12
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, MapProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white30 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              // Fundo da barra de busca levemente mais opaco para contraste
              color: isDark ? Colors.black26 : Colors.white54, 
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.search, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    focusNode: widget.focusNode,
                    controller: provider.searchController,
                    decoration: const InputDecoration(
                      hintText: "Buscar paradas...",
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (provider.searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => provider.clearSearch(keepFocus: true),
                  )
                else
                  IconButton(
                    icon: Icon(
                      provider.showFavoritesOnly ? Icons.star : Icons.star_border,
                      color: provider.showFavoritesOnly ? Colors.amber : Colors.grey,
                    ),
                    onPressed: provider.toggleFavoritesMode,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}