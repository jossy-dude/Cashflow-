import 'package:flutter/material.dart';

class OptimizedListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;

  const OptimizedListView({
    super.key,
    required this.children,
    this.padding,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: children.length,
      cacheExtent: 200,
      itemBuilder: (context, index) {
        return children[index];
      },
    );
  }
}
