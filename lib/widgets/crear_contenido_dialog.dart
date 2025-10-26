import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/contenido_service.dart';
import '../../utils/file_picker_helper.dart';
import '../../utils/logger.dart';
import '../../features/contenido/data/models/contenido_model.dart' as ContenidoModelAlias;
import '../../models/contenido_unificado.dart';

class CrearContenidoDialog extends StatefulWidget {
  final ContenidoService contenidoService;
  final Function() onSuccess;

  const CrearContenidoDialog({
    super.key,
    required this.contenidoService,
    required this.onSuccess,
  });

  @override
  State<CrearContenidoDialog> createState() => _CrearContenidoDialogState();
}

class _CrearContenidoDialogState extends State<CrearContenidoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _urlController = TextEditingController();
  final _autorController = TextEditingController();
  final _duracionController = TextEditingController();

  String _tipoSeleccionado = 'video';
  String _categoriaSeleccionada = 'nutricion';
  String _nivelSeleccionado = 'basico';
  bool _usarArchivo = true;
  PlatformFile? _archivoSeleccionado;
  bool _subiendo = false;
  double _progresoSubida = 0.0;

  final List<Map<String, String>> _tipos = [
    {'value': 'video', 'label': '🎬 Video'},
    {'value': 'audio', 'label': '🎵 Audio'},
    {'value': 'documento', 'label': '📄 Documento'},
    {'value': 'imagen', 'label': '🖼️ Imagen'},
  ];

  final List<Map<String, String>> _categorias = [
    {'value': 'nutricion', 'label': 'Nutrición'},
    {'value': 'cuidado_prenatal', 'label': 'Cuidado Prenatal'},
    {'value': 'signos_alarma', 'label': 'Signos de Alarma'},
    {'value': 'lactancia', 'label': 'Lactancia'},
    {'value': 'parto', 'label': 'Parto'},
    {'value': 'posparto', 'label': 'Posparto'},
    {'value': 'planificacion', 'label': 'Planificación'},
    {'value': 'salud_mental', 'label': 'Salud Mental'},
    {'value': 'ejercicio', 'label': 'Ejercicio'},
    {'value': 'higiene', 'label': 'Higiene'},
    {'value': 'derechos', 'label': 'Derechos'},
    {'value': 'otros', 'label': 'Otros'},
  ];

  final List<Map<String, String>> _niveles = [
    {'value': 'basico', 'label': 'Básico'},
    {'value': 'intermedio', 'label': 'Intermedio'},
    {'value': 'avanzado', 'label': 'Avanzado'},
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _urlController.dispose();
    _autorController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarArchivo() async {
    try {
      final archivo = await FilePickerHelper.pickFileByType(_tipoSeleccionado);
      if (archivo != null) {
        setState(() {
          _archivoSeleccionado = archivo;
        });
        
        final info = FilePickerHelper.getFileInfo(archivo);
        appLogger.info('Archivo seleccionado: ${info['nombre']}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo seleccionado: ${info['nombre']}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      appLogger.error('Error seleccionando archivo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _guardarContenido() async {
    if (!_formKey.currentState!.validate()) return;

    if (_usarArchivo && _archivoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un archivo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_usarArchivo && _urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa una URL'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _subiendo = true;
      _progresoSubida = 0.0;
    });

    try {
      final contenidoModel = ContenidoModelAlias.ContenidoModel(
        id: '', // ID vacío para nuevo contenido
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        categoria: _categoriaSeleccionada,
        tipo: _tipoSeleccionado,
        url: _usarArchivo ? null : _urlController.text.trim(),
        urlContenido: _usarArchivo ? null : _urlController.text.trim(),
        thumbnailUrl: null,
        imagenUrl: null,
        nivel: _nivelSeleccionado,
        etiquetas: const [],
        activo: true,
        favorito: false,
        fechaPublicacion: DateTime.now(),
        fechaCreacion: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Convertir ContenidoModel a ContenidoUnificado
      final contenido = ContenidoUnificado(
        id: contenidoModel.id,
        titulo: contenidoModel.titulo,
        descripcion: contenidoModel.descripcion,
        categoria: contenidoModel.categoria,
        tipo: contenidoModel.tipo, // Corrección: usar tipo
        urlContenido: contenidoModel.urlContenido,
        urlImagen: contenidoModel.imagenUrl, // Corrección: usar urlImagen
        duracionMinutos: int.tryParse(_duracionController.text), // Corrección: usar duracionMinutos
        nivel: contenidoModel.nivel, // Corrección: usar nivel
        tags: contenidoModel.etiquetas, // Corrección: usar tags
        fechaCreacion: contenidoModel.fechaCreacion,
        fechaActualizacion: contenidoModel.updatedAt, // Corrección: usar fechaActualizacion
        activo: contenidoModel.activo,
      );
      
      await widget.contenidoService.saveContenido(contenido);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Contenido creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess();
      }
    } catch (e) {
      appLogger.error('Error creando contenido: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _subiendo = false;
          _progresoSubida = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Nuevo Contenido Educativo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      TextFormField(
                        controller: _tituloController,
                        decoration: const InputDecoration(
                          labelText: 'Título *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El título es requerido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Descripción
                      TextFormField(
                        controller: _descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La descripción es requerida';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Tipo de contenido
                      DropdownButtonFormField<String>(
                        initialValue: _tipoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Contenido *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _tipos.map((tipo) {
                          return DropdownMenuItem(
                            value: tipo['value'],
                            child: Text(tipo['label']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _tipoSeleccionado = value!;
                            _archivoSeleccionado = null;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Categoría
                      DropdownButtonFormField<String>(
                        initialValue: _categoriaSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Categoría *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.folder),
                        ),
                        items: _categorias.map((cat) {
                          return DropdownMenuItem(
                            value: cat['value'],
                            child: Text(cat['label']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _categoriaSeleccionada = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Nivel
                      DropdownButtonFormField<String>(
                        initialValue: _nivelSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Nivel de Dificultad',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.signal_cellular_alt),
                        ),
                        items: _niveles.map((nivel) {
                          return DropdownMenuItem(
                            value: nivel['value'],
                            child: Text(nivel['label']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _nivelSeleccionado = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Switch: Archivo vs URL
                      Row(
                        children: [
                          const Text('Fuente del contenido:'),
                          const SizedBox(width: 16),
                          ChoiceChip(
                            label: const Text('Subir Archivo'),
                            selected: _usarArchivo,
                            onSelected: (selected) {
                              setState(() {
                                _usarArchivo = true;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('URL Externa'),
                            selected: !_usarArchivo,
                            onSelected: (selected) {
                              setState(() {
                                _usarArchivo = false;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Selector de archivo o URL
                      if (_usarArchivo) ...[
                        // Botón para seleccionar archivo
                        OutlinedButton.icon(
                          onPressed: _seleccionarArchivo,
                          icon: const Icon(Icons.attach_file),
                          label: Text(
                            _archivoSeleccionado == null
                                ? 'Seleccionar Archivo'
                                : 'Cambiar Archivo',
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),

                        // Info del archivo seleccionado
                        if (_archivoSeleccionado != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        FilePickerHelper.getFileInfo(_archivoSeleccionado!)['nombre'],
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        FilePickerHelper.formatFileSize(
                                          FilePickerHelper.getFileInfo(_archivoSeleccionado!)['tamaño'],
                                        ),
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else ...[
                        // Campo de URL
                        TextFormField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            labelText: 'URL del Contenido *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.link),
                            hintText: 'https://...',
                          ),
                          validator: (value) {
                            if (!_usarArchivo && (value == null || value.isEmpty)) {
                              return 'La URL es requerida';
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Duración (opcional)
                      if (_tipoSeleccionado == 'video' || _tipoSeleccionado == 'audio')
                        TextFormField(
                          controller: _duracionController,
                          decoration: const InputDecoration(
                            labelText: 'Duración (segundos)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timer),
                          ),
                          keyboardType: TextInputType.number,
                        ),

                      // Progreso de subida
                      if (_subiendo) ...[
                        const SizedBox(height: 24),
                        Column(
                          children: [
                            LinearProgressIndicator(
                              value: _progresoSubida,
                              minHeight: 8,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Subiendo... ${(_progresoSubida * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Footer con botones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _subiendo ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _subiendo ? null : _guardarContenido,
                    icon: _subiendo
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_subiendo ? 'Subiendo...' : 'Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

