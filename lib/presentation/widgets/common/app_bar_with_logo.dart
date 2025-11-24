import 'package:flutter/material.dart';
import 'package:madres_digitales_flutter_new/features/contenido/presentation/utils/resource_service.dart';

PreferredSizeWidget appBarWithLogo({String? title, List<Widget>? actions, PreferredSizeWidget? bottom}) {
  return AppBar(
    title: Row(
      children: [
        ResourceService.buildAppLogo(width: 28, height: 28),
        const SizedBox(width: 8),
        Text(title ?? 'Madres Digitales'),
      ],
    ),
    centerTitle: false,
    actions: actions,
    bottom: bottom,
  );
}
