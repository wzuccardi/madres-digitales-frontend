import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/ips_service.dart';
import '../services/municipio_service.dart';
import '../providers/service_providers.dart';
import '../shared/widgets/app_bar_with_logo.dart';
import '../utils/logger.dart';

class IPSFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? ips;

  const IPSFormScreen({super.key, this.ips});

  @override
  ConsumerState<IPSFormScreen> createState() => _IPSFormScreenState();
}

class _IPSFormScreenState extends ConsumerState<IPSFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final IPSService _ipsService;
  final MunicipioService _municipioService = MunicipioService();
  
  // Controladores
  final _nombreController = TextEditingController();
  final _nitController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  
  String _nivelAtencion = 'primario';
  String? _municipioId;
  bool _activa = true;
  bool _isLoading = false;
  bool _isLoadingMunicipios = true;
  bool _isLoadingLocation = false;
  
  // Coordenadas GPS
  double? _latitud;
  double? _longitud;
  String? _ubicacionTexto;
  
  List<Map<String, dynamic>> _municipios = [];

  @override
  void initState() {
    super.initState();
    appLogger.info('IPSFormScreen: Inicializando formulario');
    _ipsService = IPSService(ref.read(apiServiceProvider));
    _loadMunicipios();
    
    if (widget.ips != null) {
      _loadIPSData();
    }
  }

  Future<void> _loadMunicipios() async {
    try {
      appLogger.info('IPSFormScreen: Cargando municipios desde la API...');
      
      final municipiosData = await _municipioService.getAllMunicipios();
      appLogger.info('IPSFormScreen: ${municipiosData.length} municipios cargados desde la API');
      
      setState(() {
        _municipios = municipiosData.map((municipio) => {
          'id': municipio['id'].toString(),
          'nombre': municipio['nombre'].toString(),
        }).toList();
        
        _isLoadingMunicipios = false;
        
        if (_municipioId == null && _municipios.isNotEmpty) {
          _municipioId = _municipios.first['id'];
        }
      });
    } catch (e) {
      appLogger.error('IPSFormScreen: Error cargando municipios desde API', error: e);
      
      setState(() {
        _isLoadingMunicipios = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando municipios: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _loadIPSData() {
    final ips = widget.ips!;
    _nombreController.text = ips['nombre'] ?? '';
    _nitController.text = ips['nit'] ?? '';
    _direccionController.text = ips['direccion'] ?? '';
    _telefonoController.text = ips['telefono'] ?? '';
    _emailController.text = ips['email'] ?? '';
    _nivelAtencion = ips['nivel'] ?? 'primario';
    _municipioId = ips['municipio_id'];
    _activa = ips['activa'] ?? true;
    
    // Cargar coordenadas si existen
    if (ips['latitud'] != null) {
      _latitud = double.tryParse(ips['latitud'].toString());
    }
    if (ips['longitud'] != null) {
      _longitud = double.tryParse(ips['longitud'].toString());
    }
    
    // Generar texto de ubicación si hay coordenadas
    if (_latitud != null && _longitud != null) {
      _ubicacionTexto = 'Lat: ${_latitud!.toStringAsFixed(6)}, Lng: ${_longitud!.toStringAsFixed(6)}';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _nitController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _obtenerUbicacionActual() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      appLogger.info('IPSFormScreen: Verificando permisos de ubicación...');
      
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('El servicio de ubicación está deshabilitado');
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación denegados permanentemente');
      }

      appLogger.info('IPSFormScreen: Obteniendo posición actual...');
      
      // Obtener la posición actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _latitud = position.latitude;
        _longitud = position.longitude;
        _ubicacionTexto = 'Lat: ${_latitud!.toStringAsFixed(6)}, Lng: ${_longitud!.toStringAsFixed(6)}';
        _isLoadingLocation = false;
      });

      appLogger.info('IPSFormScreen: Ubicación obtenida: $_ubicacionTexto');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación obtenida exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      appLogger.error('IPSFormScreen: Error obteniendo ubicación', error: e);
      
      setState(() {
        _isLoadingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error obteniendo ubicación: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _saveIPS() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'nombre': _nombreController.text.trim(),
        'nit': _nitController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'email': _emailController.text.trim(),
        'nivel': _nivelAtencion,
        'municipio_id': _municipioId,
        'activa': _activa,
        'latitud': _latitud,
        'longitud': _longitud,
      };

      if (widget.ips != null) {
        final id = widget.ips!['id'].toString();
        await _ipsService.actualizarIPS(id, data);
        appLogger.info('IPSFormScreen: IPS actualizada exitosamente');
      } else {
        await _ipsService.crearIPS(data);
        appLogger.info('IPSFormScreen: IPS creada exitosamente');
      }

      if (!mounted) return;
      
      final mensaje = widget.ips != null 
        ? 'IPS actualizada exitosamente' 
        : 'IPS creada exitosamente';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop(true);
      
    } catch (e) {
      appLogger.error('IPSFormScreen: Error durante el guardado', error: e);
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar IPS: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithLogo(
        title: widget.ips != null ? 'Editar IPS' : 'Nueva IPS',
      ),
      body: _isLoadingMunicipios
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información Básica',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de la IPS *',
                              prefixIcon: Icon(Icons.business),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre es requerido';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _nitController,
                            decoration: const InputDecoration(
                              labelText: 'NIT',
                              prefixIcon: Icon(Icons.numbers),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _direccionController,
                            decoration: const InputDecoration(
                              labelText: 'Dirección *',
                              prefixIcon: Icon(Icons.location_on),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La dirección es requerida';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<String>(
                            initialValue: _municipioId,
                            decoration: const InputDecoration(
                              labelText: 'Municipio',
                              prefixIcon: Icon(Icons.location_city),
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Seleccionar Municipio'),
                              ),
                              ..._municipios.map((municipio) {
                                return DropdownMenuItem<String>(
                                  value: municipio['id'],
                                  child: Text(municipio['nombre']),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _municipioId = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información de Contacto',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _telefonoController,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<String>(
                            initialValue: _nivelAtencion,
                            decoration: const InputDecoration(
                              labelText: 'Nivel de Atención',
                              prefixIcon: Icon(Icons.local_hospital),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'primario', child: Text('Primario')),
                              DropdownMenuItem(value: 'secundario', child: Text('Secundario')),
                              DropdownMenuItem(value: 'terciario', child: Text('Terciario')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _nivelAtencion = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sección de Ubicación GPS
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ubicación GPS',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'La ubicación GPS permite encontrar las IPS más cercanas a las gestantes',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Mostrar coordenadas actuales
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                              color: _latitud != null && _longitud != null 
                                ? Colors.green[50] 
                                : Colors.grey[50],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _latitud != null && _longitud != null 
                                        ? Icons.location_on 
                                        : Icons.location_off,
                                      color: _latitud != null && _longitud != null 
                                        ? Colors.green 
                                        : Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _latitud != null && _longitud != null 
                                        ? 'Ubicación capturada' 
                                        : 'Sin ubicación',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _latitud != null && _longitud != null 
                                          ? Colors.green[700] 
                                          : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                if (_ubicacionTexto != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _ubicacionTexto!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Botón para obtener ubicación
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoadingLocation ? null : _obtenerUbicacionActual,
                              icon: _isLoadingLocation
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.my_location),
                              label: Text(_isLoadingLocation 
                                ? 'Obteniendo ubicación...' 
                                : 'Obtener Ubicación Actual'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          
                          if (_latitud != null && _longitud != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _latitud = null;
                                        _longitud = null;
                                        _ubicacionTexto = null;
                                      });
                                    },
                                    icon: const Icon(Icons.clear, size: 16),
                                    label: const Text('Limpiar'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveIPS,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(widget.ips != null ? 'Actualizar' : 'Crear'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}