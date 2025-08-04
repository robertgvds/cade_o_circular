import 'package:flutter/material.dart';

class FloatingToolbar extends StatefulWidget {
  final VoidCallback onToggleBottomSheet;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmitted;
  final List<String> suggestions;
  final FocusNode focusNode;

  const FloatingToolbar({
    super.key,
    required this.onToggleBottomSheet,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.suggestions,
    required this.focusNode,
  });

  @override
  State<FloatingToolbar> createState() => _FloatingToolbarState();
}

class _FloatingToolbarState extends State<FloatingToolbar> {
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    final text = widget.searchController.text;
    setState(() {
      _showSuggestions = text.isNotEmpty && widget.suggestions.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! < -10) {
          widget.onToggleBottomSheet();
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
            GestureDetector(
              onTap: widget.onToggleBottomSheet,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: widget.focusNode,
                          controller: widget.searchController,
                          onChanged: widget.onSearchChanged,
                          onSubmitted: (_) => widget.onSearchSubmitted(),
                          decoration: InputDecoration(
                            hintText: "Pesquisar...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceVariant,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            // Removi o suffixIcon para deixar só o botão bus como confirmar
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Botão de confirmar pesquisa com ícone de lupa (search)
                      IconButton.filled(
                        onPressed: () {
                          // Quando clicar no botão, confirma a pesquisa e tira foco para fechar teclado
                          widget.onSearchSubmitted();
                          widget.focusNode.unfocus();
                        },
                        icon: const Icon(Icons.search),
                      ),
                    ],
                  ),

                  if (_showSuggestions)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = widget.suggestions[index];
                          return ListTile(
                            title: Text(suggestion),
                            onTap: () {
                              widget.searchController.text = suggestion;
                              widget.onSearchSubmitted();
                              widget.focusNode.unfocus();
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
