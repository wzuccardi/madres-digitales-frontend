import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../domain/entities/contenido.dart';
import '../blocs/contenido/contenido_event.dart';
import '../blocs/contenido/contenido_state.dart';
import '../blocs/contenido/contenido_provider.dart';
import '../widgets/contenido_form_widget.dart';
import '../../domain/usecases/create_contenido.dart';

class ContenidoFormPage extends ConsumerStatefulWidget {
  final Contenido? contenido;
  final bool isEditing;

  const ContenidoFormPage({
    super.key,
    this.contenido,
  }) : isEditing = contenido != null;

  @override
  ConsumerState<ContenidoFormPage> createState() => _ContenidoFormPageState();
}

class _ContenidoFormPageState extends ConsumerState<ContenidoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _urlController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();
  final _duracionController = TextEditingController();
  final _etiquetasController = TextEditingController();
  
  TipoContenido _tipoSeleccionado = TipoContenido.articulo;
  CategoriaContenido _categoriaSeleccionada = CategoriaContenido.nutricion;
  NivelDificultad _nivelSeleccionado = NivelDificultad.basico;
  int _semanaInicioSeleccionada = 1;
  int _semanaFinSeleccionada = 40;
  
  bool _isLoading = false;
  String? _errorMessage;
  File? _thumbnailFile;

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _urlController.dispose();
    _thumbnailUrlController.dispose();
    _duracionController.dispose();
    _etiquetasController.dispose();
    super.dispose();
  }

  void _inicializarDatos() {
    if (widget.isEditing && widget.contenido != null) {
      final contenido = widget.contenido!;
      
      _tituloController.text = contenido.titulo;
      _descripcionController.text = contenido.descripcion;
      _urlController.text = contenido.url ?? '';
      _thumbnailUrlController.text = contenido.thumbnailUrl ?? '';
      _duracionController.text = contenido.duracion?.toString() ?? '';
      _etiquetasController.text = contenido.etiquetas.join(', ');
      
      _tipoSeleccionado = contenido.tipo;
      _categoriaSeleccionada = contenido.categoria;
      _nivelSeleccionado = contenido.nivel;
      _semanaInicioSeleccionada = contenido.semanaGestacionInicio ?? 1;
      _semanaFinSeleccionada = contenido.semanaGestacionFin ?? 40;
    }
  }

  Future<void> _guardarContenido() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final etiquetas = _etiquetasController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final params = CreateContenidoParams(
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        url: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
        thumbnailUrl: _thumbnailUrlController.text.trim().isEmpty 
            ? null 
            : _thumbnailUrlController.text.trim(),
        tipo: _tipoSeleccionado,
        categoria: _categoriaSeleccionada,
        nivel: _nivelSeleccionado,
        duracion: _duracionController.text.trim().isEmpty 
            ? null 
            : int.tryParse(_duracionController.text.trim()),
        etiquetas: etiquetas,
        semanaGestacionInicio: _semanaInicioSeleccionada,
        semanaGestacionFin: _semanaFinSeleccionada,
      );

      if (widget.isEditing) {
        ref.read(contenidoBlocProvider.notifier).mapEventToState(
          UpdateContenidoEvent(
            id: widget.contenido!.id,
            params: params,
          ),
        );
      } else {
        ref.read(contenidoBlocProvider.notifier).mapEventToState(
          CreateContenidoEvent(params: params),
        );
      }

      // Esperar a que se complete la operación
      ref.listen<ContenidoState>(contenidoBlocProvider, (previous, state) {
        if (state.status == ContenidoStatus.success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isEditing
                    ? 'Contenido actualizado correctamente'
                    : 'Contenido creado correctamente',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.status == ContenidoStatus.failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.error ?? 'Error desconocido';
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _thumbnailFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Editar Contenido' : 'Nuevo Contenido',
        ),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmarEliminacion,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    ContenidoFormWidget(
                      formKey: _formKey,
                      tituloController: _tituloController,
                      descripcionController: _descripcionController,
                      urlController: _urlController,
                      thumbnailUrlController: _thumbnailUrlController,
                      duracionController: _duracionController,
                      etiquetasController: _etiquetasController,
                      tipoSeleccionado: _tipoSeleccionado,
                      categoriaSeleccionada: _categoriaSeleccionada,
                      nivelSeleccionado: _nivelSeleccionado,
                      semanaInicioSeleccionada: _semanaInicioSeleccionada,
                      semanaFinSeleccionada: _semanaFinSeleccionada,
                      thumbnailFile: _thumbnailFile,
                      onTipoChanged: (TipoContenido value) {
                        setState(() {
                          _tipoSeleccionado = value;
                        });
                      },
                      onCategoriaChanged: (CategoriaContenido value) {
                        setState(() {
                          _categoriaSeleccionada = value;
                        });
                      },
                      onNivelChanged: (NivelDificultad value) {
                        setState(() {
                          _nivelSeleccionado = value;
                        });
                      },
                      onSemanaInicioChanged: (int value) {
                        setState(() {
                          _semanaInicioSeleccionada = value;
                        });
                      },
                      onSemanaFinChanged: (int value) {
                        setState(() {
                          _semanaFinSeleccionada = value;
                        });
                      },
                      onSeleccionarImagen: _seleccionarImagen,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('CANCELAR'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _guardarContenido,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    widget.isEditing ? 'ACTUALIZAR' : 'GUARDAR',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _confirmarEliminacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Contenido'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este contenido? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(contenidoBlocProvider.notifier).mapEventToState(
                DeleteContenidoEvent(widget.contenido!.id),
              );
              
              // Esperar a que se complete la operación
              ref.listen<ContenidoState>(contenidoBlocProvider, (previous, state) {
                if (state.status == ContenidoStatus.success) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contenido eliminado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              });
            },
            child: const Text(
              'ELIMINAR',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}