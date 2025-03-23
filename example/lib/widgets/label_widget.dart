import 'package:flutter/material.dart';

class AppLabelWidget extends StatelessWidget {
  final String label;
  final Widget child;

  const AppLabelWidget({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        spacing: 4,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          child,
        ],
      ),
    );
  }
}
