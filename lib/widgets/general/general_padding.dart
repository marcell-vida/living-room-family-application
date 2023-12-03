import 'package:flutter/material.dart';

class GeneralPadding extends StatelessWidget {
  final Widget? child;
  final List<Widget>? children;
  final double horizontal;
  final double vertical;
  final MainAxisAlignment mainAxisAlignment;

  const GeneralPadding({super.key,
    this.child,
    this.children,
    this.horizontal = 10,
    this.vertical = 0,
    this.mainAxisAlignment = MainAxisAlignment.start});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: child ??
          Column(
              mainAxisAlignment: mainAxisAlignment, children: children ?? []),
    );
  }
}
