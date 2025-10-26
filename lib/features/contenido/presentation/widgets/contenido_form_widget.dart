import 'package:flutter/material.dart';
import 'dart:io';

import '../../domain/entities/contenido.dart';
import 'file_picker_widget.dart';

class ContenidoFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController tituloController;
  final TextEditingController descripcionController;
  final TextEditingController urlController;
  final TextEditingController thumbnailUrlController;
  final TextEditingController duracionController;
  final TextEditingController etiquetasController;
  final TipoContenido tipoSeleccionado;
  final CategoriaContenido categoriaSeleccionada;
  final NivelDificultad nivelSeleccionado;
  final int semanaInicioSeleccionada;
  final int semanaFinSeleccionada;
  final File? thumbnailFile;
  final Function(TipoContenido) onTipoChanged;
  final Function(CategoriaContenido) onCategoriaChanged;
  final Function(NivelDificultad) onNivelChanged;
  final Function(int) onSemanaInicioChanged;
  final Function(int) onSemanaFinChanged;
  final VoidCallback onSeleccionarImagen;

  const ContenidoFormWidget({
    super.key,
    required this.formKey,
    required this.tituloController,
    required this.descripcionController,
    required this.urlController,
    required this.thumbnailUrlController,
    required this.duracionController,
    required this.etiquetasController,
    required this.tipoSeleccionado,
    required this.categoriaSeleccionada,
    required this.nivelSeleccionado,
    required this.semanaInicioSeleccionada,
    required this.semanaFinSeleccionada,
    this.thumbnailFile,
    required this.onTipoChanged,
    required this.onCategoriaChanged,
    required this.onNivelChanged,
    required this.onSemanaInicioChanged,
    required this.onSemanaFinChanged,
    required this.onSeleccionarImagen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        TextFormField(
          controller: tituloController,
          decoration: const InputDecoration(
            labelText: 'Título',
            hintText: 'Ingrese el título del contenido',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingrese un título';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Descripción
        TextFormField(
          controller: descripcionController,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            hintText: 'Ingrese una descripción del contenido',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingrese una descripción';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Tipo de contenido
        DropdownButtonFormField<TipoContenido>(
          initialValue: tipoSeleccionado,
          decoration: const InputDecoration(
            labelText: 'Tipo de contenido',
            border: OutlineInputBorder(),
          ),
          items: TipoContenido.values.map((TipoContenido tipo) {
            return DropdownMenuItem<TipoContenido>(
              value: tipo,
              child: Text(_getTipoLabel(tipo)),
            );
          }).toList(),
          onChanged: (TipoContenido? value) {
            if (value != null) {
              onTipoChanged(value);
            }
          },
        ),
        
        const SizedBox(height: 16),
        
        // Categoría
        DropdownButtonFormField<CategoriaContenido>(
          initialValue: categoriaSeleccionada,
          decoration: const InputDecoration(
            labelText: 'Categoría',
            border: OutlineInputBorder(),
          ),
          items: CategoriaContenido.values.map((CategoriaContenido categoria) {
            return DropdownMenuItem<CategoriaContenido>(
              value: categoria,
              child: Text(_getCategoriaLabel(categoria)),
            );
          }).toList(),
          onChanged: (CategoriaContenido? value) {
            if (value != null) {
              onCategoriaChanged(value);
            }
          },
        ),
        
        const SizedBox(height: 16),
        
        // Nivel de dificultad
        DropdownButtonFormField<NivelDificultad>(
          initialValue: nivelSeleccionado,
          decoration: const InputDecoration(
            labelText: 'Nivel de dificultad',
            border: OutlineInputBorder(),
          ),
          items: NivelDificultad.values.map((NivelDificultad nivel) {
            return DropdownMenuItem<NivelDificultad>(
              value: nivel,
              child: Text(_getNivelLabel(nivel)),
            );
          }).toList(),
          onChanged: (NivelDificultad? value) {
            if (value != null) {
              onNivelChanged(value);
            }
          },
        ),
        
        const SizedBox(height: 16),
        
        // Selector de archivo según el tipo de contenido
        _buildFileSelector(),
        
        const SizedBox(height: 16),
        
        // URL de la imagen miniatura
        TextFormField(
          controller: thumbnailUrlController,
          decoration: const InputDecoration(
            labelText: 'URL de la imagen miniatura',
            hintText: 'https://ejemplo.com/imagen.jpg',
            border: OutlineInputBorder(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Vista previa de la imagen
        _buildImagePreview(),
        
        const SizedBox(height: 16),
        
        // Botón para seleccionar imagen
        OutlinedButton.icon(
          onPressed: onSeleccionarImagen,
          icon: const Icon(Icons.photo_library),
          label: const Text('Seleccionar imagen desde galería'),
        ),
        
        const SizedBox(height: 16),
        
        // Duración (solo para video y podcast)
        if (tipoSeleccionado == TipoContenido.video || 
            tipoSeleccionado == TipoContenido.podcast)
          TextFormField(
            controller: duracionController,
            decoration: const InputDecoration(
              labelText: 'Duración (segundos)',
              hintText: '300',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingrese la duración';
              }
              if (int.tryParse(value.trim()) == null) {
                return 'Por favor ingrese un número válido';
              }
              return null;
            },
          ),
        
        const SizedBox(height: 16),
        
        // Etiquetas
        TextFormField(
          controller: etiquetasController,
          decoration: const InputDecoration(
            labelText: 'Etiquetas',
            hintText: 'nutrición, embarazo, salud (separadas por comas)',
            border: OutlineInputBorder(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Semanas de gestación
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: semanaInicioSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Semana de inicio',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(40, (index) => index + 1)
                    .map((int semana) {
                  return DropdownMenuItem<int>(
                    value: semana,
                    child: Text('Semana $semana'),
                  );
                }).toList(),
                onChanged: (int? value) {
                  if (value != null) {
                    onSemanaInicioChanged(value);
                  }
                },
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: semanaFinSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Semana de fin',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(40, (index) => index + 1)
                    .map((int semana) {
                  return DropdownMenuItem<int>(
                    value: semana,
                    child: Text('Semana $semana'),
                  );
                }).toList(),
                onChanged: (int? value) {
                  if (value != null) {
                    onSemanaFinChanged(value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFileSelector() {
    switch (tipoSeleccionado) {
      case TipoContenido.video:
        return FilePickerWidget(
          fileType: ContenidoFileType.video,
          initialUrl: urlController.text,
          onFileSelected: (url) {
            urlController.text = url;
          },
          labelText: 'Archivo de video',
          hintText: 'Seleccione o ingrese la URL del video',
          maxSizeBytes: 50 * 1024 * 1024, // 50 MB
        );
      case TipoContenido.podcast:
        return FilePickerWidget(
          fileType: ContenidoFileType.audio,
          initialUrl: urlController.text,
          onFileSelected: (url) {
            urlController.text = url;
          },
          labelText: 'Archivo de audio',
          hintText: 'Seleccione o ingrese la URL del audio',
          maxSizeBytes: 20 * 1024 * 1024, // 20 MB
        );
      case TipoContenido.infografia:
      case TipoContenido.guia:
      case TipoContenido.curso:
      case TipoContenido.webinar:
      case TipoContenido.evaluacion:
        return FilePickerWidget(
          fileType: ContenidoFileType.document,
          initialUrl: urlController.text,
          onFileSelected: (url) {
            urlController.text = url;
          },
          labelText: 'Archivo del documento',
          hintText: 'Seleccione o ingrese la URL del documento',
          maxSizeBytes: 20 * 1024 * 1024, // 20 MB
        );
      case TipoContenido.articulo:
        // Para artículos, solo mostrar campo de URL
        return TextFormField(
          controller: urlController,
          decoration: const InputDecoration(
            labelText: 'URL del artículo',
            hintText: 'https://ejemplo.com/articulo',
            border: OutlineInputBorder(),
          ),
        );
    }
  }

  Widget _buildImagePreview() {
    if (thumbnailFile != null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.file(
            thumbnailFile!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          ),
        ),
      );
    } else if (thumbnailUrlController.text.isNotEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.network(
            thumbnailUrlController.text,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Vista previa de la imagen',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTipoLabel(TipoContenido tipo) {
    switch (tipo) {
      case TipoContenido.articulo:
        return 'Artículo';
      case TipoContenido.video:
        return 'Video';
      case TipoContenido.podcast:
        return 'Podcast';
      case TipoContenido.infografia:
        return 'Infografía';
      case TipoContenido.guia:
        return 'Guía';
      case TipoContenido.curso:
        return 'Curso';
      case TipoContenido.webinar:
        return 'Webinar';
      case TipoContenido.evaluacion:
        return 'Evaluación';
    }
  }

  String _getCategoriaLabel(CategoriaContenido categoria) {
    switch (categoria) {
      case CategoriaContenido.nutricion:
        return 'Nutrición';
      case CategoriaContenido.ejercicio:
        return 'Ejercicio';
      case CategoriaContenido.saludMental:
        return 'Salud Mental';
      case CategoriaContenido.preparacionParto:
        return 'Preparación del Parto';
      case CategoriaContenido.cuidadoBebe:
        return 'Cuidado del Bebé';
      case CategoriaContenido.lactancia:
        return 'Lactancia';
      case CategoriaContenido.desarrolloInfantil:
        return 'Desarrollo Infantil';
      case CategoriaContenido.seguridad:
        return 'Seguridad';
    }
  }

  String _getNivelLabel(NivelDificultad nivel) {
    switch (nivel) {
      case NivelDificultad.basico:
        return 'Básico';
      case NivelDificultad.intermedio:
        return 'Intermedio';
      case NivelDificultad.avanzado:
        return 'Avanzado';
    }
  }
}