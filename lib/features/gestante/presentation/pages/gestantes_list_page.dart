import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gestante_detail_page.dart';
import 'create_gestante_page.dart';
import '../../domain/entities/gestante.dart';

class GestantesListPage extends ConsumerStatefulWidget {
  const GestantesListPage({super.key});
  
  @override
  ConsumerState<GestantesListPage> createState() => _GestantesListPageState();
}

class _GestantesListPageState extends ConsumerState<GestantesListPage> {
  List<Gestante> gestantes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchGestantes();
  }

  Future<void> _fetchGestantes() async {
    try {
      // Simular obtención de datos - en una implementación real se usaría el gestanteProvider
      await Future.delayed(const Duration(seconds: 1));
      
      // Datos de ejemplo - en una implementación real se obtendrían del provider
      setState(() {
        gestantes = [
          // Ejemplo de datos - reemplazar con datos reales del provider
          Gestante(
            id: '1',
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
          ),
        ];
        isLoading = false;
      });
      print('🤰 Flutter: Successfully loaded ${gestantes.length} gestantes');
    } catch (e) {
      print('❌ Flutter: Error loading gestantes: $e');
      setState(() {
        errorMessage = 'Error al cargar gestantes: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestantes'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateGestantePage(),
                ),
              );
            },
            tooltip: 'Agregar Gestante',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchGestantes,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchGestantes,
                  child: gestantes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pregnant_woman,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay gestantes registradas',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Agrega una nueva gestante usando el botón +',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: gestantes.length,
                          itemBuilder: (context, index) {
                            final gestante = gestantes[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              elevation: 2,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.pink,
                                  child: Text(
                                    gestante.nombres.substring(0, 1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  gestante.nombreCompleto,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${gestante.tipoDocumento}: ${gestante.numeroDocumento}'),
                                    const SizedBox(height: 4),
                                    Text('EPS: ${gestante.eps}'),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Edad: ${gestante.edad} años | Semanas: ${gestante.semanasGestacion ?? 'N/A'}',
                                    ),
                                  ],
                                ),
                                trailing: gestante.esAltoRiesgo
                                    ? const Icon(Icons.warning, color: Colors.red)
                                    : const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GestanteDetailPage(gestanteId: gestante.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateGestantePage(),
            ),
          );
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }
}