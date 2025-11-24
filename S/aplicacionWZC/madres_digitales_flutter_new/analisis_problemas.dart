// ignore_for_file: prefer_single_quotes
import 'dart:io';
// Script para analizar y categorizar los problemas del proyecto Flutter
void main() {
  // Lista completa de problemas analizada
  final List<Map<String, dynamic>> problemas = [
    // Importaciones no utilizadas (35 problemas)
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'consolidate_services.dart:2:8', 'descripcion': "Unused import: 'dart:convert'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'fix_imports.dart:2:8', 'descripcion': "Unused import: 'dart:convert'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\app.dart:3:8', 'descripcion': "Unused import: 'package:go_router/go_router.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\core\\network\\api_service.dart:10:8', 'descripcion': "Unused import: 'package:madres_digitales_flutter_new/core/network/api_service.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\core\\network\\websocket_service.dart:2:8', 'descripcion': "Unused import: 'dart:convert'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\core\\network\\websocket_service.dart:3:8', 'descripcion': "Unused import: 'package:madres_digitales_flutter_new/data/services/web_socket_service.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\core\\providers\\service_providers.dart:4:8', 'descripcion': "Unused import: 'cache_provider.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\core\\theme\\app_theme.dart:2:8', 'descripcion': "Unused import: 'package:madres_digitales_flutter_new/core/theme/app_theme.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\core\\usecase.dart:1:8', 'descripcion': "Unused import: 'package:dartz/dartz.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\core\\utils\\file_picker_helper.dart:3:8', 'descripcion': "Duplicate import"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\core\\utils\\logger.dart:1:8', 'descripcion': "Unused import: 'package:madres_digitales_flutter_new/core/utils/logger.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\data\\datasources\\local\\gestante_local_datasource.dart:2:8', 'descripcion': "Unused import: 'package:path/path.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\data\\datasources\\local\\gestante_local_datasource.dart:5:8', 'descripcion': "Unused import: '../../../domain/entities/gestante.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\data\\datasources\\remote\\api_service.dart:9:8', 'descripcion': "Unused import: 'package:madres_digitales_flutter_new/core/network/api_service.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\cache_service.dart:2:8', 'descripcion': "Unused import: 'package:madres_digitales_flutter_new/data/services/cache_service.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\local_storage_service.dart:2:8', 'descripcion': "Unused import: 'package:madres_digitales_flutter_new/data/services/local_storage_service.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\medico_service.dart:4:8', 'descripcion': "Duplicate import"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\permission_service.dart:2:8', 'descripcion': "Unused import: 'package:madres_digitales_flutter_new/data/services/permission_service.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\usuario_service.dart:6:8', 'descripcion': "Unused import: 'package:madres_digitales_flutter_new/domain/entities/gestante.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\web_socket_service.dart:2:8', 'descripcion': "Unused import: 'package:madres_digitales_flutter_new/data/services/web_socket_service.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\domain\\entities\\gestante.dart:2:8', 'descripcion': "Unused import: 'package:madres_digitales_flutter_new/domain/entities/gestante.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\domain\\entities\\user.dart:2:8', 'descripcion': "Unused import: 'package:madres_digitales_flutter_new/domain/entities/user.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\domain\\repositories\\auth_repository.dart:2:8', 'descripcion': "Duplicate import"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\domain\\repositories\\gestante_repository.dart:3:8', 'descripcion': "Unused import: '../../../../core/usecases/usecase.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\domain\\repositories\\gestante_repository.dart:4:8', 'descripcion': "Unused import: '../../../../core/errors/app_error.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\domain\\repositories\\user_repository.dart:2:8', 'descripcion': "Duplicate import"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\domain\\usecases\\gestante\\get_gestantes_usecase.dart:4:8', 'descripcion': "Unused import: '../../../../core/errors/failures.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\domain\\usecases\\gestante\\get_gestantes_usecase.dart:6:8', 'descripcion': "Duplicate import"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\features\\contenido\\presentation\\widgets\\contenido_form_widget.dart:1:8', 'descripcion': "Unused import: 'package:file_picker/file_picker.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\features\\gestante\\presentation\\providers\\permission_service_provider.dart:4:8', 'descripcion': "Duplicate import"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\main.dart:3:8', 'descripcion': "Unused import: 'package:go_router/go_router.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\main.dart:15:8', 'descripcion': "Duplicate import"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\providers\\sos_provider.dart:2:8', 'descripcion': "Unused import: 'package:flutter/material.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\providers\\sos_provider.dart:7:8', 'descripcion': "Unused import: '../../domain/repositories/sos_repository.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\providers\\sos_provider.dart:11:8', 'descripcion': "Unused import: '../../../../core/errors/app_error.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\shared\\theme\\app_theme.dart:2:8', 'descripcion': "Unused import: 'package:madres_digitales_flutter_new/core/theme/app_theme.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'migrate_cache_service.dart:2:8', 'descripcion': "Unused import: 'dart:convert'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'migrate_service_robust.dart:2:8', 'descripcion': "Unused import: 'dart:convert'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'migrate_storage_service.dart:2:8', 'descripcion': "Unused import: 'dart:convert'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'update_cache_imports.dart:2:8', 'descripcion': "Unused import: 'dart:convert'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'update_imports_fixed.dart:3:8', 'descripcion': "Unused import: 'package:path/path.dart'"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\settings\\sync_conflicts_screen.dart:5:8', 'descripcion': "Duplicate import"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\contenido_download_service.dart:4:8', 'descripcion': "Duplicate import"},
    {'tipo': 'unused_import', 'gravedad': 'warning', 'archivo': 'lib\\data\\models\\gestante_model.dart:3:8', 'descripcion': "Duplicate import"},
    
    // Variables locales no utilizadas (35 problemas)
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'fix_uris.dart:48:12', 'descripcion': "The value of local variable 'hasChanges' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'fix_uris.dart:93:9', 'descripcion': "The value of local variable 'pathParts' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'fix_uris.dart:96:9', 'descripcion': "The value of local variable 'depth' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\core\\network\\api_service.dart:63:15', 'descripcion': "The value of local variable 'code' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\data\\datasources\\local\\gestante_local_datasource.dart:222:40', 'descripcion': "The value of local variable 'maps' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\permission_repository_impl.dart:110:15', 'descripcion': "The value of local variable 'updatedPermission' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\permission_cache_service.dart:235:11', 'descripcion': "The value of local variable 'removedCount' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\debug\\diagnostico_contenido.dart:43:15', 'descripcion': "The value of local variable 'contenido' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\domain\\usecases\\gestante\\update_gestante_usecase.dart:47:13', 'descripcion': "The value of local variable 'updatedGestante' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\features\\contenido\\data\\datasources\\contenido_remote_datasource.dart:289:12', 'descripcion': "The value of local variable 'queryParamsStr' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\main.dart:73:9', 'descripcion': "The value of local variable 'secureStorage' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\main.dart:76:9', 'descripcion': "The value of local variable 'apiService' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\main.dart:91:11', 'descripcion': "The value of local variable 'authState' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\admin\\usuario_form_screen.dart:152:15', 'descripcion': "The value of local variable 'response' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\admin\\usuario_form_screen.dart:163:15', 'descripcion': "The value of local variable 'response' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\alertas\\alertas_screen.dart:445:11', 'descripcion': "The value of local variable 'isInfo' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\contenido\\contenido_import_export_screen.dart:298:13', 'descripcion': "The value of local variable 'jsonString' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\contenido\\contenido_screen.dart:327:11', 'descripcion': "The value of local variable 'isAdmin' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\home\\sos_mejorado_screen.dart:209:13', 'descripcion': "The value of local variable 'position' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\providers\\sos_provider.dart:112:11', 'descripcion': "The value of local variable 'alertasActualizadas' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\providers\\sos_provider.dart:124:11', 'descripcion': "The value of local variable 'alertasActualizadas' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\providers\\sos_provider.dart:204:13', 'descripcion': "The value of local variable 'alertas' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\providers\\sos_provider.dart:341:11', 'descripcion': "The value of local variable 'alertasActualizadas' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\providers\\sos_provider.dart:352:11', 'descripcion': "The value of local variable 'alertasActualizadas' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\widgets\\common\\loading_widget.dart:111:11', 'descripcion': "The value of local variable 'theme' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\widgets\\reportes\\reporte_chart.dart:104:12', 'descripcion': "The value of local variable 'startAngle' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'migrate_cache_service.dart:34:9', 'descripcion': "The value of local variable 'filesUpdated' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'migrate_service_robust_fixed.dart:312:13', 'descripcion': "The value of local variable 'relativePath' isn't used"},
    {'tipo': 'unused_local_variable', 'gravedad': 'warning', 'archivo': 'validate_migration.dart:53:7', 'descripcion': "The value of local variable 'missing' isn't used"},
    
    // Campos no utilizados (15 problemas)
    {'tipo': 'unused_field', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\integrated_admin_service.dart:9:21', 'descripcion': "The value of field '_authService' isn't used"},
    {'tipo': 'unused_field', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\mensaje_service.dart:19:11', 'descripcion': "The value of field '_currentUserId' isn't used"},
    {'tipo': 'unused_field', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\offline_error_service.dart:184:23', 'descripcion': "The value of field '_errorStatsKey' isn't used"},
    {'tipo': 'unused_field', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\contenido_cache_service.dart:103:23', 'descripcion': "The value of field '_tagInvalidationKeyPrefix' isn't used"},
    {'tipo': 'unused_field', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\simple_data_service.dart:11:28', 'descripcion': "The value of field '_permissionService' isn't used"},
    {'tipo': 'unused_field', 'gravedad': 'warning', 'archivo': 'lib\\features\\gestante\\domain\\usecases\\get_gestantes_usecase.dart:23:28', 'descripcion': "The value of field '_repository' isn't used"},
    {'tipo': 'unused_field', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\admin\\usuario_form_screen.dart:20:29', 'descripcion': "The value of field '_usuarioService' isn't used"},
    {'tipo': 'unused_field', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\providers\\auth_provider.dart:114:29', 'descripcion': "The value of field '_refreshTokenUseCase' isn't used"},
    {'tipo': 'unused_field', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\providers\\auth_provider.dart:115:28', 'descripcion': "The value of field '_verifyTokenUseCase' isn't used"},
    {'tipo': 'unused_field', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\widgets\\layout\\sync_indicator.dart:15:9', 'descripcion': "The value of field '_syncQueueDao' isn't used"},
    {'tipo': 'unused_field', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\widgets\\players\\multimedia_player.dart:37:14', 'descripcion': "The value of field '_isFullScreen' isn't used"},
    
    // Elementos no utilizados (11 problemas)
    {'tipo': 'unused_element', 'gravedad': 'warning', 'archivo': 'lib\\core\\types\\result.dart:7:16', 'descripcion': "The declaration 'Result._' isn't referenced"},
    {'tipo': 'unused_element', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\contenido_cache_service.dart:99:7', 'descripcion': "The declaration '<unnamed>' isn't referenced"},
    {'tipo': 'unused_element', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\contenido_cache_service.dart:509:8', 'descripcion': "The declaration '_isContenidoInvalidated' isn't referenced"},
    {'tipo': 'unused_element', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\contenido_sync_service.dart:8:16', 'descripcion': "The declaration 'syncContenidoCategoria' isn't referenced"},
    {'tipo': 'unused_element', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\offline_error_service.dart:843:16', 'descripcion': "The declaration '_cleanupOldErrors' isn't referenced"},
    {'tipo': 'unused_element', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\alertas\\alertas_screen.dart:88:16', 'descripcion': "The declaration '_resolverAlerta' isn't referenced"},
    {'tipo': 'unused_element', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\alertas\\alertas_screen.dart:144:16', 'descripcion': "The declaration '_navegarAFormularioAlerta' isn't referenced"},
    {'tipo': 'unused_element', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\contenido\\contenido_screen.dart:298:8', 'descripcion': "The declaration '_filtrarContenidos' isn't referenced"},
    {'tipo': 'unused_element', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\sos_terminal_page.dart:340:12', 'descripcion': "The declaration 'build' isn't referenced"},
    {'tipo': 'unused_element', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\widgets\\contenido\\contenido_player_widget.dart:107:16', 'descripcion': "The declaration '_stop' isn't referenced"},
    {'tipo': 'unused_element', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\widgets\\players\\audio_player_widget.dart:121:16', 'descripcion': "The declaration '_stop' isn't referenced"},
    
    // Código muerto (15 problemas)
    {'tipo': 'dead_code', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\contenido_sync_service.dart:8:3', 'descripcion': "Dead code"},
    {'tipo': 'dead_code', 'gravedad': 'warning', 'archivo': 'lib\\domain\\usecases\\generate_report_usecase.dart:83:55', 'descripcion': "Dead code"},
    {'tipo': 'dead_code', 'gravedad': 'warning', 'archivo': 'lib\\domain\\usecases\\generate_report_usecase.dart:109:54', 'descripcion': "Dead code"},
    {'tipo': 'dead_code', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\home\\mensajes_screen.dart:328:29', 'descripcion': "Dead code"},
    {'tipo': 'dead_code', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\home\\mensajes_screen.dart:333:29', 'descripcion': "Dead code"},
    {'tipo': 'dead_code', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\home\\mensajes_screen.dart:353:35', 'descripcion': "Dead code"},
    {'tipo': 'dead_code', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\home\\mensajes_screen.dart:361:35', 'descripcion': "Dead code"},
    {'tipo': 'dead_code', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\reports_page.dart:244:26', 'descripcion': "Dead code"},
    {'tipo': 'dead_code_on_catch_subtype', 'gravedad': 'warning', 'archivo': 'lib\\domain\\usecases\\auth\\get_current_user_usecase.dart:26:7', 'descripcion': "Dead code: This on-catch block won't be executed because 'InvalidType' is a subtype of 'InvalidType' and hence will have been caught already"},
    {'tipo': 'dead_code_on_catch_subtype', 'gravedad': 'warning', 'archivo': 'lib\\domain\\usecases\\auth\\refresh_token_usecase.dart:41:7', 'descripcion': "Dead code: This on-catch block won't be executed because 'InvalidType' is a subtype of 'InvalidTokenException' and hence will have been caught already"},
    {'tipo': 'dead_code_on_catch_subtype', 'gravedad': 'warning', 'archivo': 'lib\\domain\\usecases\\auth\\sign_in_usecase.dart:66:7', 'descripcion': "Dead code: This on-catch block won't be executed because 'InvalidType' is a subtype of 'InvalidCredentialsException' and hence will have been caught already"},
    {'tipo': 'dead_code_on_catch_subtype', 'gravedad': 'warning', 'archivo': 'lib\\domain\\usecases\\auth\\sign_out_usecase.dart:21:7', 'descripcion': "Dead code: This on-catch block won't be executed because 'InvalidType' is a subtype of 'InvalidType' and hence will have been caught already"},
    {'tipo': 'dead_code_on_catch_subtype', 'gravedad': 'warning', 'archivo': 'lib\\domain\\usecases\\auth\\sign_up_usecase.dart:62:7', 'descripcion': "Dead code: This on-catch block won't be executed because 'InvalidType' is a subtype of 'InvalidType' and hence will have been caught already"},
    {'tipo': 'dead_code_on_catch_subtype', 'gravedad': 'warning', 'archivo': 'lib\\domain\\usecases\\auth\\verify_token_usecase.dart:23:7', 'descripcion': "Dead code: This on-catch block won't be executed because 'InvalidType' is a subtype of 'InvalidType' and hence will have been caught already"},
    {'tipo': 'dead_code_on_catch_subtype', 'gravedad': 'warning', 'archivo': 'lib\\domain\\usecases\\sos\\get_active_sos_alerts_usecase.dart:17:7', 'descripcion': "Dead code: This on-catch block won't be executed because 'InvalidType' is a subtype of 'InvalidType' and hence will have been caught already"},
    {'tipo': 'dead_code_on_catch_subtype', 'gravedad': 'warning', 'archivo': 'lib\\domain\\usecases\\sos\\get_sos_statistics_usecase.dart:18:7', 'descripcion': "Dead code: This on-catch block won't be executed because 'InvalidType' is a subtype of 'InvalidType' and hence will have been caught already"},
    {'tipo': 'dead_code_on_catch_subtype', 'gravedad': 'warning', 'archivo': 'lib\\domain\\usecases\\sos\\update_sos_status_usecase.dart:38:7', 'descripcion': "Dead code: This on-catch block won't be executed because 'InvalidType' is a subtype of 'InvalidType' and hence will have been caught already"},
    
    // Expresiones null-aware innecesarias (15 problemas)
    {'tipo': 'dead_null_aware_expression', 'gravedad': 'warning', 'archivo': 'lib\\core\\extensions\\string_extensions.dart:11:39', 'descripcion': "The left operand can't be null, so right operand is never executed"},
    {'tipo': 'dead_null_aware_expression', 'gravedad': 'warning', 'archivo': 'lib\\core\\extensions\\string_extensions.dart:17:39', 'descripcion': "The left operand can't be null, so right operand is never executed"},
    {'tipo': 'dead_null_aware_expression', 'gravedad': 'warning', 'archivo': 'lib\\core\\extensions\\string_extensions.dart:25:62', 'descripcion': "The left operand can't be null, so right operand is never executed"},
    {'tipo': 'dead_null_aware_expression', 'gravedad': 'warning', 'archivo': 'lib\\core\\extensions\\string_extensions.dart:31:39', 'descripcion': "The left operand can't be null, so right operand is never executed"},
    {'tipo': 'dead_null_aware_expression', 'gravedad': 'warning', 'archivo': 'lib\\core\\extensions\\string_extensions.dart:37:39', 'descripcion': "The left operand can't be null, so right operand is never executed"},
    {'tipo': 'dead_null_aware_expression', 'gravedad': 'warning', 'archivo': 'lib\\core\\extensions\\string_extensions.dart:110:39', 'descripcion': "The left operand can't be null, so right operand is never executed"},
    {'tipo': 'dead_null_aware_expression', 'gravedad': 'warning', 'archivo': 'lib\\core\\extensions\\string_extensions.dart:116:39', 'descripcion': "The left operand can't be null, so right operand is never executed"},
    {'tipo': 'dead_null_aware_expression', 'gravedad': 'warning', 'archivo': 'lib\\core\\extensions\\string_extensions.dart:131:39', 'descripcion': "The left operand can't be null, so right operand is never executed"},
    {'tipo': 'dead_null_aware_expression', 'gravedad': 'warning', 'archivo': 'lib\\core\\network\\api_service.dart:50:49', 'descripcion': "The left operand can't be null, so right operand is never executed"},
    {'tipo': 'dead_null_aware_expression', 'gravedad': 'warning', 'archivo': 'lib\\data\\datasources\\remote\\api_service.dart:49:49', 'descripcion': "The left operand can't be null, so right operand is never executed"},
    {'tipo': 'dead_null_aware_expression', 'gravedad': 'warning', 'archivo': 'lib\\data\\models\\contenido_unificado_converters.dart:13:41', 'descripcion': "The left operand can't be null, so right operand is never executed"},
    {'tipo': 'dead_null_aware_expression', 'gravedad': 'warning', 'archivo': 'lib\\data\\models\\dashboard_models.dart:46:70', 'descripcion': "The left operand can't be null, so right operand is never executed"},
    {'tipo': 'dead_null_aware_expression', 'gravedad': 'warning', 'archivo': 'lib\\data\\models\\dashboard_models.dart:46:102', 'descripcion': "The left operand can't be null, so right operand is never executed"},
    {'tipo': 'dead_null_aware_expression', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\providers\\sos_provider.dart:356:91', 'descripcion': "The left operand can't be null, so right operand is never executed"},
    
    // Operadores null innecesarios (8 problemas)
    {'tipo': 'invalid_null_aware_operator', 'gravedad': 'warning', 'archivo': 'lib\\core\\storage\\local_storage_manager.dart:53:69', 'descripcion': "The receiver can't be null, so null-aware operator '?.' is unnecessary"},
    {'tipo': 'invalid_null_aware_operator', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\path_provider_service.dart:16:91', 'descripcion': "The receiver can't be null, so null-aware operator '?.' is unnecessary"},
    {'tipo': 'invalid_null_aware_operator', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\path_provider_service.dart:17:23', 'descripcion': "The receiver can't be null, so null-aware operator '?.' is unnecessary"},
    {'tipo': 'invalid_null_aware_operator', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\path_provider_service.dart:29:86', 'descripcion': "The receiver can't be null, so null-aware operator '?.' is unnecessary"},
    {'tipo': 'invalid_null_aware_operator', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\path_provider_service.dart:30:23', 'descripcion': "The receiver can't be null, so null-aware operator '?.' is unnecessary"},
    {'tipo': 'invalid_null_aware_operator', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\path_provider_service.dart:42:88', 'descripcion': "The receiver can't be null, so null-aware operator '?.' is unnecessary"},
    {'tipo': 'invalid_null_aware_operator', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\path_provider_service.dart:43:23', 'descripcion': "The receiver can't be null, so null-aware operator '?.' is unnecessary"},
    {'tipo': 'invalid_null_aware_operator', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\path_provider_service.dart:55:86', 'descripcion': "The receiver can't be null, so null-aware operator '?.' is unnecessary"},
    {'tipo': 'invalid_null_aware_operator', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\path_provider_service.dart:56:23', 'descripcion': "The receiver can't be null, so null-aware operator '?.' is unnecessary"},
    
    // Aserciones no nulas innecesarias (10 problemas)
    {'tipo': 'unnecessary_non_null_assertion', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\sos_repository_impl.dart:114:49', 'descripcion': "The '!' will have no effect because the receiver can't be null"},
    {'tipo': 'unnecessary_non_null_assertion', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\sos_repository_impl.dart:118:43', 'descripcion': "The '!' will have no effect because the receiver can't be null"},
    {'tipo': 'unnecessary_non_null_assertion', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\sos_repository_impl.dart:386:49', 'descripcion': "The '!' will have no effect because the receiver can't be null"},
    {'tipo': 'unnecessary_non_null_assertion', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\sos_repository_impl.dart:390:43', 'descripcion': "The '!' will have no effect because the receiver can't be null"},
    {'tipo': 'unnecessary_non_null_assertion', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\sos_repository_impl.dart:429:49', 'descripcion': "The '!' will have no effect because the receiver can't be null"},
    {'tipo': 'unnecessary_non_null_assertion', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\sos_repository_impl.dart:433:43', 'descripcion': "The '!' will have no effect because the receiver can't be null"},
    {'tipo': 'unnecessary_non_null_assertion', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\sos_repository_impl.dart:521:49', 'descripcion': "The '!' will have no effect because the receiver can't be null"},
    {'tipo': 'unnecessary_non_null_assertion', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\sos_repository_impl.dart:525:43', 'descripcion': "The '!' will have no effect because the receiver can't be null"},
    {'tipo': 'unnecessary_non_null_assertion', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\sos_repository_impl.dart:609:49', 'descripcion': "The '!' will have no effect because the receiver can't be null"},
    {'tipo': 'unnecessary_non_null_assertion', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\sos_repository_impl.dart:613:43', 'descripcion': "The '!' will have no effect because the receiver can't be null"},
    {'tipo': 'unnecessary_non_null_assertion', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\providers\\auth_provider.dart:589:57', 'descripcion': "The '!' will have no effect because the receiver can't be null"},
    {'tipo': 'unnecessary_non_null_assertion', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\providers\\auth_provider.dart:641:57', 'descripcion': "The '!' will have no effect because the receiver can't be null"},
    {'tipo': 'unnecessary_non_null_assertion', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\providers\\auth_provider.dart:785:26', 'descripcion': "The '!' will have no effect because the receiver can't be null"},
    
    // Comparaciones nulas innecesarias (4 problemas)
    {'tipo': 'unnecessary_null_comparison', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\providers\\auth_provider.dart:784:27', 'descripcion': "The operand can't be 'null', so condition is always 'true'"},
    {'tipo': 'unnecessary_null_comparison', 'gravedad': 'warning', 'archivo': 'migrate_service.dart:87:19', 'descripcion': "The operand can't be 'null', so condition is always 'true'"},
    {'tipo': 'unnecessary_null_comparison', 'gravedad': 'warning', 'archivo': 'migrate_service.dart:94:19', 'descripcion': "The operand can't be 'null', so condition is always 'true'"},
    {'tipo': 'unnecessary_null_comparison', 'gravedad': 'warning', 'archivo': 'migrate_service_robust.dart:114:19', 'descripcion': "The operand can't be 'null', so condition is always 'true'"},
    {'tipo': 'unnecessary_null_comparison', 'gravedad': 'warning', 'archivo': 'migrate_service_robust.dart:120:19', 'descripcion': "The operand can't be 'null', so condition is always 'true'"},
    
    // Overrides incorrectos (16 problemas)
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:10:16', 'descripcion': "The field doesn't override an inherited getter or setter"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:13:17', 'descripcion': "The field doesn't override an inherited getter or setter"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:29:26', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:73:26', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:98:26', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:123:26', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:148:26', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:173:26', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:198:26', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:223:26', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:332:16', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:352:16', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:372:16', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:392:16', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:412:16', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:446:26', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:466:32', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:485:26', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\gestante_repository_impl.dart:515:15', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\user_repository_impl.dart:93:16', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\data\\repositories\\user_repository_impl.dart:496:16', 'descripcion': "The method doesn't override an inherited method"},
    {'tipo': 'override_on_non_overriding_member', 'gravedad': 'warning', 'archivo': 'lib\\presentation\\pages\\sos_terminal_page.dart:19:10', 'descripcion': "The method doesn't override an inherited method"},
    
    // Etiquetas no utilizadas (8 problemas)
    {'tipo': 'unused_label', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\integrated_admin_service.dart:127:9', 'descripcion': "The label 'body' isn't used"},
    {'tipo': 'unused_label', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\integrated_admin_service.dart:144:9', 'descripcion': "The label 'body' isn't used"},
    {'tipo': 'unused_label', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\integrated_admin_service.dart:164:9', 'descripcion': "The label 'body' isn't used"},
    {'tipo': 'unused_label', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\integrated_admin_service.dart:246:9', 'descripcion': "The label 'body' isn't used"},
    {'tipo': 'unused_label', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\integrated_admin_service.dart:263:9', 'descripcion': "The label 'body' isn't used"},
    {'tipo': 'unused_label', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\integrated_admin_service.dart:283:9', 'descripcion': "The label 'body' isn't used"},
    {'tipo': 'unused_label', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\integrated_admin_service.dart:303:9', 'descripcion': "The label 'body' isn't used"},
    {'tipo': 'unused_label', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\integrated_admin_service.dart:470:9', 'descripcion': "The label 'body' isn't used"},
    {'tipo': 'unused_label', 'gravedad': 'warning', 'archivo': 'lib\\data\\services\\integrated_admin_service.dart:515:9', 'descripcion': "The label 'body' isn't used"},
    
    // Importaciones duplicadas (6 problemas)
    {'tipo': 'duplicate_import', 'gravedad': 'warning', 'archivo': 'lib\\core\\providers\\service_providers.dart:13:8', 'descripcion': "Duplicate import"},
    {'tipo': 'duplicate_import', 'gravedad': 'warning', 'archivo': 'lib\\core\\providers\\service_providers.dart:14:8', 'descripcion': "Duplicate import"},
    {'tipo': 'duplicate_import', 'gravedad': 'warning', 'archivo': 'lib\\core\\utils\\file_picker_helper.dart:3:8', 'descripcion': "Duplicate import"},
    {'tipo': 'duplicate_import', 'gravedad': 'warning', 'archivo': 'lib\\data\\models\\gestante_model.dart:3:8', 'descripcion': "Duplicate import"},
    {'tipo': 'duplicate_import', 'gravedad': 'warning', 'archivo': 'lib\\domain\\repositories\\auth_repository.dart:2:8', 'descripcion': "Duplicate import"},
    {'tipo': 'duplicate_import', 'gravedad': 'warning', 'archivo': 'lib\\domain\\repositories\\user_repository.dart:2:8', 'descripcion': "Duplicate import"},
    
    // Dependencias de desarrollo innecesarias (5 problemas)
    {'tipo': 'unnecessary_dev_dependency', 'gravedad': 'warning', 'archivo': 'pubspec.yaml:68:3', 'descripcion': "The dev dependency on flutter_riverpod is unnecessary because there is also a normal dependency on that package"},
    {'tipo': 'unnecessary_dev_dependency', 'gravedad': 'warning', 'archivo': 'pubspec.yaml:69:3', 'descripcion': "The dev dependency on build_runner is unnecessary because there is also a normal dependency on that package"},
    {'tipo': 'unnecessary_dev_dependency', 'gravedad': 'warning', 'archivo': 'pubspec.yaml:70:3', 'descripcion': "The dev dependency on json_serializable is unnecessary because there is also a normal dependency on that package"},
    {'tipo': 'unnecessary_dev_dependency', 'gravedad': 'warning', 'archivo': 'pubspec.yaml:71:3', 'descripcion': "The dev dependency on freezed is unnecessary because there is also a normal dependency on that package"},
    {'tipo': 'unnecessary_dev_dependency', 'gravedad': 'warning', 'archivo': 'pubspec.yaml:72:3', 'descripcion': "The dev dependency on mockito is unnecessary because there is also a normal dependency on that package"},
  ];

  // Contar problemas por tipo
  final Map<String, int> conteoPorTipo = {};
  for (final problema in problemas) {
    final tipo = problema['tipo'] as String;
    conteoPorTipo[tipo] = (conteoPorTipo[tipo] ?? 0) + 1;
  }

  // Contar problemas por gravedad
  final Map<String, int> conteoPorGravedad = {};
  for (final problema in problemas) {
    final gravedad = problema['gravedad'] as String;
    conteoPorGravedad[gravedad] = (conteoPorGravedad[gravedad] ?? 0) + 1;
  }

  // Agrupar problemas por archivo
  final Map<String, int> conteoPorArchivo = {};
  for (final problema in problemas) {
    final archivo = (problema['archivo'] as String).split(':')[0];
    conteoPorArchivo[archivo] = (conteoPorArchivo[archivo] ?? 0) + 1;
  }

  // Imprimir resultados
  stdout.writeln('=== ANÁLISIS DE PROBLEMAS DEL PROYECTO FLUTTER ===');
  stdout.writeln('\nTOTAL DE PROBLEMAS: ${problemas.length}');
  
  stdout.writeln('\n--- PROBLEMAS POR TIPO ---');
  conteoPorTipo.forEach((tipo, cantidad) {
    stdout.writeln('$tipo: $cantidad');
  });
  
  stdout.writeln('\n--- PROBLEMAS POR GRAVEDAD ---');
  conteoPorGravedad.forEach((gravedad, cantidad) {
    stdout.writeln('$gravedad: $cantidad');
  });
  
  stdout.writeln('\n--- ARCHIVOS CON MÁS PROBLEMAS (Top 10) ---');
  final archivosOrdenados = conteoPorArchivo.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  for (int i = 0; i < archivosOrdenados.length && i < 10; i++) {
    final entrada = archivosOrdenados[i];
    stdout.writeln('${i + 1}. ${entrada.key}: ${entrada.value} problemas');
  }
}