import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../data/models/bus_stop_model.dart';
import '../data/models/bus_location_model.dart';
import '../providers/map_provider.dart';
import '../providers/location_provider.dart';
import '../core/theme/theme_provider.dart';
import '../core/theme/theme.dart'; // Importante
import '../widgets/floating_search_bottom_sheet.dart';
import '../widgets/map_widget.dart';
import '../widgets/stop_detail_sheet_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _hasCenteredInitially = false;

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _animateToLocation(LatLng target, {double zoom = 18.0}) {
    try {
      final camera = _mapController.camera;
      final latTween = Tween<double>(
        begin: camera.center.latitude,
        end: target.latitude,
      );
      final lngTween = Tween<double>(
        begin: camera.center.longitude,
        end: target.longitude,
      );
      final zoomTween = Tween<double>(begin: camera.zoom, end: zoom);

      final controller = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      final animation = CurvedAnimation(
        parent: controller,
        curve: Curves.fastOutSlowIn,
      );

      controller.addListener(() {
        _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation),
        );
      });
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) controller.dispose();
      });
      controller.forward();
    } catch (e) {
      debugPrint("Erro anim: $e");
    }
  }

  void _onStopSelected(BusStopModel stop) {
    context.read<MapProvider>().selectStop(stop);
    final offsetLatLng = LatLng(stop.latitude - 0.001, stop.longitude);
    _animateToLocation(offsetLatLng, zoom: 18.0);
    _openDetailSheet();
  }

  Future<void> _openDetailSheet() async {
    final mapProvider = context.read<MapProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) {
        return Padding(
          // Garante que não colemos na AppBar
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 70,
          ),
          child: Container(
            decoration: ShapeDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              shape: kAppShapeTop,
              shadows: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30),
              ],
            ),
            child: ClipPath(
              clipper: ShapeBorderClipper(shape: kAppShapeTop),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.9),
                  ),
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.45,
                    minChildSize: 0.25,
                    maxChildSize: 0.95, // Limite interno
                    expand: false,
                    builder: (context, scrollController) {
                      return Consumer<MapProvider>(
                        builder: (context, provider, _) {
                          if (provider.selectedStop == null)
                            return const SizedBox();
                          return FutureBuilder<List<BusLocationModel>>(
                            future: provider.fetchBusesForStop(
                              provider.selectedStop!,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return StopDetailSheetContent(
                                scrollController: scrollController,
                                stop: provider.selectedStop!,
                                buses: snapshot.data ?? [],
                                onBack: () => Navigator.pop(context),
                                // AÇÃO DE CLICAR NO ÔNIBUS
                                onBusTap: (bus) {
                                  Navigator.pop(context); // Fecha a sheet
                                  // Pequeno delay para a animação de fechar não engasgar o mapa
                                  Future.delayed(
                                    const Duration(milliseconds: 100),
                                    () {
                                      _animateToLocation(
                                        bus.latLng,
                                        zoom: 19.0,
                                      ); // Zoom bem perto
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) mapProvider.clearSelectedStop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final locationProvider = context.watch<LocationProvider>();
    final isDarkTheme = themeProvider.isDarkMode;

    if (!_hasCenteredInitially && locationProvider.currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateToLocation(locationProvider.currentPosition!);
        setState(() => _hasCenteredInitially = true);
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,

      // HEADER COM VERMELHO FORTE
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              // Cor FORTE e vibrante
              color: primaryRed.withOpacity(0.85),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_bus_filled_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cadê o Circular?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900, // Extra Bold
                        color: Colors.white,
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.white,
                    ),
                    onPressed: () => context.read<ThemeProvider>().toggle(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _searchFocusNode.unfocus(),
              child: MapWidget(
                mapController: _mapController,
                currentPosition: locationProvider.currentPosition,
                isDarkTheme: isDarkTheme,
                busStops: context.watch<MapProvider>().displayStops,
                activeBuses: context.watch<MapProvider>().liveBuses,
                routePoints: context.watch<MapProvider>().routePoints,
                onStopMarkerTap: _onStopSelected,
              ),
            ),
          ),

          if (locationProvider.currentPosition == null)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kRadiusMedium),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      color: Colors.black.withOpacity(0.6),
                      child: Text(
                        locationProvider.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // BOTÃO LOCALIZAÇÃO PADRONIZADO
          Positioned(
            right: 20,
            bottom: MediaQuery.of(context).size.height * 0.15,
            child: Container(
              height: 60, // Levemente maior
              width: 60,
              decoration: ShapeDecoration(
                shape: kAppShape,
                color: Theme.of(context).colorScheme.surfaceContainer,
                shadows: appShadows,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(kRadiusPill),
                  child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap:
                      locationProvider.currentPosition == null
                          ? null
                          : () => _animateToLocation(
                            locationProvider.currentPosition!,
                            zoom: 18.0,
                          ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: primaryRed, // Vermelho forte
                    size: 28,
                  ),
                ),
              )),
            ),
          ),

          FloatingSearchBottomSheet(
            focusNode: _searchFocusNode,
            onStopSelected: _onStopSelected,
          ),
        ],
      ),
    );
  }
}
