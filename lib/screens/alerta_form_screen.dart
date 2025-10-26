import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/services/alerta_service.dart';
import 'package:madres_digitales_flutter_new/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';

class AlertaFormScreen extends ConsumerStatefulWidget {
  const AlertaFormScreen({super.key});

  @override
  ConsumerState<AlertaFormScreen> createState() => _AlertaFormScreenState();
}

class _AlertaFormScreenState extends ConsumerState<AlertaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mensajeController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  String? _gestanteSeleccionada;
  String _tipoAlerta = 'manual';
  String _nivelPrioridad = 'media';
  final List<String> _sintomasSeleccionados = [];
  List<dynamic> _gestantesDisponibles = [];
  bool _isLoading = false;
  bool _isLoadingGestantes = true;

  @override
  void initState() {
    super.initState();
    _cargarGestantesDisponibles();
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _cargarGestantesDisponibles() async {
    try {
      final alertaService = AlertaService(ref.read(apiServiceProvider));
      final gestantes = await alertaService.obtenerGestantesDisponibles();
      
      setState(() {
        _gestantesDisponibles = gestantes;
        _isLoadingGestantes = false;
      });
    } catch (e) {
      appLogger.error('Error cargando gestantes disponibles', error: e);
      setState(() {
        _isLoadingGestantes = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando gestantes: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _crearAlerta() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gestanteSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar una gestante'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final alertaService = AlertaService(ref.read(apiServiceProvider));
      
      await alertaService.crearAlerta(
        gestanteId: _gestanteSeleccionada!,
        tipoAlerta: _tipoAlerta,
        nivelPrioridad: _nivelPrioridad,
        mensaje: _mensajeController.text.trim(),
        sintomas: _sintomasSeleccionados,
        descripcionDetallada: _descripcionController.text.trim().isNotEmpty 
            ? _descripcionController.text.trim() 
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerta creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Retornar true para indicar éxito
      }
    } catch (e) {
      appLogger.error('Error creando alerta', error: e);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creando alerta: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getPriorityColor(String prioridad) {
    switch (prioridad) {
      case 'critica': return Colors.red;
      case 'alta': return Colors.orange;
      case 'media': return Colors.yellow[700]!;
      case 'baja': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getPriorityIcon(String prioridad) {
    switch (prioridad) {
      case 'critica': return Icons.warning;
      case 'alta': return Icons.priority_high;
      case 'media': return Icons.info;
      case 'baja': return Icons.info_outline;
      default: return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Alerta'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoadingGestantes
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selección de gestante
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.blue[600]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Gestante',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _gestanteSeleccionada,
                              decoration: const InputDecoration(
                                labelText: 'Seleccionar gestante *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.search),
                              ),
                              items: _gestantesDisponibles.map((gestante) {
                                return DropdownMenuItem<String>(
                                  value: gestante['id'],
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        gestante['nombre'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      if (gestante['documento'] != null && gestante['documento'].isNotEmpty)
                                        Text(
                                          'CC: ${gestante['documento']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _gestanteSeleccionada = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Debe seleccionar una gestante';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tipo de alerta y prioridad
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange[600]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Tipo y Prioridad',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Tipo de alerta
                            DropdownButtonFormField<String>(
                              initialValue: _tipoAlerta,
                              decoration: const InputDecoration(
                                labelText: 'Tipo de alerta',
                                border: OutlineInputBorder(),
                              ),
                              items: AlertaService.tiposAlerta.map((tipo) {
                                String displayText;
                                switch (tipo) {
                                  case 'manual': displayText = 'Alerta Manual'; break;
                                  case 'emergencia_obstetrica': displayText = 'Emergencia Obstétrica'; break;
                                  case 'hipertension': displayText = 'Hipertensión'; break;
                                  case 'preeclampsia': displayText = 'Preeclampsia'; break;
                                  case 'sepsis': displayText = 'Sepsis Materna'; break;
                                  case 'hemorragia': displayText = 'Hemorragia'; break;
                                  case 'parto_prematuro': displayText = 'Parto Prematuro'; break;
                                  default: displayText = tipo;
                                }
                                return DropdownMenuItem<String>(
                                  value: tipo,
                                  child: Text(displayText),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _tipoAlerta = value!;
                                });
                              },
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Nivel de prioridad
                            DropdownButtonFormField<String>(
                              initialValue: _nivelPrioridad,
                              decoration: const InputDecoration(
                                labelText: 'Nivel de prioridad',
                                border: OutlineInputBorder(),
                              ),
                              items: AlertaService.nivelesPrioridad.map((prioridad) {
                                return DropdownMenuItem<String>(
                                  value: prioridad,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getPriorityIcon(prioridad),
                                        color: _getPriorityColor(prioridad),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(prioridad.toUpperCase()),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _nivelPrioridad = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Mensaje
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.message, color: Colors.green[600]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Mensaje',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _mensajeController,
                              decoration: const InputDecoration(
                                labelText: 'Mensaje de la alerta *',
                                border: OutlineInputBorder(),
                                hintText: 'Describa brevemente la situación...',
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El mensaje es requerido';
                                }
                                if (value.trim().length < 10) {
                                  return 'El mensaje debe tener al menos 10 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descripcionController,
                              decoration: const InputDecoration(
                                labelText: 'Descripción detallada (opcional)',
                                border: OutlineInputBorder(),
                                hintText: 'Información adicional...',
                              ),
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Síntomas
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.healing, color: Colors.purple[600]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Síntomas (opcional)',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: AlertaService.sintomasComunes.map((sintoma) {
                                final isSelected = _sintomasSeleccionados.contains(sintoma);
                                String displayText = sintoma.replaceAll('_', ' ').toUpperCase();
                                
                                return FilterChip(
                                  label: Text(
                                    displayText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _sintomasSeleccionados.add(sintoma);
                                      } else {
                                        _sintomasSeleccionados.remove(sintoma);
                                      }
                                    });
                                  },
                                  selectedColor: Colors.red[400],
                                  checkmarkColor: Colors.white,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Botón crear alerta
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _crearAlerta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_alert),
                                  SizedBox(width: 8),
                                  Text(
                                    'CREAR ALERTA',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}