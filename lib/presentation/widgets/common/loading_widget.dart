import 'package:flutter/material.dart';
import 'package:madres_digitales_flutter_new/core/theme/app_theme.dart';

/// Widget de carga personalizado
class LoadingWidget extends StatelessWidget {
  
  const LoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
    this.strokeWidth,
    this.isCentered = true,
  });
  final String? message;
  final double? size;
  final Color? color;
  final double? strokeWidth;
  final bool isCentered;

  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? AppTheme.primaryColor;
    final loadingSize = size ?? 24.0;
    final loadingStrokeWidth = strokeWidth ?? 3.0;
    
    final loadingIndicator = SizedBox(
      width: loadingSize,
      height: loadingSize,
      child: CircularProgressIndicator(
        strokeWidth: loadingStrokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
      ),
    );
    
    Widget content = loadingIndicator;
    
    if (message != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingIndicator,
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: loadingColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    if (isCentered) {
      content = Center(child: content);
    }
    
    return content;
  }
}

/// Widget de carga de pantalla completa
class FullScreenLoadingWidget extends StatelessWidget {
  
  const FullScreenLoadingWidget({
    super.key,
    this.message,
    this.backgroundColor,
    this.indicatorColor,
  });
  final String? message;
  final Color? backgroundColor;
  final Color? indicatorColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white.withValues(alpha: 0.8),
      body: Center(
        child: LoadingWidget(
          message: message,
          color: indicatorColor,
          size: 48,
        ),
      ),
    );
  }
}

/// Widget de carga con botón de cancelar
class LoadingWithCancelWidget extends StatelessWidget {
  
  const LoadingWithCancelWidget({
    super.key,
    required this.message,
    required this.onCancel,
    this.cancelText = 'Cancelar',
    this.indicatorColor,
    this.buttonColor,
  });
  final String message;
  final VoidCallback onCancel;
  final String cancelText;
  final Color? indicatorColor;
  final Color? buttonColor;

  @override
  Widget build(BuildContext context) {
    final btnColor = buttonColor ?? AppTheme.primaryColor;
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingWidget(
            message: message,
            color: indicatorColor,
            size: 48,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(cancelText),
          ),
        ],
      ),
    );
  }
}
