import 'package:flutter/material.dart';

class SettingsListContainer extends StatelessWidget {
  final List<Widget> children;

  const SettingsListContainer({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final borderWidth =
        1 / MediaQuery.of(context).devicePixelRatio; // 1 physical pixel

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD6D6D6),
            width: borderWidth,
          ),
        ),
        padding: const EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}