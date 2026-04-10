import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../data/models/bus_stop_model.dart';
import '../core/theme/theme.dart';

class FloatingSearchBottomSheet extends StatefulWidget {
  final FocusNode focusNode;
  final ValueChanged<BusStopModel> onStopSelected;

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
  ScrollController? _listScrollController; // Guardamos o controle da lista aqui

  final double _minSize = 0.133;
  final double _maxSize = 0.87;

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
    } else {
      // Se perdeu o foco (ex: clicou no mapa), encolhe e volta pro topo
      _scrollToTop();
      _animateTo(_minSize);
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

  void _scrollToTop() {
    if (_listScrollController != null && _listScrollController!.hasClients) {
      _listScrollController!.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: _minSize,
      minChildSize: _minSize,
      maxChildSize: _maxSize,
      snap: true,
      builder: (context, scrollController) {
        _listScrollController = scrollController; // Salvamos o controller da lista

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: ShapeDecoration(
            shape: kAppShape,
            shadows: appShadows,
          ),
          child: ClipPath(
            clipper: ShapeBorderClipper(shape: kAppShape),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.9),
                ),
                child: Consumer<MapProvider>(
                  builder: (context, provider, child) {
                    final displayStops = provider.displayStops;

                    return CustomScrollView(
                      controller: scrollController,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        // --- HEADER FIXO NO TOPO ---
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _StickyHeaderDelegate(
                            height: 95.0, // Altura exata do Header
                            child: _buildHeader(context, provider),
                          ),
                        ),

                        // --- LISTA ROLÁVEL ---
                        SliverPadding(
                          padding: EdgeInsets.only(bottom: bottomPadding + 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (displayStops.isEmpty) {
                                  if (!provider.showFavoritesOnly) {
                                    return const Padding(
                                      padding: EdgeInsets.all(32.0),
                                      child: Center(
                                        child: Text("Arraste para ver todas as pontos",
                                            style: TextStyle(color: Colors.grey)),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox();
                                  }
                                }

                                final stop = displayStops[index];
                                final isFavorite = provider.favoriteStops.contains(stop.id);

                                return Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(
                                        isFavorite ? Icons.star_rounded : Icons.place_outlined,
                                        color: isFavorite ? Colors.amber : Colors.grey,
                                      ),
                                      title: Text(stop.longName),
                                      onTap: () {
                                        widget.focusNode.unfocus();
                                        _scrollToTop(); // Volta pro topo antes de encolher!
                                        _animateTo(_minSize);
                                        widget.onStopSelected(stop);
                                      },
                                    ),
                                    Divider(
                                        height: 1,
                                        indent: 16,
                                        endIndent: 16,
                                        color: isDark ? Colors.white12 : Colors.black12),
                                  ],
                                );
                              },
                              // A contagem agora reflete diretamente o tamanho da lista (sem o +1 do antigo header)
                              childCount: displayStops.isEmpty ? 1 : displayStops.length,
                            ),
                          ),
                        ),
                      ],
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

    return Container(
      decoration: ShapeDecoration(
            shape: kAppShape,
            shadows: appShadows,
            color: Theme.of(context).colorScheme.surfaceContainer
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Alça de puxar
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white30 : Colors.black12,
                borderRadius: BorderRadius.circular(kRadiusSmall), // Usando variáveis do tema
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(kRadiusPill), // Usando variáveis do tema
                border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
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
                        hintText: "Buscar pontos...",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (provider.searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        provider.clearSearch(keepFocus: true);
                        _scrollToTop(); // Também volta pro topo se limpar a pesquisa
                      },
                    )
                  else
                    IconButton(
                      icon: Icon(
                        provider.showFavoritesOnly ? Icons.star : Icons.star_border,
                        color: provider.showFavoritesOnly ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () {
                        provider.toggleFavoritesMode();
                        _scrollToTop(); // Também volta pro topo se filtrar por favoritos
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Classe que ensina o Flutter a colar o Header no topo do CustomScrollView
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return true; // Atualiza a barra de pesquisa se algo mudar no estado
  }
}