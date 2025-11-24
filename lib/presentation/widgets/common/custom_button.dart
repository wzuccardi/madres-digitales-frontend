import 'package:flutter/material.dart';
import 'package:madres_digitales_flutter_new/core/theme/app_theme.dart';

/// Widget de botón personalizado
class CustomButton extends StatelessWidget {
  
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSecondary = false,
    this.isOutlined = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.textStyle,
    this.padding,
    this.icon,
    this.alignment = MainAxisAlignment.center,
    this.boxShadow,
    this.isFullWidth = false,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isOutlined;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final Widget? icon;
  final MainAxisAlignment alignment;
  final BoxShadow? boxShadow;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determinar colores según el tipo de botón
    Color bgColor = backgroundColor ?? Colors.transparent;
    Color fgColor = foregroundColor ?? Colors.white;
    Color bdColor = borderColor ?? Colors.transparent;
    double bdWidth = borderWidth ?? 1.0;
    
    if (isSecondary) {
      bgColor = backgroundColor ?? AppTheme.secondaryColor;
      fgColor = foregroundColor ?? Colors.white;
    } else if (isOutlined) {
      bgColor = backgroundColor ?? Colors.transparent;
      fgColor = foregroundColor ?? AppTheme.primaryColor;
      bdColor = borderColor ?? AppTheme.primaryColor;
      bdWidth = borderWidth ?? 1.5;
    } else {
      bgColor = backgroundColor ?? AppTheme.primaryColor;
      fgColor = foregroundColor ?? Colors.white;
    }
    
    // Si está deshabilitado
    if (isDisabled) {
      bgColor = Colors.grey.shade300;
      fgColor = Colors.grey.shade500;
      bdColor = Colors.grey.shade400;
    }
    
    // Estilo de texto
    TextStyle btnTextStyle = (textStyle ?? theme.textTheme.labelLarge?.copyWith(
      color: fgColor,
      fontWeight: FontWeight.w600,
    )) ?? const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
    
    // Contenido del botón
    Widget buttonContent;
    if (isLoading) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          ),
          if (text.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(text, style: btnTextStyle),
          ],
        ],
      );
    } else if (icon != null) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        children: [
          icon!,
          if (text.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(text, style: btnTextStyle),
          ],
        ],
      );
    } else {
      buttonContent = Text(text, style: btnTextStyle);
    }
    
    // Botón
    final button = Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius ?? 8),
      child: InkWell(
        onTap: (isDisabled || isLoading) ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        child: Container(
          width: isFullWidth ? double.infinity : width,
          height: height ?? 48,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : bgColor,
            border: Border.all(
              color: bdColor,
              width: bdWidth,
            ),
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
            boxShadow: boxShadow != null ? [boxShadow!] : null,
          ),
          child: Center(child: buttonContent),
        ),
      ),
    );
    
    return button;
  }
}

/// Widget de botón de texto (sin fondo)
class AppTextButton extends StatelessWidget {
  
  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isDisabled = false,
    this.textColor,
    this.textStyle,
    this.padding,
    this.icon,
    this.alignment = MainAxisAlignment.center,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final Color? textColor;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final Widget? icon;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color color = textColor ?? AppTheme.primaryColor;
    if (isDisabled) {
      color = Colors.grey.shade500;
    }
    
    TextStyle style = (textStyle ?? theme.textTheme.labelLarge?.copyWith(
      color: color,
      fontWeight: FontWeight.w600,
    )) ?? const TextStyle(
      fontWeight: FontWeight.w600,
    );
    
    Widget buttonContent;
    if (icon != null) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        children: [
          icon!,
          if (text.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(text, style: style),
          ],
        ],
      );
    } else {
      buttonContent = Text(text, style: style);
    }
    
    return GestureDetector(
      onTap: (isDisabled) ? null : onPressed,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(8),
        child: buttonContent,
      ),
    );
  }
}

/// Widget de botón de icono
class AppIconButton extends StatelessWidget {
  
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isDisabled = false,
    this.iconColor,
    this.iconSize,
    this.padding,
    this.tooltip,
    this.backgroundColor,
    this.borderRadius,
  });
  final Widget icon;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final Color? iconColor;
  final double? iconSize;
  final EdgeInsets? padding;
  final String? tooltip;
  final Color? backgroundColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color color = iconColor ?? theme.iconTheme.color ?? Colors.grey.shade700;
    if (isDisabled) {
      color = Colors.grey.shade400;
    }
    
    Widget button = Container(
      padding: padding ?? const EdgeInsets.all(8),
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
            )
          : null,
      child: IconTheme(
        data: IconThemeData(
          color: color,
          size: iconSize ?? 24,
        ),
        child: icon,
      ),
    );
    
    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    return GestureDetector(
      onTap: (isDisabled) ? null : onPressed,
      child: button,
    );
  }
}
