import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/integrated_admin_provider.dart';
import '../providers/service_providers.dart';
import '../models/integrated_models.dart';
import '../features/municipios/presentation/screens/municipios_admin_screen.dart';
import 'contenido_crud_screen.dart';

class SuperAdminScreen extends ConsumerStatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  ConsumerState<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends ConsumerState<SuperAdminScreen> {
  String _searchQuery = '';
  String _filtroEstado = 'todos'; // todos, activos, inactivos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Administrador'),
        backgroundColor: Colors.purple[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.video_library),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContenidoCrudScreen(),
                ),
              );
            },
            tooltip: 'Gestión de Contenidos',
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.pushNamed(context, '/usuarios');
            },
            tooltip: 'Gestión de Usuarios',
          ),
          IconButton(
            icon: const Icon(Icons.location_city),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MunicipiosAdminScreen(),
                ),
              );
            },
            tooltip: 'Gestión de Municipios',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(municipiosIntegradosProvider);
              ref.invalidate(resumenIntegradoProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildResumenEstadisticas(),
          _buildAccesoRapidoModulos(),
          _buildFiltros(),
          Expanded(child: _buildMunicipiosList()),
        ],
      ),
    );
  }

  Widget _buildResumenEstadisticas() {
    final resumenAsync = ref.watch(resumenIntegradoProvider);
    
    return resumenAsync.when(
      data: (resumen) => Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[100],
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Municipios',
                '${resumen.municipiosActivos}/${resumen.totalMunicipios}',
                Colors.blue,
                Icons.location_city,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'IPS',
                '${resumen.ipsActivas}/${resumen.totalIPS}',
                Colors.green,
                Icons.local_hospital,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Médicos',
                '${resumen.medicosActivos}/${resumen.totalMedicos}',
                Colors.orange,
                Icons.medical_services,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Gestantes',
                '${resumen.gestantesActivas}',
                Colors.purple,
                Icons.pregnant_woman,
              ),
            ),
          ],
        ),
      ),
      loading: () => Container(
        height: 100,
        color: Colors.grey[100],
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        height: 100,
        color: Colors.red[50],
        child: Center(
          child: Text(
            'Error cargando estadísticas: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccesoRapidoModulos() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Módulos de Administración',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MunicipiosAdminScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.location_city),
                      label: const Text('Administrar Municipios'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
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

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar municipio',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _filtroEstado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todos')),
                DropdownMenuItem(value: 'activos', child: Text('Activos')),
                DropdownMenuItem(value: 'inactivos', child: Text('Inactivos')),
              ],
              onChanged: (value) {
                setState(() {
                  _filtroEstado = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMunicipiosList() {
    final municipiosAsync = ref.watch(municipiosIntegradosProvider);
    
    return municipiosAsync.when(
      data: (municipios) {
        final municipiosFiltrados = _filtrarMunicipios(municipios);
        
        if (municipiosFiltrados.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_city,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No se encontraron municipios',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(municipiosIntegradosProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: municipiosFiltrados.length,
            itemBuilder: (context, index) {
              final municipio = municipiosFiltrados[index];
              return _buildMunicipioCard(municipio);
            },
          ),
        );
      },
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cargando municipios...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar municipios: $error',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(municipiosIntegradosProvider);
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  List<MunicipioIntegrado> _filtrarMunicipios(List<MunicipioIntegrado> municipios) {
    var filtered = municipios;

    // Filtrar por estado
    if (_filtroEstado == 'activos') {
      filtered = filtered.where((m) => m.activo).toList();
    } else if (_filtroEstado == 'inactivos') {
      filtered = filtered.where((m) => !m.activo).toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((m) => 
        m.nombre.toLowerCase().contains(query) ||
        m.codigo.toLowerCase().contains(query)
      ).toList();
    }

    return filtered;
  }

  Widget _buildMunicipioCard(MunicipioIntegrado municipio) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        municipio.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Código: ${municipio.codigo}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Departamento: ${municipio.departamento}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: municipio.estadoColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        municipio.estadoTexto,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Switch(
                      value: municipio.activo,
                      activeThumbColor: Colors.green,
                      onChanged: (value) {
                        _toggleMunicipioEstado(municipio.id, value);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Estadísticas integradas
            Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    'Gestantes',
                    '${municipio.totalGestantes}',
                    Colors.purple,
                    Icons.pregnant_woman,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    'IPS',
                    '${municipio.totalIPS}',
                    Colors.green,
                    Icons.local_hospital,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    'Médicos',
                    '${municipio.totalMedicos}',
                    Colors.orange,
                    Icons.medical_services,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    'Alertas',
                    '${municipio.alertasActivas}',
                    municipio.alertasActivas > 0 ? Colors.red : Colors.grey,
                    Icons.warning,
                  ),
                ),
              ],
            ),
            if (municipio.gestantesRiesgoAlto > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.red[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${municipio.gestantesRiesgoAlto} gestantes de alto riesgo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Cobertura: ${municipio.nivelCobertura}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  'Registrado: ${_formatDate(municipio.created_at.toIso8601String())}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMunicipioEstado(String municipioId, bool nuevoEstado) async {
    try {
      final service = await ref.read(integratedAdminServiceProvider.future);
      await service.toggleMunicipioEstado(municipioId, nuevoEstado);
      
      // Refrescar los datos
      ref.invalidate(municipiosIntegradosProvider);
      ref.invalidate(resumenIntegradoProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nuevoEstado 
                ? 'Municipio activado exitosamente' 
                : 'Municipio desactivado exitosamente'
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar municipio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}