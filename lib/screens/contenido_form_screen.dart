import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import '../models/contenido_unificado.dart';
import '../providers/service_providers.dart';
import '../shared/theme/app_theme.dart';
import '../shared/widgets/custom_button.dart';
import '../utils/logger.dart';

class ContenidoFormScreen extends ConsumerStatefulWidget {
  final ContenidoUnificado? contenido;
  final bool isSimpleMode;

  const ContenidoFormScreen({super.key, this.contenido, this.isSimpleMode = false});

  @override
  ConsumerState<ContenidoFormScreen> createState() => _ContenidoFormScreenState();
}

class _ContenidoFormScreenState extends ConsumerState<ContenidoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _urlController = TextEditingController();
  final _duracionController = TextEditingController();

  String _tipoSeleccionado = 'VIDEO';
  String _categoriaSeleccionada = 'EMBARAZO';
  String _nivelSeleccionado = 'BASICO';
  bool _isLoading = false;

  // Para archivo local
  PlatformFile? _archivoSeleccionado;
  bool _usarUrl = true; // true = URL, false = archivo local

  final List<String> _tipos = ['VIDEO', 'ARTICULO', 'INFOGRAFIA', 'PDF', 'AUDIO'];
  final List<String> _categorias = [
    'EMBARAZO',
    'PARTO',
    'POSPARTO',
    'LACTANCIA',
    'NUTRICION',
    'EJERCICIO',
    'SALUD_MENTAL',
    'CUIDADO_BEBE',
  ];
  final List<String> _niveles = ['BASICO', 'INTERMEDIO', 'AVANZADO'];

  @override
  void initState() {
    super.initState();
    if (widget.contenido != null) {
      _tituloController.text = widget.contenido!.titulo;
      _descripcionController.text = widget.contenido!.descripcion ?? ''; // Corrección: descripcion es nullable
      _urlController.text = widget.contenido!.urlContenido ?? '';
      _duracionController.text = widget.contenido!.duracionMinutos?.toString() ?? ''; // Corrección: usar duracionMinutos
      _tipoSeleccionado = widget.contenido!.tipo.toUpperCase(); // Corrección: usar tipo
      _categoriaSeleccionada = widget.contenido!.categoria.toUpperCase();
      _nivelSeleccionado = widget.contenido!.nivel?.toUpperCase() ?? 'BASICO'; // Corrección: usar nivel
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _urlController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarArchivo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'mp4', 'mp3', 'jpg', 'jpeg', 'png', 'webp'],
        withData: true, // Importante para web
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _archivoSeleccionado = result.files.first;
          _usarUrl = false;
          _urlController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Archivo seleccionado: ${_archivoSeleccionado!.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al seleccionar archivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _limpiarArchivo() {
    setState(() {
      _archivoSeleccionado = null;
      _usarUrl = true;
    });
  }

  String _mapearTipoParaBackend(String tipo) {
    // Mapear tipos del frontend a los valores que espera el backend
    switch (tipo.toUpperCase()) {
      case 'PDF':
        return 'documento';
      case 'IMAGEN':
        return 'imagen';
      default:
        return tipo.toLowerCase();
    }
  }

  String _mapearCategoriaParaBackend(String categoria) {
    // Mapear categorías del frontend a los valores que espera el backend
    switch (categoria.toUpperCase()) {
      case 'EMBARAZO':
        return 'embarazo'; // Corregido: era 'nutricion'
      case 'PARTO':
        return 'parto';
      case 'POSPARTO':
        return 'posparto';
      case 'LACTANCIA':
        return 'lactancia';
      case 'NUTRICION':
        return 'nutricion';
      case 'EJERCICIO':
        return 'ejercicio';
      case 'SALUD_MENTAL':
        return 'salud_mental';
      case 'CUIDADO_BEBE':
        return 'cuidado_bebe'; // Corregido: era 'cuidado_prenatal'
      default:
        return categoria.toLowerCase();
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final contenidoServiceAsync = ref.read(contenidoServiceProvider);
      final contenidoService = contenidoServiceAsync.when(
        data: (service) => service,
        loading: () => throw Exception('Servicio de contenido no está disponible'),
        error: (error, stack) => throw Exception('Error cargando servicio de contenido: $error'),
      );

      if (widget.contenido == null) {
        // Crear nuevo
        // Validar que se haya proporcionado un archivo o una URL
        if (!_usarUrl && _archivoSeleccionado == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Debes proporcionar una URL o seleccionar un archivo'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        
        final contenido = ContenidoUnificado(
          id: '', // ID vacío para nuevo contenido
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          categoria: _mapearCategoriaParaBackend(_categoriaSeleccionada),
          tipo: _mapearTipoParaBackend(_tipoSeleccionado), // Corrección: usar tipo
          urlContenido: _usarUrl && _urlController.text.trim().isNotEmpty
              ? _urlController.text.trim()
              : null,
          urlImagen: null, // Corrección: usar urlImagen
          duracionMinutos: _duracionController.text.trim().isNotEmpty // Corrección: usar duracionMinutos
              ? int.tryParse(_duracionController.text.trim())
              : null,
          nivel: _nivelSeleccionado.toLowerCase(), // Corrección: usar nivel
          tags: [], // Corrección: usar tags
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(), // Corrección: usar fechaActualizacion
          activo: true,
          archivo: _archivoSeleccionado?.name, // Agregar el nombre del archivo seleccionado
        );
        
        // Si hay un archivo seleccionado, necesitamos prepararlo para el FormData
        if (!_usarUrl && _archivoSeleccionado != null) {
          await _guardarConArchivo(contenido, contenidoService);
        } else {
          await contenidoService.saveContenido(contenido);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Contenido creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Actualizar existente
        final contenido = ContenidoUnificado(
          id: widget.contenido!.id,
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          categoria: _mapearCategoriaParaBackend(_categoriaSeleccionada),
          tipo: _mapearTipoParaBackend(_tipoSeleccionado), // Corrección: usar tipo
          urlContenido: _urlController.text.trim().isNotEmpty ? _urlController.text.trim() : null,
          urlImagen: widget.contenido!.urlImagen, // Corrección: usar urlImagen
          duracionMinutos: _duracionController.text.trim().isNotEmpty // Corrección: usar duracionMinutos
              ? int.tryParse(_duracionController.text.trim())
              : widget.contenido!.duracionMinutos,
          nivel: _nivelSeleccionado.toLowerCase(), // Corrección: usar nivel
          tags: widget.contenido!.tags, // Corrección: usar tags
          fechaCreacion: widget.contenido!.fechaCreacion,
          fechaActualizacion: DateTime.now(), // Corrección: usar fechaActualizacion
          activo: widget.contenido!.activo,
        );
        
        // Si hay un archivo seleccionado, necesitamos prepararlo para el FormData
        if (!_usarUrl && _archivoSeleccionado != null) {
          await _guardarConArchivo(contenido, contenidoService);
        } else {
          await contenidoService.saveContenido(contenido);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Contenido actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      appLogger.error('Error guardando contenido', error: e);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Guardar contenido con archivo usando FormData
  Future<void> _guardarConArchivo(ContenidoUnificado contenido, dynamic contenidoService) async {
    try {
      // Crear FormData
      final formData = FormData();
      
      // Agregar campos del formulario
      formData.fields.add(MapEntry('titulo', contenido.titulo));
      formData.fields.add(MapEntry('descripcion', contenido.descripcion ?? ''));
      formData.fields.add(MapEntry('categoria', contenido.categoria));
      formData.fields.add(MapEntry('tipo', contenido.tipo));
      
      if (contenido.nivel != null) {
        formData.fields.add(MapEntry('nivel', contenido.nivel!));
      }
      
      if (contenido.duracionMinutos != null) {
        formData.fields.add(MapEntry('duracion', contenido.duracionMinutos.toString()));
      }
      
      if (contenido.tags != null && contenido.tags!.isNotEmpty) {
        // Convertir array de tags a string separado por comas
        formData.fields.add(MapEntry('tags', contenido.tags!.join(',')));
      }
      
      // Agregar el archivo
      if (_archivoSeleccionado != null && _archivoSeleccionado!.bytes != null) {
        formData.files.add(MapEntry(
          'video', // Nombre del campo que espera el backend
          MultipartFile.fromBytes(
            _archivoSeleccionado!.bytes!,
            filename: _archivoSeleccionado!.name,
          ),
        ));
      }
      
      // Enviar usando el ApiService directamente
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.post('/contenido-crud', data: formData);
      
      if (response.statusCode != 201) {
        throw Exception(response.data['message'] ?? 'Error guardando contenido con archivo');
      }
      
      // Invalidar cache
      final offlineService = ref.read(offlineServiceProvider);
      final offlineServiceInstance = offlineService.when(
        data: (service) => service,
        loading: () => throw Exception('Servicio offline no disponible'),
        error: (error, stack) => throw Exception('Error cargando servicio offline: $error'),
      );
      await offlineServiceInstance.clearAllCache();
      
    } catch (e) {
      appLogger.error('Error guardando contenido con archivo', error: e);
      rethrow;
    }
  }

  Future<void> _vistaPrevia() async {
    if (_urlController.text.trim().isNotEmpty) {
      final url = _urlController.text.trim();
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ No se puede abrir la URL'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al abrir URL: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ No hay URL para previsualizar'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _resetearFormulario() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetear formulario'),
        content: const Text('¿Estás seguro de que deseas limpiar todos los campos del formulario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Resetear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _tituloController.clear();
        _descripcionController.clear();
        _urlController.clear();
        _duracionController.clear();
        _tipoSeleccionado = 'VIDEO';
        _categoriaSeleccionada = 'EMBARAZO';
        _nivelSeleccionado = 'BASICO';
        _archivoSeleccionado = null;
        _usarUrl = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Formulario reseteado'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _cargarDesdePlantilla() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cargar desde plantilla'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona una plantilla para cargar:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Video Educativo'),
              subtitle: const Text('Plantilla para videos educativos'),
              onTap: () {
                Navigator.pop(context);
                _aplicarPlantillaVideo();
              },
            ),
            ListTile(
              title: const Text('Artículo Informativo'),
              subtitle: const Text('Plantilla para artículos informativos'),
              onTap: () {
                Navigator.pop(context);
                _aplicarPlantillaArticulo();
              },
            ),
            ListTile(
              title: const Text('Infografía'),
              subtitle: const Text('Plantilla para infografías'),
              onTap: () {
                Navigator.pop(context);
                _aplicarPlantillaInfografia();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _aplicarPlantillaVideo() {
    setState(() {
      _tipoSeleccionado = 'VIDEO';
      _categoriaSeleccionada = 'EMBARAZO';
      _nivelSeleccionado = 'BASICO';
      _tituloController.text = 'Nuevo Video Educativo';
      _descripcionController.text = 'Descripción del video educativo sobre embarazo y cuidados prenatales.';
      _duracionController.text = '300'; // 5 minutos
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Plantilla de video cargada'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _aplicarPlantillaArticulo() {
    setState(() {
      _tipoSeleccionado = 'ARTICULO';
      _categoriaSeleccionada = 'NUTRICION';
      _nivelSeleccionado = 'INTERMEDIO';
      _tituloController.text = 'Nuevo Artículo Informativo';
      _descripcionController.text = 'Artículo informativo sobre nutrición durante el embarazo.';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Plantilla de artículo cargada'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _aplicarPlantillaInfografia() {
    setState(() {
      _tipoSeleccionado = 'INFOGRAFIA';
      _categoriaSeleccionada = 'EJERCICIO';
      _nivelSeleccionado = 'BASICO';
      _tituloController.text = 'Nueva Infografía';
      _descripcionController.text = 'Infografía sobre ejercicios seguros durante el embarazo.';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Plantilla de infografía cargada'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contenido == null
            ? (widget.isSimpleMode ? 'Nuevo Contenido' : 'Nuevo Contenido (Avanzado)')
            : (widget.isSimpleMode ? 'Editar Contenido' : 'Editar Contenido (Avanzado)')),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!widget.isSimpleMode)
            IconButton(
              icon: Icon(widget.isSimpleMode ? Icons.expand_more : Icons.expand_less),
              onPressed: () {
                setState(() {
                  // Cambiar entre modo simple y avanzado
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ContenidoFormScreen(
                        contenido: widget.contenido,
                        isSimpleMode: !widget.isSimpleMode,
                      ),
                    ),
                  );
                });
              },
              tooltip: widget.isSimpleMode ? 'Modo Avanzado' : 'Modo Simple',
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'preview':
                  _vistaPrevia();
                  break;
                case 'reset':
                  _resetearFormulario();
                  break;
                case 'template':
                  _cargarDesdePlantilla();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'preview',
                child: Row(
                  children: [
                    Icon(Icons.preview, size: 20),
                    SizedBox(width: 8),
                    Text('Vista previa'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'template',
                child: Row(
                  children: [
                    Icon(Icons.dashboard_customize, size: 20),
                    SizedBox(width: 8),
                    Text('Cargar plantilla'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Resetear formulario'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El título es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La descripción es requerida (mínimo 10 caracteres)';
                  }
                  if (value.trim().length < 10) {
                    return 'La descripción debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _tipoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo *',
                  border: OutlineInputBorder(),
                ),
                items: _tipos.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(_getNombreTipo(tipo)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _tipoSeleccionado = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _categoriaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Categoría *',
                  border: OutlineInputBorder(),
                ),
                items: _categorias.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(_getNombreCategoria(categoria)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _categoriaSeleccionada = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Campo de nivel solo en modo avanzado
              if (!widget.isSimpleMode) ...[
                DropdownButtonFormField<String>(
                  initialValue: _nivelSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Nivel',
                    border: OutlineInputBorder(),
                  ),
                  items: _niveles.map((nivel) {
                    return DropdownMenuItem(
                      value: nivel,
                      child: Text(_getNombreNivel(nivel)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _nivelSeleccionado = value);
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Sección de archivo/URL
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Contenido del archivo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tabs para seleccionar URL o Archivo
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('URL'),
                            selected: _usarUrl,
                            onSelected: (selected) {
                              setState(() {
                                _usarUrl = true;
                                _archivoSeleccionado = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Archivo Local'),
                            selected: !_usarUrl,
                            onSelected: (selected) {
                              setState(() => _usarUrl = false);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Campo URL o botón de archivo
                    if (_usarUrl)
                      TextFormField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          labelText: 'URL del archivo',
                          hintText: 'https://... o /uploads/...',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_archivoSeleccionado != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                border: Border.all(color: Colors.green),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _archivoSeleccionado!.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${(_archivoSeleccionado!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: _limpiarArchivo,
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _seleccionarArchivo,
                            icon: const Icon(Icons.upload_file),
                            label: Text(_archivoSeleccionado == null
                                ? 'Seleccionar Archivo'
                                : 'Cambiar Archivo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Formatos: PDF, MP4, MP3, JPG, PNG, WEBP',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Campo de duración solo en modo avanzado
              if (!widget.isSimpleMode) ...[
                TextFormField(
                  controller: _duracionController,
                  decoration: const InputDecoration(
                    labelText: 'Duración (segundos)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
              ],
              
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: _isLoading
                          ? 'Guardando...'
                          : (widget.contenido == null ? 'Crear Contenido' : 'Actualizar Contenido'),
                      onPressed: _isLoading ? null : _guardar,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!widget.isSimpleMode && _urlController.text.trim().isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: _vistaPrevia,
                      icon: const Icon(Icons.preview),
                      label: const Text('Vista Previa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _resetearFormulario,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Resetear'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Botones adicionales en modo avanzado
              if (!widget.isSimpleMode) ...[
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _cargarDesdePlantilla,
                        icon: const Icon(Icons.dashboard_customize),
                        label: const Text('Cargar Plantilla'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (widget.contenido != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancelar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
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
    );
  }

  String _getNombreTipo(String tipo) {
    switch (tipo) {
      case 'VIDEO': return 'Video';
      case 'ARTICULO': return 'Artículo';
      case 'INFOGRAFIA': return 'Infografía';
      case 'PDF': return 'PDF';
      case 'AUDIO': return 'Audio';
      default: return tipo;
    }
  }

  String _getNombreCategoria(String categoria) {
    switch (categoria) {
      case 'EMBARAZO': return 'Embarazo';
      case 'PARTO': return 'Parto';
      case 'POSPARTO': return 'Posparto';
      case 'LACTANCIA': return 'Lactancia';
      case 'NUTRICION': return 'Nutrición';
      case 'EJERCICIO': return 'Ejercicio';
      case 'SALUD_MENTAL': return 'Salud Mental';
      case 'CUIDADO_BEBE': return 'Cuidado del Bebé';
      default: return categoria;
    }
  }

  String _getNombreNivel(String nivel) {
    switch (nivel) {
      case 'BASICO': return 'Básico';
      case 'INTERMEDIO': return 'Intermedio';
      case 'AVANZADO': return 'Avanzado';
      default: return nivel;
    }
  }
}

