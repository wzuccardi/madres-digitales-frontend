import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../shared/theme/app_theme.dart';

/// Widget de formulario simplificado para crear/editar contenidos
class ContenidoFormSimpleWidget extends StatefulWidget {
  final String? contenidoId;
  final String? tituloInicial;
  final String? descripcionInicial;
  final String? tipoInicial;
  final String? categoriaInicial;
  final String? nivelInicial;
  final String? urlInicial;
  final int? duracionInicial;
  final Function(Map<String, dynamic>) onSubmit;

  const ContenidoFormSimpleWidget({
    super.key,
    this.contenidoId,
    this.tituloInicial,
    this.descripcionInicial,
    this.tipoInicial,
    this.categoriaInicial,
    this.nivelInicial,
    this.urlInicial,
    this.duracionInicial,
    required this.onSubmit,
  });

  @override
  State<ContenidoFormSimpleWidget> createState() => _ContenidoFormSimpleWidgetState();
}

class _ContenidoFormSimpleWidgetState extends State<ContenidoFormSimpleWidget> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _urlController = TextEditingController();
  final _duracionController = TextEditingController();

  String _tipoSeleccionado = 'VIDEO';
  String _categoriaSeleccionada = 'EMBARAZO';
  String _nivelSeleccionado = 'BASICO';
  bool _usarUrl = true;
  PlatformFile? _archivoSeleccionado;

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
    _tituloController.text = widget.tituloInicial ?? '';
    _descripcionController.text = widget.descripcionInicial ?? '';
    _urlController.text = widget.urlInicial ?? '';
    _duracionController.text = widget.duracionInicial?.toString() ?? '';
    _tipoSeleccionado = widget.tipoInicial ?? 'VIDEO';
    _categoriaSeleccionada = widget.categoriaInicial ?? 'EMBARAZO';
    _nivelSeleccionado = widget.nivelInicial ?? 'BASICO';
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
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _archivoSeleccionado = result.files.first;
          _usarUrl = false;
          _urlController.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Archivo seleccionado: ${_archivoSeleccionado!.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al seleccionar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _limpiarArchivo() {
    setState(() {
      _archivoSeleccionado = null;
      _usarUrl = true;
    });
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'titulo': _tituloController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'tipo': _tipoSeleccionado,
      'categoria': _categoriaSeleccionada,
      'nivel': _nivelSeleccionado,
      'urlContenido': _usarUrl && _urlController.text.trim().isNotEmpty
          ? _urlController.text.trim()
          : null,
      'archivo': _archivoSeleccionado,
      'duracion': _duracionController.text.trim().isNotEmpty
          ? int.tryParse(_duracionController.text.trim())
          : null,
    };

    widget.onSubmit(data);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Título
          TextFormField(
            controller: _tituloController,
            decoration: const InputDecoration(
              labelText: 'Título *',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
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
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La descripción es requerida';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Tipo
          DropdownButtonFormField<String>(
            initialValue: _tipoSeleccionado,
            decoration: const InputDecoration(
              labelText: 'Tipo *',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: _tipos.map((tipo) {
              return DropdownMenuItem(value: tipo, child: Text(tipo));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _tipoSeleccionado = value);
              }
            },
          ),

          const SizedBox(height: 16),

          // Categoría
          DropdownButtonFormField<String>(
            initialValue: _categoriaSeleccionada,
            decoration: const InputDecoration(
              labelText: 'Categoría *',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: _categorias.map((categoria) {
              return DropdownMenuItem(value: categoria, child: Text(categoria));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _categoriaSeleccionada = value);
              }
            },
          ),

          const SizedBox(height: 16),

          // Nivel
          DropdownButtonFormField<String>(
            initialValue: _nivelSeleccionado,
            decoration: const InputDecoration(
              labelText: 'Nivel',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: _niveles.map((nivel) {
              return DropdownMenuItem(value: nivel, child: Text(nivel));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _nivelSeleccionado = value);
              }
            },
          ),

          const SizedBox(height: 16),

          // Duración (opcional)
          TextFormField(
            controller: _duracionController,
            decoration: const InputDecoration(
              labelText: 'Duración (minutos)',
              hintText: '5',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 24),

          // Sección de archivo/URL
          _buildArchivoSection(),

          const SizedBox(height: 32),

          // Botón guardar
          ElevatedButton(
            onPressed: _guardar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: Text(widget.contenidoId == null ? 'Crear Contenido' : 'Actualizar Contenido'),
          ),
        ],
      ),
    );
  }

  Widget _buildArchivoSection() {
    return Container(
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Tabs
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
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                  label: Text(_archivoSeleccionado == null ? 'Seleccionar Archivo' : 'Cambiar Archivo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Formatos: PDF, MP4, MP3, JPG, PNG, WEBP',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

