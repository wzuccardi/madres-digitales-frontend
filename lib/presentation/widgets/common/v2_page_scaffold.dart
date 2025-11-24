import 'package:flutter/material.dart';

class V2PageScaffold extends StatelessWidget {
  const V2PageScaffold({super.key, required this.title, required this.body, this.actions});
  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: Padding(padding: const EdgeInsets.all(16), child: body),
    );
  }
}