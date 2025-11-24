import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/alerta_service.dart';
import '../../data/services/alerta_service_simple.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/contenido_service.dart';
import '../../data/services/control_service.dart';
import '../../data/services/dashboard_service.dart';
import '../../data/services/gestante_service.dart';
import '../../data/services/permission_service.dart';
import '../../data/services/reporte_service.dart';
import '../../core/network/api_service.dart';
import '../../core/network/simple_network_info.dart';
import '../../core/network/websocket_service.dart';
import '../../data/services/cache_service.dart';
import '../../data/repositories/gestante_repository_impl.dart';
import '../../data/repositories/sos_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'package:madres_digitales_flutter_new/features/contenido/data/repositories/contenido_repository_impl.dart';
import 'package:madres_digitales_flutter_new/features/contenido/data/datasources/contenido_remote_datasource.dart';
import 'package:madres_digitales_flutter_new/features/contenido/data/datasources/contenido_local_datasource.dart';
import 'package:madres_digitales_flutter_new/features/gestante/data/datasources/gestante_remote_datasource.dart';
import 'package:madres_digitales_flutter_new/features/gestante/data/datasources/gestante_local_datasource.dart';
import 'package:madres_digitales_flutter_new/features/gestante/data/datasources/gestante_remote_datasource_impl.dart';
import 'package:madres_digitales_flutter_new/features/gestante/data/datasources/gestante_local_datasource_impl.dart';
import 'package:madres_digitales_flutter_new/features/alertas/data/repositories/alerta_repository_impl.dart';
import '../../domain/repositories/report_repository.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../core/services/pdf_generator_service.dart';
import '../../core/services/excel_generator_service.dart';
import '../../core/services/csv_generator_service.dart';
import '../../core/services/txt_generator_service.dart';
import '../../domain/repositories/gestante_repository.dart';
import '../../domain/repositories/sos_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/repositories/contenido_repository.dart';
import 'package:madres_digitales_flutter_new/features/alertas/domain/repositories/alerta_repository.dart';
//import '../cache/cache_providers.dart'; // Comentado temporalmente hasta que exista
import '../../data/services/usuario_service.dart';
import '../../data/services/municipio_service.dart';
import '../../data/services/ips_service.dart';
import '../../data/services/medico_service.dart';
import 'package:madres_digitales_flutter_new/data/services/simple_data_service.dart';
import 'package:madres_digitales_flutter_new/data/services/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/services/contenido_progreso_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/offline_service.dart';
import '../../data/services/sync_service.dart';
import '../../data/services/offline_error_service.dart';
import '../../data/services/notification_service.dart';


// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Alert Service Provider
final alertaServiceProvider = Provider<AlertaService>((ref) {
  final api = ref.read(apiServiceProvider);
  final cache = ref.read(cacheServiceProvider);
  final ws = ref.read(webSocketServiceProvider);
  return AlertaService(api, cache, ws);
});

// Simple Alert Service Provider (following GestanteService pattern)
final alertaServiceSimpleProvider = Provider<AlertaServiceSimple>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AlertaServiceSimple(apiService);
});

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Contenido Service Provider
final contenidoServiceProvider = Provider<ContenidoService>((ref) {
  final api = ref.read(apiServiceProvider);
  final repo = ref.read(contenidoRepositoryProvider);
  return ContenidoService(repo, api);
});

// Control Service Provider
final controlServiceProvider = Provider<ControlService>((ref) {
  final api = ref.read(apiServiceProvider);
  final sync = ref.read(syncServiceProvider);
  final ws = ref.read(webSocketServiceProvider);
  return ControlService(apiService: api, syncService: sync, webSocketService: ws);
});

// Dashboard Service Provider
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return DashboardService(apiService);
});

// Gestante Service Provider
final gestanteServiceProvider = Provider<GestanteService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return GestanteService(apiService);
});

// Gestante Data Sources
final gestanteRemoteDataSourceProvider = Provider<GestanteRemoteDataSource>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return GestanteRemoteDataSourceImpl(apiService: apiService);
});

final gestanteLocalDataSourceProvider = Provider<GestanteLocalDataSource>((ref) {
  return GestanteLocalDataSourceImpl();
});

// Permission Service Provider
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

// Reporte Service Provider
final reporteServiceProvider = Provider<ReporteService>((ref) {
  return ReporteService();
});

final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());

final webSocketServiceProvider = Provider<WebSocketService>((ref) => WebSocketService());

// Contenido Sync Service Provider (placeholder)
final contenidoSyncServiceProvider = FutureProvider<DummySyncService>((ref) async {
  return DummySyncService();
});

final gestanteRepositoryProvider = Provider<GestanteRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  final cacheService = ref.read(cacheServiceProvider);
  final webSocketService = ref.read(webSocketServiceProvider);
  return GestanteRepositoryImpl(
    apiService,
    cacheService,
    webSocketService,
  );
});

final sosRepositoryProvider = Provider<SOSRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  final ws = ref.read(webSocketServiceProvider);
  final cache = ref.read(cacheServiceProvider);
  return SOSRepositoryImpl(api, ws, cache);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  return AuthRepositoryImpl(api);
});

final contenidoRepositoryProvider = Provider<ContenidoRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  final remote = ContenidoRemoteDataSourceImpl(apiService: api);
  final local = ContenidoLocalDataSourceImpl();
  final network = NetworkInfoImpl();
  return ContenidoRepositoryImpl(
    remoteDataSource: remote,
    localDataSource: local,
    networkInfo: network,
  );
});

final alertaRepositoryProvider = Provider<AlertaRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  final cache = ref.read(cacheServiceProvider);
  final sync = ref.read(syncServiceProvider);
  final ws = ref.read(webSocketServiceProvider);
  return AlertaRepositoryImpl(apiService: api, cacheService: cache, syncService: sync, webSocketService: ws);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final pdf = PDFGeneratorService();
  final excel = ExcelGeneratorService();
  final csv = CSVGeneratorService();
  final txt = TXTGeneratorService();
  return ReportRepositoryImpl(
    pdfGeneratorService: pdf,
    excelGeneratorService: excel,
    csvGeneratorService: csv,
    txtGeneratorService: txt,
  );
});

final usuarioServiceProvider = Provider<UsuarioService>((ref) {
  final api = ref.read(apiServiceProvider);
  return UsuarioService(apiService: api);
});

final municipioServiceProvider = Provider<MunicipioService>((ref) {
  final api = ref.read(apiServiceProvider);
  return MunicipioService(api);
});

final ipsServiceProvider = Provider<IPSService>((ref) {
  final api = ref.read(apiServiceProvider);
  final cache = ref.read(cacheServiceProvider);
  return IPSService(apiService: api, cacheService: cache);
});

final medicoServiceProvider = Provider<MedicoService>((ref) {
  final api = ref.read(apiServiceProvider);
  final cache = ref.read(cacheServiceProvider);
  final sync = ref.read(syncServiceProvider);
  return MedicoService(apiService: api, cacheService: cache, syncService: sync);
});

final simpleDataServiceProvider = Provider<SimpleDataService>((ref) {
  final api = ref.read(apiServiceProvider);
  return SimpleDataService(api);
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) => ConnectivityService());

final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  return ref.read(connectivityServiceProvider).connectivityStream;
});
final contenidoProgresoServiceProvider = Provider<ContenidoProgresoService>((ref) {
  final api = ref.read(apiServiceProvider);
  return ContenidoProgresoService(api);
});
final offlineServiceProvider = FutureProvider<OfflineService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return OfflineService(prefs: prefs);
});

// Sync Service Provider
final syncServiceProvider = Provider<SyncService>((ref) {
  final api = ref.read(apiServiceProvider);
  return SyncService(apiService: api, connectivity: Connectivity());
});

final offlineErrorServiceProvider = Provider<OfflineErrorService>((ref) {
  final api = ref.read(apiServiceProvider);
  return OfflineErrorService(apiService: api);
});
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
class DummySyncService {
  DummySyncService();
  final Stream<double> syncProgress = const Stream<double>.empty();
  bool get isSyncing => false;
  void syncContenidos() {}
}
