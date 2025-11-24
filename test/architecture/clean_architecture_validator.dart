import 'dart:io';
import 'dart:mirrors';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Validador de Clean Architecture para Madres Digitales
/// Verifica que el proyecto siga los principios de Clean Architecture
class CleanArchitectureValidator {
  static final CleanArchitectureValidator _instance = CleanArchitectureValidator._internal();
  factory CleanArchitectureValidator() => _instance;
  CleanArchitectureValidator._internal();

  final List<ArchitectureViolation> _violations = [];
  final Map<String, List<String>> _layerDependencies = {};

  /// Ejecuta validación completa de Clean Architecture
  ArchitectureValidationResult validateProject(String projectPath) {
    _violations.clear();
    _layerDependencies.clear();

    print('🔍 Iniciando validación de Clean Architecture...');
    print('📁 Ruta del proyecto: $projectPath');

    // 1. Validar estructura de directorios
    _validateDirectoryStructure(projectPath);

    // 2. Validar dependencias entre capas
    _validateLayerDependencies(projectPath);

    // 3. Validar principios SOLID
    _validateSolidPrinciples(projectPath);

    // 4. Validar patrones de arquitectura
    _validateArchitecturePatterns(projectPath);

    // 5. Validar convenciones de nomenclatura
    _validateNamingConventions(projectPath);

    // 6. Validar separación de responsabilidades
    _validateResponsibilitySeparation(projectPath);

    // 7. Validar inyección de dependencias
    _validateDependencyInjection(projectPath);

    // 8. Validar manejo de errores
    _validateErrorHandling(projectPath);

    final result = ArchitectureValidationResult(
      violations: List.from(_violations),
      layerDependencies: Map.from(_layerDependencies),
      totalViolations: _violations.length,
      score: _calculateArchitectureScore(),
    );

    _printValidationResults(result);
    return result;
  }

  /// Valida la estructura de directorios según Clean Architecture
  void _validateDirectoryStructure(String projectPath) {
    print('📂 Validando estructura de directorios...');

    final requiredDirectories = [
      'lib/domain/',
      'lib/domain/entities/',
      'lib/domain/repositories/',
      'lib/domain/usecases/',
      'lib/data/',
      'lib/data/repositories/',
      'lib/data/datasources/',
      'lib/data/models/',
      'lib/presentation/',
      'lib/presentation/pages/',
      'lib/presentation/widgets/',
      'lib/presentation/providers/',
      'lib/core/',
      'lib/core/errors/',
      'lib/core/utils/',
      'lib/core/services/',
    ];

    for (final directory in requiredDirectories) {
      final fullPath = '$projectPath$directory';
      final dir = Directory(fullPath);
      
      if (!dir.existsSync()) {
        _violations.add(ArchitectureViolation(
          type: ViolationType.directoryStructure,
          severity: ViolationSeverity.high,
          description: 'Directorio requerido no encontrado: $directory',
          file: fullPath,
          recommendation: 'Crear el directorio faltante según Clean Architecture',
        ));
      } else {
        print('✅ $directory');
      }
    }
  }

  /// Valida que las dependencias entre capas sean correctas
  void _validateLayerDependencies(String projectPath) {
    print('🔗 Validando dependencias entre capas...');

    final libDir = Directory('$projectPath/lib');
    if (!libDir.existsSync()) return;

    // Reglas de dependencias permitidas
    final allowedDependencies = {
      'domain': [], // Domain no debe depender de nadie
      'data': ['domain'], // Data solo puede depender de Domain
      'presentation': ['domain', 'data'], // Presentation puede depender de Domain y Data
      'core': [], // Core debe ser independiente
    };

    _analyzeDirectory(libDir, allowedDependencies, projectPath);
  }

  /// Analiza archivos en busca de dependencias incorrectas
  void _analyzeDirectory(
    Directory dir,
    Map<String, List<String>> allowedDependencies,
    String projectPath,
  ) {
    dir.listSync(recursive: true).where((file) => 
      file.path.endsWith('.dart') && !file.path.contains('.dart_tools')
    ).forEach((file) {
      _analyzeFileDependencies(file, allowedDependencies, projectPath);
    });
  }

  /// Analiza dependencias en un archivo específico
  void _analyzeFileDependencies(
    File file,
    Map<String, List<String>> allowedDependencies,
    String projectPath,
  ) {
    try {
      final content = file.readAsStringSync();
      final relativePath = file.path.replaceFirst('$projectPath/', '');
      
      // Determinar capa actual
      final currentLayer = _determineLayer(relativePath);
      if (currentLayer == null) return;

      // Extraer imports
      final imports = _extractImports(content);
      
      for (final importPath in imports) {
        final targetLayer = _determineLayer(importPath);
        if (targetLayer == null) continue;

        // Verificar si la dependencia es permitida
        if (!allowedDependencies[currentLayer]!.contains(targetLayer)) {
          _violations.add(ArchitectureViolation(
            type: ViolationType.layerDependency,
            severity: ViolationSeverity.high,
            description: 'Dependencia no permitida: $currentLayer → $targetLayer',
            file: relativePath,
            line: _findImportLine(content, importPath),
            recommendation: 'Mover la dependencia a una capa permitida o usar interfaces',
          ));
        }
      }
    } catch (e) {
      print('⚠️ Error analizando archivo ${file.path}: $e');
    }
  }

  /// Determina la capa de Clean Architecture basada en la ruta
  String? _determineLayer(String path) {
    if (path.startsWith('lib/domain/')) return 'domain';
    if (path.startsWith('lib/data/')) return 'data';
    if (path.startsWith('lib/presentation/')) return 'presentation';
    if (path.startsWith('lib/core/')) return 'core';
    return null;
  }

  /// Extrae imports de un archivo Dart
  List<String> _extractImports(String content) {
    final regex = RegExp(r"import\s+['\"]([^'\"]+)['\"]");
    final matches = regex.allMatches(content);
    return matches.map((match) => match.group(1)!).toList();
  }

  /// Encuentra la línea de un import específico
  int _findImportLine(String content, String importPath) {
    final lines = content.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains(importPath)) {
        return i + 1;
      }
    }
    return 0;
  }

  /// Valida principios SOLID
  void _validateSolidPrinciples(String projectPath) {
    print('🏗️ Validando principios SOLID...');

    // Single Responsibility Principle
    _validateSingleResponsibility(projectPath);
    
    // Open/Closed Principle
    _validateOpenClosed(projectPath);
    
    // Liskov Substitution Principle
    _validateLiskovSubstitution(projectPath);
    
    // Interface Segregation Principle
    _validateInterfaceSegregation(projectPath);
    
    // Dependency Inversion Principle
    _validateDependencyInversion(projectPath);
  }

  /// Valida Single Responsibility Principle
  void _validateSingleResponsibility(String projectPath) {
    final libDir = Directory('$projectPath/lib');
    if (!libDir.existsSync()) return;

    libDir.listSync(recursive: true).where((file) => 
      file.path.endsWith('.dart')
    ).forEach((file) {
      try {
        final content = file.readAsStringSync();
        final className = _extractClassName(content);
        
        if (className == null) return;

        // Contar responsabilidades (métodos públicos)
        final publicMethods = _countPublicMethods(content);
        
        if (publicMethods > 10) {
          _violations.add(ArchitectureViolation(
            type: ViolationType.singleResponsibility,
            severity: ViolationSeverity.medium,
            description: 'Clase $className tiene demasiadas responsabilidades ($publicMethods métodos)',
            file: file.path.replaceFirst('$projectPath/', ''),
            recommendation: 'Dividir la clase en clases más pequeñas con responsabilidades específicas',
          ));
        }
      } catch (e) {
        print('⚠️ Error validando SRP en ${file.path}: $e');
      }
    });
  }

  /// Valida Open/Closed Principle
  void _validateOpenClosed(String projectPath) {
    // Buscar clases que podrían beneficiarse de polimorfismo
    final libDir = Directory('$projectPath/lib');
    if (!libDir.existsSync()) return;

    libDir.listSync(recursive: true).where((file) => 
      file.path.endsWith('.dart')
    ).forEach((file) {
      try {
        final content = file.readAsStringSync();
        
        // Buscar patrones de switch/case largos
        if (_hasLargeSwitchStatement(content)) {
          _violations.add(ArchitectureViolation(
            type: ViolationType.openClosed,
            severity: ViolationSeverity.medium,
            description: 'Clase con switch/case extenso detectado',
            file: file.path.replaceFirst('$projectPath/', ''),
            recommendation: 'Considerar usar polimorfismo o patrón Strategy',
          ));
        }
      } catch (e) {
        print('⚠️ Error validando OCP en ${file.path}: $e');
      }
    });
  }

  /// Valida Liskov Substitution Principle
  void _validateLiskovSubstitution(String projectPath) {
    // Buscar clases que sobreescriben métodos sin mantener el contrato
    final libDir = Directory('$projectPath/lib');
    if (!libDir.existsSync()) return;

    libDir.listSync(recursive: true).where((file) => 
      file.path.endsWith('.dart')
    ).forEach((file) {
      try {
        final content = file.readAsStringSync();
        
        // Buscar @override sin mantener contrato
        if (_hasProblematicOverride(content)) {
          _violations.add(ArchitectureViolation(
            type: ViolationType.liskovSubstitution,
            severity: ViolationSeverity.medium,
            description: 'Posible violación de Liskov Substitution Principle',
            file: file.path.replaceFirst('$projectPath/', ''),
            recommendation: 'Asegurar que las clases derivadas puedan sustituir a las bases',
          ));
        }
      } catch (e) {
        print('⚠️ Error validando LSP en ${file.path}: $e');
      }
    });
  }

  /// Valida Interface Segregation Principle
  void _validateInterfaceSegregation(String projectPath) {
    // Buscar interfaces demasiado grandes
    final libDir = Directory('$projectPath/lib');
    if (!libDir.existsSync()) return;

    libDir.listSync(recursive: true).where((file) => 
      file.path.endsWith('.dart')
    ).forEach((file) {
      try {
        final content = file.readAsStringSync();
        
        if (_isLargeInterface(content)) {
          _violations.add(ArchitectureViolation(
            type: ViolationType.interfaceSegregation,
            severity: ViolationSeverity.medium,
            description: 'Interface demasiado grande detectada',
            file: file.path.replaceFirst('$projectPath/', ''),
            recommendation: 'Dividir la interface en interfaces más pequeñas y cohesivas',
          ));
        }
      } catch (e) {
        print('⚠️ Error validando ISP en ${file.path}: $e');
      }
    });
  }

  /// Valida Dependency Inversion Principle
  void _validateDependencyInversion(String projectPath) {
    // Buscar dependencias directas a implementaciones concretas
    final libDir = Directory('$projectPath/lib');
    if (!libDir.existsSync()) return;

    libDir.listSync(recursive: true).where((file) => 
      file.path.endsWith('.dart')
    ).forEach((file) {
      try {
        final content = file.readAsStringSync();
        final layer = _determineLayer(file.path.replaceFirst('$projectPath/', ''));
        
        if (layer == 'domain') {
          // Domain no debe depender de implementaciones concretas
          if (_hasConcreteDependencies(content)) {
            _violations.add(ArchitectureViolation(
              type: ViolationType.dependencyInversion,
              severity: ViolationSeverity.high,
              description: 'Dependencia directa a implementación concreta en capa domain',
              file: file.path.replaceFirst('$projectPath/', ''),
              recommendation: 'Usar interfaces y dependency injection',
            ));
          }
        }
      } catch (e) {
        print('⚠️ Error validando DIP en ${file.path}: $e');
      }
    });
  }

  /// Valida patrones de arquitectura
  void _validateArchitecturePatterns(String projectPath) {
    print('🎯 Validando patrones de arquitectura...');

    // Validar uso de Repository pattern
    _validateRepositoryPattern(projectPath);
    
    // Validar uso de Use Case pattern
    _validateUseCasePattern(projectPath);
    
    // Validar uso de Provider pattern
    _validateProviderPattern(projectPath);
  }

  /// Valida implementación del Repository pattern
  void _validateRepositoryPattern(String projectPath) {
    final repositoryDir = Directory('$projectPath/lib/domain/repositories');
    if (!repositoryDir.existsSync()) return;

    repositoryDir.listSync().where((file) => 
      file.path.endsWith('.dart')
    ).forEach((file) {
      try {
        final content = file.readAsStringSync();
        final className = _extractClassName(content);
        
        if (className == null) return;

        // Verificar que sea una clase abstracta
        if (!content.contains('abstract class') && !content.contains('abstract')) {
          _violations.add(ArchitectureViolation(
            type: ViolationType.repositoryPattern,
            severity: ViolationSeverity.high,
            description: 'Repository $className no es abstracto',
            file: file.path.replaceFirst('$projectPath/', ''),
            recommendation: 'Los repositories deben ser abstractos o interfaces',
          ));
        }
      } catch (e) {
        print('⚠️ Error validando Repository en ${file.path}: $e');
      }
    });
  }

  /// Valida implementación del Use Case pattern
  void _validateUseCasePattern(String projectPath) {
    final useCaseDir = Directory('$projectPath/lib/domain/usecases');
    if (!useCaseDir.existsSync()) return;

    useCaseDir.listSync().where((file) => 
      file.path.endsWith('.dart')
    ).forEach((file) {
      try {
        final content = file.readAsStringSync();
        final className = _extractClassName(content);
        
        if (className == null) return;

        // Verificar que tenga un método execute
        if (!content.contains('Future<') || !content.contains('execute(')) {
          _violations.add(ArchitectureViolation(
            type: ViolationType.useCasePattern,
            severity: ViolationSeverity.high,
            description: 'Use Case $className no sigue el patrón estándar',
            file: file.path.replaceFirst('$projectPath/', ''),
            recommendation: 'Implementar método execute() con tipo de retorno futuro',
          ));
        }
      } catch (e) {
        print('⚠️ Error validando Use Case en ${file.path}: $e');
      }
    });
  }

  /// Valida implementación del Provider pattern
  void _validateProviderPattern(String projectPath) {
    final providerDir = Directory('$projectPath/lib/presentation/providers');
    if (!providerDir.existsSync()) return;

    providerDir.listSync().where((file) => 
      file.path.endsWith('.dart')
    ).forEach((file) {
      try {
        final content = file.readAsStringSync();
        final className = _extractClassName(content);
        
        if (className == null) return;

        // Verificar que extienda StateNotifier o similar
        if (!content.contains('StateNotifier') && 
            !content.contains('ChangeNotifier') && 
            !content.contains('Provider')) {
          _violations.add(ArchitectureViolation(
            type: ViolationType.providerPattern,
            severity: ViolationSeverity.medium,
            description: 'Provider $className no sigue el patrón Riverpod',
            file: file.path.replaceFirst('$projectPath/', ''),
            recommendation: 'Usar StateNotifier, ChangeNotifier o Provider de Riverpod',
          ));
        }
      } catch (e) {
        print('⚠️ Error validando Provider en ${file.path}: $e');
      }
    });
  }

  /// Valida convenciones de nomenclatura
  void _validateNamingConventions(String projectPath) {
    print('📝 Validando convenciones de nomenclatura...');

    final libDir = Directory('$projectPath/lib');
    if (!libDir.existsSync()) return;

    libDir.listSync(recursive: true).where((file) => 
      file.path.endsWith('.dart')
    ).forEach((file) {
      try {
        final content = file.readAsStringSync();
        final className = _extractClassName(content);
        final relativePath = file.path.replaceFirst('$projectPath/', '');
        
        if (className == null) return;

        // Validar nombres según capa
        final layer = _determineLayer(relativePath);
        if (layer != null) {
          _validateClassNameNaming(className, layer, relativePath);
        }
      } catch (e) {
        print('⚠️ Error validando nomenclatura en ${file.path}: $e');
      }
    });
  }

  /// Valida naming de clases según capa
  void _validateClassNameNaming(String className, String layer, String filePath) {
    switch (layer) {
      case 'domain/entities':
        if (!className.endsWith('Entity') && !className.endsWith('Model')) {
          _violations.add(ArchitectureViolation(
            type: ViolationType.namingConvention,
            severity: ViolationSeverity.low,
            description: 'Entity $className no sigue convención de nomenclatura',
            file: filePath,
            recommendation: 'Usar sufijo Entity o Model para entidades de dominio',
          ));
        }
        break;
      case 'domain/repositories':
        if (!className.endsWith('Repository')) {
          _violations.add(ArchitectureViolation(
            type: ViolationType.namingConvention,
            severity: ViolationSeverity.low,
            description: 'Repository $className no sigue convención de nomenclatura',
            file: filePath,
            recommendation: 'Usar sufijo Repository para interfaces de repositorio',
          ));
        }
        break;
      case 'domain/usecases':
        if (!className.endsWith('UseCase')) {
          _violations.add(ArchitectureViolation(
            type: ViolationType.namingConvention,
            severity: ViolationSeverity.low,
            description: 'Use Case $className no sigue convención de nomenclatura',
            file: filePath,
            recommendation: 'Usar sufijo UseCase para casos de uso',
          ));
        }
        break;
    }
  }

  /// Valida separación de responsabilidades
  void _validateResponsibilitySeparation(String projectPath) {
    print('⚖️ Validando separación de responsabilidades...');

    // Buscar clases con múltiples responsabilidades
    final libDir = Directory('$projectPath/lib');
    if (!libDir.existsSync()) return;

    libDir.listSync(recursive: true).where((file) => 
      file.path.endsWith('.dart')
    ).forEach((file) {
      try {
        final content = file.readAsStringSync();
        final className = _extractClassName(content);
        
        if (className == null) return;

        // Analizar complejidad ciclomática (simplificado)
        final complexity = _calculateCyclomaticComplexity(content);
        
        if (complexity > 10) {
          _violations.add(ArchitectureViolation(
            type: ViolationType.responsibilitySeparation,
            severity: ViolationSeverity.medium,
            description: 'Clase $className con alta complejidad ($complexity)',
            file: file.path.replaceFirst('$projectPath/', ''),
            recommendation: 'Refactorizar para reducir complejidad y separar responsabilidades',
          ));
        }
      } catch (e) {
        print('⚠️ Error validando separación de responsabilidades en ${file.path}: $e');
      }
    });
  }

  /// Valida inyección de dependencias
  void _validateDependencyInjection(String projectPath) {
    print('💉 Validando inyección de dependencias...');

    // Buscar instanciación directa de dependencias
    final libDir = Directory('$projectPath/lib');
    if (!libDir.existsSync()) return;

    libDir.listSync(recursive: true).where((file) => 
      file.path.endsWith('.dart')
    ).forEach((file) {
      try {
        final content = file.readAsStringSync();
        final relativePath = file.path.replaceFirst('$projectPath/', '');
        final layer = _determineLayer(relativePath);
        
        if (layer == 'presentation') {
          // Buscar new() directo en presentación
          if (_hasDirectInstantiation(content)) {
            _violations.add(ArchitectureViolation(
              type: ViolationType.dependencyInjection,
              severity: ViolationSeverity.high,
              description: 'Instanciación directa de dependencias detectada',
              file: relativePath,
              recommendation: 'Usar inyección de dependencias con Riverpod',
            ));
          }
        }
      } catch (e) {
        print('⚠️ Error validando inyección de dependencias en ${file.path}: $e');
      }
    });
  }

  /// Valida manejo de errores
  void _validateErrorHandling(String projectPath) {
    print('🚨 Validando manejo de errores...');

    // Buscar try/catch sin manejo adecuado
    final libDir = Directory('$projectPath/lib');
    if (!libDir.existsSync()) return;

    libDir.listSync(recursive: true).where((file) => 
      file.path.endsWith('.dart')
    ).forEach((file) {
      try {
        final content = file.readAsStringSync();
        
        if (_hasPoorErrorHandling(content)) {
          _violations.add(ArchitectureViolation(
            type: ViolationType.errorHandling,
            severity: ViolationSeverity.medium,
            description: 'Manejo de errores inadecuado detectado',
            file: file.path.replaceFirst('$projectPath/', ''),
            recommendation: 'Implementar manejo de errores específico y logging',
          ));
        }
      } catch (e) {
        print('⚠️ Error validando manejo de errores en ${file.path}: $e');
      }
    });
  }

  // Métodos helper para análisis de código

  String? _extractClassName(String content) {
    final classRegex = RegExp(r'(?:class|abstract class)\s+(\w+)');
    final match = classRegex.firstMatch(content);
    return match?.group(1);
  }

  int _countPublicMethods(String content) {
    final methodRegex = RegExp(r'\s+(\w+)\s*\([^)]*\)\s*{');
    final matches = methodRegex.allMatches(content);
    return matches.length;
  }

  bool _hasLargeSwitchStatement(String content) {
    final switchRegex = RegExp(r'switch\s*\([^)]*\)\s*{');
    final matches = switchRegex.allMatches(content);
    
    for (final match in matches) {
      final startIndex = match.start;
      final endIndex = content.indexOf('}', startIndex);
      final switchContent = content.substring(startIndex, endIndex + 1);
      
      // Contar casos
      final caseCount = 'case'.allMatches(switchContent).length;
      if (caseCount > 5) return true;
    }
    return false;
  }

  bool _hasProblematicOverride(String content) {
    // Buscar @override que cambia comportamiento significativamente
    final overrideRegex = RegExp(r'@override\s+.*\{');
    final matches = overrideRegex.allMatches(content);
    
    for (final match in matches) {
      final startIndex = match.start;
      final endIndex = content.indexOf('}', startIndex);
      final overrideContent = content.substring(startIndex, endIndex + 1);
      
      // Verificar si lanza excepción diferente o tiene lógica muy diferente
      if (overrideContent.contains('throw') && 
          !overrideContent.contains('super.')) {
        return true;
      }
    }
    return false;
  }

  bool _isLargeInterface(String content) {
    if (!content.contains('abstract class')) return false;
    
    // Contar métodos abstractos
    final methodRegex = RegExp(r'(\w+)\s*\([^)]*\);');
    final matches = methodRegex.allMatches(content);
    
    return matches.length > 10; // Más de 10 métodos es demasiado grande
  }

  bool _hasConcreteDependencies(String content) {
    // Buscar imports de capas inferiores
    final imports = _extractImports(content);
    
    for (final importPath in imports) {
      if (importPath.contains('data/') || 
          importPath.contains('presentation/') ||
          importPath.contains('core/')) {
        return true;
      }
    }
    return false;
  }

  bool _hasDirectInstantiation(String content) {
    final newRegex = RegExp(r'\bnew\s+\w+\s*\(');
    return newRegex.hasMatch(content);
  }

  bool _hasPoorErrorHandling(String content) {
    // Buscar catch vacío o genérico
    final catchRegex = RegExp(r'catch\s*\([^)]*\)\s*{\s*}');
    return catchRegex.hasMatch(content);
  }

  int _calculateCyclomaticComplexity(String content) {
    // Simplificación: contar puntos de decisión
    int complexity = 1; // Base
    
    // Contar if, for, while, case, catch
    final decisionPoints = [
      RegExp(r'\bif\s*\('),
      RegExp(r'\bfor\s*\('),
      RegExp(r'\bwhile\s*\('),
      RegExp(r'\bcase\s+'),
      RegExp(r'\bcatch\s*\('),
    ];
    
    for (final regex in decisionPoints) {
      complexity += regex.allMatches(content).length;
    }
    
    return complexity;
  }

  /// Calcula puntaje de arquitectura
  double _calculateArchitectureScore() {
    if (_violations.isEmpty) return 100.0;
    
    // Penalización por severidad
    double totalPenalty = 0;
    for (final violation in _violations) {
      switch (violation.severity) {
        case ViolationSeverity.low:
          totalPenalty += 1;
          break;
        case ViolationSeverity.medium:
          totalPenalty += 3;
          break;
        case ViolationSeverity.high:
          totalPenalty += 5;
          break;
        case ViolationSeverity.critical:
          totalPenalty += 10;
          break;
      }
    }
    
    final maxPenalty = 100.0;
    final score = (maxPenalty - totalPenalty).clamp(0.0, maxPenalty);
    return score;
  }

  /// Imprime resultados de validación
  void _printValidationResults(ArchitectureValidationResult result) {
    print('\n📊 RESULTADOS DE VALIDACIÓN DE CLEAN ARCHITECTURE');
    print('=' * 60);
    print('📈 Puntaje General: ${result.score.toStringAsFixed(1)}/100');
    print('🔍 Total de Violaciones: ${result.totalViolations}');
    
    if (result.violations.isEmpty) {
      print('✅ ¡Excelente! No se encontraron violaciones de Clean Architecture.');
      return;
    }
    
    print('\n📋 Detalle de Violaciones por Severidad:');
    final violationsBySeverity = <ViolationSeverity, List<ArchitectureViolation>>{};
    for (final violation in result.violations) {
      violationsBySeverity.putIfAbsent(violation.severity, () => []).add(violation);
    }
    
    violationsBySeverity.forEach((severity, violations) {
      final severityName = severity.toString().split('.').last;
      print('  $severityName: ${violations.length} violaciones');
    });
    
    print('\n📋 Detalle por Tipo:');
    final violationsByType = <ViolationType, List<ArchitectureViolation>>{};
    for (final violation in result.violations) {
      violationsByType.putIfAbsent(violation.type, () => []).add(violation);
    }
    
    violationsByType.forEach((type, violations) {
      final typeName = type.toString().split('.').last;
      print('  $typeName: ${violations.length} violaciones');
      
      // Mostrar las 3 más críticas de cada tipo
      final sortedViolations = violations.toList()
        ..sort((a, b) => b.severity.index.compareTo(a.severity.index));
      
      for (int i = 0; i < sortedViolations.length && i < 3; i++) {
        final violation = sortedViolations[i];
        print('    🔸 ${violation.description}');
        print('       📁 ${violation.file}:${violation.line}');
        print('       💡 ${violation.recommendation}');
      }
    });
    
    print('\n🎯 Recomendaciones Prioritarias:');
    _printPrioritizedRecommendations(result);
  }

  /// Imprime recomendaciones priorizarias
  void _printPrioritizedRecommendations(ArchitectureValidationResult result) {
    final criticalViolations = result.violations
        .where((v) => v.severity == ViolationSeverity.critical)
        .toList();
    
    final highViolations = result.violations
        .where((v) => v.severity == ViolationSeverity.high)
        .toList();
    
    if (criticalViolations.isNotEmpty) {
      print('🚨 CRÍTICO - Atender inmediatamente:');
      for (final violation in criticalViolations.take(5)) {
        print('  🔴 ${violation.description}');
        print('     💡 ${violation.recommendation}');
      }
    }
    
    if (highViolations.isNotEmpty) {
      print('⚠️ ALTA PRIORIDAD - Corregir pronto:');
      for (final violation in highViolations.take(5)) {
        print('  🟠 ${violation.description}');
        print('     💡 ${violation.recommendation}');
      }
    }
    
    if (criticalViolations.isEmpty && highViolations.isEmpty) {
      print('✅ No hay violaciones críticas o de alta prioridad');
      print('   Continuar con las mejoras de media y baja prioridad');
    }
  }
}

/// Resultado de validación de Clean Architecture
class ArchitectureValidationResult {
  final List<ArchitectureViolation> violations;
  final Map<String, List<String>> layerDependencies;
  final int totalViolations;
  final double score;

  const ArchitectureValidationResult({
    required this.violations,
    required this.layerDependencies,
    required this.totalViolations,
    required this.score,
  });

  bool get isValid => score >= 80;
  bool get needsImprovement => score >= 60 && score < 80;
  bool get needsMajorRefactoring => score < 60;

  String get qualityLevel {
    if (score >= 90) return 'Excelente';
    if (score >= 80) return 'Bueno';
    if (score >= 70) return 'Aceptable';
    if (score >= 60) return 'Necesita Mejora';
    return 'Crítico';
  }
}

/// Violación de Clean Architecture detectada
class ArchitectureViolation {
  final ViolationType type;
  final ViolationSeverity severity;
  final String description;
  final String file;
  final int line;
  final String recommendation;

  const ArchitectureViolation({
    required this.type,
    required this.severity,
    required this.description,
    required this.file,
    this.line = 0,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'severity': severity.toString(),
      'description': description,
      'file': file,
      'line': line,
      'recommendation': recommendation,
    };
  }
}

/// Tipos de violaciones de Clean Architecture
enum ViolationType {
  directoryStructure,
  layerDependency,
  singleResponsibility,
  openClosed,
  liskovSubstitution,
  interfaceSegregation,
  dependencyInversion,
  repositoryPattern,
  useCasePattern,
  providerPattern,
  namingConvention,
  responsibilitySeparation,
  dependencyInjection,
  errorHandling,
}

/// Severidad de las violaciones
enum ViolationSeverity {
  low,
  medium,
  high,
  critical,
}