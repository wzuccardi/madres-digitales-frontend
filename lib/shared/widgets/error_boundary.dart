import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// Error Boundary Widget
/// Captura errores en el árbol de widgets y muestra una UI amigable
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? errorBuilder;
  final void Function(FlutterErrorDetails)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();
    
    // Capturar errores de Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log del error
      developer.log(
        'Error capturado por ErrorBoundary',
        error: details.exception,
        stackTrace: details.stack,
        name: 'ErrorBoundary',
      );

      // Callback personalizado
      widget.onError?.call(details);

      // Actualizar estado para mostrar UI de error
      if (mounted) {
        setState(() {
          _errorDetails = details;
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      // Mostrar UI de error personalizada o por defecto
      return widget.errorBuilder?.call(_errorDetails!) ??
          _buildDefaultErrorWidget(context);
    }

    return widget.child;
  }

  Widget _buildDefaultErrorWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red[700],
                ),
                const SizedBox(height: 24),
                Text(
                  '¡Ups! Algo salió mal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ha ocurrido un error inesperado. Por favor, intenta de nuevo.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _errorDetails = null;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_errorDetails != null)
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Detalles del Error'),
                          content: SingleChildScrollView(
                            child: Text(
                              _errorDetails!.exception.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Ver detalles técnicos'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para capturar errores en secciones específicas
class ErrorCatcher extends StatelessWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  const ErrorCatcher({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      developer.log(
        'Error capturado por ErrorCatcher',
        error: details.exception,
        stackTrace: details.stack,
        name: 'ErrorCatcher',
      );

      if (errorBuilder != null) {
        return errorBuilder!(details.exception, details.stack);
      }

      return _buildDefaultErrorWidget(context, details);
    };

    return child;
  }

  Widget _buildDefaultErrorWidget(
    BuildContext context,
    FlutterErrorDetails details,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.red[50],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[700],
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'Error al cargar este componente',
            style: TextStyle(
              color: Colors.red[900],
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            details.exception.toString(),
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Mixin para manejar errores en StatefulWidgets
mixin ErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  String? _errorMessage;
  bool _hasError = false;

  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  void handleError(Object error, [StackTrace? stackTrace]) {
    developer.log(
      'Error manejado por ErrorHandlerMixin',
      error: error,
      stackTrace: stackTrace,
      name: 'ErrorHandlerMixin',
    );

    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  void clearError() {
    if (mounted) {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
    }
  }

  Widget buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[700],
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[900],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Ha ocurrido un error',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: clearError,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Función helper para ejecutar código con manejo de errores
Future<T?> runWithErrorHandling<T>({
  required Future<T> Function() action,
  required void Function(Object error, StackTrace stackTrace) onError,
  T? defaultValue,
}) async {
  try {
    return await action();
  } catch (error, stackTrace) {
    developer.log(
      'Error capturado por runWithErrorHandling',
      error: error,
      stackTrace: stackTrace,
      name: 'ErrorHandling',
    );
    onError(error, stackTrace);
    return defaultValue;
  }
}

