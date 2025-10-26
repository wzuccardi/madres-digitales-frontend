import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/geolocalizacion.dart';
import '../services/geolocalizacion_service.dart';
import '../services/logger_service.dart';

/// Pantalla de mapa interactivo
class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final _geoService = GeolocalizacionService();
  final _logger = LoggerService();
  final _mapController = MapController();

  LatLng _centro = const LatLng(10.4, -75.5); // Bolívar, Colombia
  double _zoom = 10.0;
  
  List<EntidadCercana> _entidadesCercanas = [];
  List<ZonaCobertura> _zonasCobertura = [];
  PuntoGeo? _ubicacionActual;
  RutaCalculada? _rutaActual;
  
  bool _isLoading = false;
  bool _mostrarGestantes = true;
  bool _mostrarIPS = true;
  bool _mostrarZonas = true;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await _obtenerUbicacionActual();
    await _cargarDatos();
  }

  Future<void> _obtenerUbicacionActual() async {
    try {
      final ubicacion = await _geoService.obtenerUbicacionActual();
      if (ubicacion != null) {
        setState(() {
          _ubicacionActual = ubicacion;
          _centro = ubicacion.latLng;
        });
        _mapController.move(_centro, _zoom);
      }
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo ubicación', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      // Cargar entidades cercanas
      if (_ubicacionActual != null) {
        final entidades = await _geoService.buscarCercanos(
          latitud: _ubicacionActual!.latitud,
          longitud: _ubicacionActual!.longitud,
          radio: 50,
          tipo: 'todos',
          limit: 100,
        );

        setState(() {
          _entidadesCercanas = entidades;
        });
      }

      // Cargar zonas de cobertura
      final zonas = await _geoService.obtenerZonasCobertura();
      setState(() {
        _zonasCobertura = zonas;
      });
    } catch (e, stackTrace) {
      _logger.error('Error cargando datos del mapa', error: e, stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando datos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centrarEnUbicacionActual,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMapa(),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          _buildLeyenda(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoom_in',
            mini: true,
            onPressed: () {
              setState(() => _zoom = (_zoom + 1).clamp(1, 18));
              _mapController.move(_centro, _zoom);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoom_out',
            mini: true,
            onPressed: () {
              setState(() => _zoom = (_zoom - 1).clamp(1, 18));
              _mapController.move(_centro, _zoom);
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Widget _buildMapa() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _centro,
        initialZoom: _zoom,
        onTap: (tapPosition, point) {
          _logger.info('Tap en mapa', data: {
            'lat': point.latitude,
            'lon': point.longitude,
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.madresdigitales.app',
        ),
        
        // Zonas de cobertura
        if (_mostrarZonas)
          ..._zonasCobertura.map((zona) => PolygonLayer(
            polygons: [
              Polygon(
                points: zona.poligono.latLngs,
                color: _parseColor(zona.color ?? '#4ECDC4').withValues(alpha: 0.3),
                borderColor: _parseColor(zona.color ?? '#4ECDC4'),
                borderStrokeWidth: 2,
                // isFilled: true, // Parámetro obsoleto, eliminando advertencia
              ),
            ],
          )),

        // Marcadores de entidades
        MarkerLayer(
          markers: [
            // Ubicación actual
            if (_ubicacionActual != null)
              Marker(
                point: _ubicacionActual!.latLng,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 40,
                ),
              ),

            // Gestantes
            if (_mostrarGestantes)
              ..._entidadesCercanas
                  .where((e) => e.tipo == 'gestante')
                  .map((e) => Marker(
                        point: e.ubicacion.latLng,
                        width: 30,
                        height: 30,
                        child: GestureDetector(
                          onTap: () => _mostrarDetalleEntidad(e),
                          child: const Icon(
                            Icons.person_pin_circle,
                            color: Colors.pink,
                            size: 30,
                          ),
                        ),
                      )),

            // IPS
            if (_mostrarIPS)
              ..._entidadesCercanas
                  .where((e) => e.tipo == 'ips')
                  .map((e) => Marker(
                        point: e.ubicacion.latLng,
                        width: 30,
                        height: 30,
                        child: GestureDetector(
                          onTap: () => _mostrarDetalleEntidad(e),
                          child: const Icon(
                            Icons.local_hospital,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      )),
          ],
        ),

        // Ruta actual
        if (_rutaActual != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _rutaActual!.latLngs,
                color: Colors.blue,
                strokeWidth: 4,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildLeyenda() {
    return Positioned(
      top: 16,
      right: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Leyenda',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildLeyendaItem(Icons.person_pin_circle, 'Gestantes', Colors.pink),
              _buildLeyendaItem(Icons.local_hospital, 'IPS', Colors.red),
              _buildLeyendaItem(Icons.my_location, 'Mi ubicación', Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeyendaItem(IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _centrarEnUbicacionActual() {
    if (_ubicacionActual != null) {
      _mapController.move(_ubicacionActual!.latLng, 14);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicación no disponible')),
      );
    }
  }

  void _mostrarFiltros() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Mostrar Gestantes'),
              value: _mostrarGestantes,
              onChanged: (value) {
                setState(() => _mostrarGestantes = value ?? true);
                Navigator.pop(context);
              },
            ),
            CheckboxListTile(
              title: const Text('Mostrar IPS'),
              value: _mostrarIPS,
              onChanged: (value) {
                setState(() => _mostrarIPS = value ?? true);
                Navigator.pop(context);
              },
            ),
            CheckboxListTile(
              title: const Text('Mostrar Zonas'),
              value: _mostrarZonas,
              onChanged: (value) {
                setState(() => _mostrarZonas = value ?? true);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalleEntidad(EntidadCercana entidad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entidad.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${entidad.tipo}'),
            Text('Distancia: ${entidad.distanciaFormateada}'),
            if (entidad.direccion != null) Text('Dirección: ${entidad.direccion}'),
            if (entidad.telefono != null) Text('Teléfono: ${entidad.telefono}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          if (_ubicacionActual != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _calcularRuta(entidad.ubicacion);
              },
              child: const Text('Calcular Ruta'),
            ),
        ],
      ),
    );
  }

  Future<void> _calcularRuta(PuntoGeo destino) async {
    if (_ubicacionActual == null) return;

    try {
      final ruta = await _geoService.calcularRuta(
        origen: _ubicacionActual!,
        destino: destino,
      );

      setState(() {
        _rutaActual = ruta;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ruta: ${ruta.distanciaFormateada} - ${ruta.duracionFormateada}',
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.error('Error calculando ruta', error: e, stackTrace: stackTrace);
    }
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

