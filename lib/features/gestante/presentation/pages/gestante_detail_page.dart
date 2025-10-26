import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/gestante.dart';
import '../providers/madrina_session_provider.dart';

class GestanteDetailPage extends ConsumerStatefulWidget {
  final String gestanteId;

  const GestanteDetailPage({
    super.key,
    required this.gestanteId,
  });

  @override
  ConsumerState<GestanteDetailPage> createState() => _GestanteDetailPageState();
}

class _GestanteDetailPageState extends ConsumerState<GestanteDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Gestante? _gestante;
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadGestante();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGestante() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Aquí iría la lógica para obtener la gestante por ID
      // Por ahora, usamos datos de ejemplo
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _gestante = Gestante(
          id: widget.gestanteId,
          nombres: 'María',
          apellidos: 'González',
          tipoDocumento: 'CC',
          numeroDocumento: '12345678',
          email: 'maria.gonzalez@email.com',
          telefono: '3001234567',
          fechaNacimiento: DateTime(1990, 5, 15),
          fechaUltimaMestruacion: DateTime(2024, 1, 15),
          fechaProbableParto: DateTime(2024, 10, 22),
          esAltoRiesgo: true,
          factoresRiesgo: const ['Hipertensión', 'Diabetes'],
          grupoSanguineo: 'O+',
          contactoEmergenciaNombre: 'Carlos González',
          contactoEmergenciaTelefono: '3012345678',
          direccion: 'Calle 123 #45-67',
          barrio: 'Centro',
          eps: 'SURA',
          regimen: 'Contributivo',
          fechaCreacion: DateTime.now(),
          creadaPor: 'm1',
          madrinasAsignadas: const ['m1', 'm2'],
          activa: true,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar gestante: $e';
      });
    }
  }

  Future<void> _refreshGestante() async {
    await _loadGestante();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadPermissions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final tienePermisoEditar = snapshot.data?['editar'] ?? false;
        final tienePermisoEliminar = snapshot.data?['eliminar'] ?? false;
        final tienePermisoCrearControl = snapshot.data?['crearControl'] ?? false;
        final tienePermisoActivarSos = snapshot.data?['activar_sos'] ?? false;

        if (_isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_errorMessage != null || _gestante == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage ?? 'No se pudo cargar la información',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshGestante,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
      appBar: AppBar(
        title: Text(_gestante!.nombreCompleto),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          // Botón de SOS (si tiene permiso)
          if (tienePermisoActivarSos)
            IconButton(
              icon: const Icon(Icons.sos),
              onPressed: _activarSOS,
              tooltip: 'Activar SOS',
            ),
          
          // Botón de editar (si tiene permiso)
          if (tienePermisoEditar)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editarGestante,
              tooltip: 'Editar',
            ),
          
          // Botón de eliminar (si tiene permiso)
          if (tienePermisoEliminar)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'eliminar') {
                  _confirmarEliminacion();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshGestante,
        child: Column(
          children: [
            // Información principal
            _buildGestanteHeader(),
            
            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: Colors.pink,
              indicatorColor: Colors.pink,
              tabs: const [
                Tab(text: 'Información'),
                Tab(text: 'Controles'),
                Tab(text: 'Asignaciones'),
                Tab(text: 'Historial'),
              ],
            ),
            
            // Contenido de las tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInformacionTab(),
                  _buildControlesTab(tienePermisoCrearControl),
                  _buildAsignacionesTab(),
                  _buildHistorialTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: tienePermisoCrearControl
          ? FloatingActionButton(
              onPressed: _crearControl,
              backgroundColor: Colors.pink,
              child: const Icon(Icons.add),
            )
          : null,
        );
      },
    );
  }

  Future<Map<String, bool>> _loadPermissions() async {
    // Usamos el session provider que tiene el método tienePermiso
    final sessionNotifier = ref.read(madrinaSessionProvider.notifier);
    
    return {
      'editar': await sessionNotifier.tienePermiso(widget.gestanteId, 'editar'),
      'eliminar': await sessionNotifier.tienePermiso(widget.gestanteId, 'eliminar'),
      'crearControl': await sessionNotifier.tienePermiso(widget.gestanteId, 'crearControl'),
      'activar_sos': await sessionNotifier.tienePermiso(widget.gestanteId, 'activar_sos'),
    };
  }

  Widget _buildGestanteHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.pink.withValues(alpha: 0.1),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.pink,
            child: Text(
              _gestante!.nombres.substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _gestante!.nombreCompleto,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_gestante!.tipoDocumento}: ${_gestante!.numeroDocumento}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Edad: ${_gestante!.edad} años',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Semanas: ${_gestante!.semanasGestacion}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (_gestante!.esAltoRiesgo)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'ALTO RIESGO',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformacionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInformacionSection(
            'Información de Contacto',
            [
              _buildInfoRow('Teléfono', _gestante!.telefono),
              _buildInfoRow('Email', _gestante!.email ?? 'No registrado'),
              _buildInfoRow('Dirección', _gestante!.direccion),
              if (_gestante!.barrio != null)
                _buildInfoRow('Barrio', _gestante!.barrio!),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildInformacionSection(
            'Información Médica',
            [
              _buildInfoRow('Grupo Sanguíneo', _gestante!.grupoSanguineo),
              _buildInfoRow(
                'Última Menstruación',
                _gestante!.fechaUltimaMestruacion != null
                    ? '${_gestante!.fechaUltimaMestruacion!.day}/${_gestante!.fechaUltimaMestruacion!.month}/${_gestante!.fechaUltimaMestruacion!.year}'
                    : 'No registrada',
              ),
              _buildInfoRow(
                'Fecha Probable de Parto',
                _gestante!.fechaProbableParto != null
                    ? '${_gestante!.fechaProbableParto!.day}/${_gestante!.fechaProbableParto!.month}/${_gestante!.fechaProbableParto!.year}'
                    : 'No calculada',
              ),
              if (_gestante!.factoresRiesgo.isNotEmpty)
                _buildInfoRow(
                  'Factores de Riesgo',
                  _gestante!.factoresRiesgo.join(', '),
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildInformacionSection(
            'Información de Seguro',
            [
              _buildInfoRow('EPS', _gestante!.eps),
              _buildInfoRow('Régimen', _gestante!.regimen),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildInformacionSection(
            'Contacto de Emergencia',
            [
              _buildInfoRow(
                'Nombre',
                _gestante!.contactoEmergenciaNombre ?? 'No registrado',
              ),
              _buildInfoRow(
                'Teléfono',
                _gestante!.contactoEmergenciaTelefono ?? 'No registrado',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInformacionSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildControlesTab(bool tienePermisoCrearControl) {
    return Column(
      children: [
        if (tienePermisoCrearControl)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.withValues(alpha: 0.1),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Puedes crear nuevos controles para esta gestante usando el botón +',
                  ),
                ),
              ],
            ),
          ),
        
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_services,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay controles registrados',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los controles aparecerán aquí una vez sean creados',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAsignacionesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Madrinas Asignadas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          // Aquí iría la lista de madrinas asignadas
          // Por ahora, mostramos un mensaje
          Text(
            'Esta gestante está asignada a ${_gestante!.madrinasAsignadas.length} madrina(s)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Historial de Actividad',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay actividad registrada',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _activarSOS() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activar SOS'),
        content: const Text(
          '¿Estás seguro de que quieres activar la alarma SOS para esta gestante?\n\n'
          'Se notificará a todas las madrinas asignadas y se activará una alarma sonora.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí iría la lógica para activar el SOS
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('SOS activado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Activar'),
          ),
        ],
      ),
    );
  }

  void _editarGestante() {
    // Aquí iría la lógica para editar la gestante
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de edición no implementada'),
      ),
    );
  }

  void _confirmarEliminacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Gestante'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar a esta gestante?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí iría la lógica para eliminar la gestante
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gestante eliminada'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _crearControl() {
    // Aquí iría la lógica para crear un control
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de crear control no implementada'),
      ),
    );
  }
}