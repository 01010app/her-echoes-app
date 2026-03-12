import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    final Color bgColor = isOutlined
        ? Colors.transparent
        : (enabled ? const Color(0xFFE1002D) : const Color(0xFF949494));
    final Color textColor =
        isOutlined ? const Color(0xFFE1002D) : Colors.white;
    final Color splashColor = isOutlined
        ? const Color(0xFFE1002D).withOpacity(0.08)
        : enabled
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.08);

    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        elevation: enabled && !isOutlined ? 2 : 0,
        shadowColor: const Color(0xFFE1002D).withOpacity(0.25),
        child: InkWell(
          onTap: () => onPressed?.call(),  // siempre hay callback → siempre hay ripple
          borderRadius: BorderRadius.circular(16),
          splashColor: splashColor,
          highlightColor: splashColor,
          child: Container(
            decoration: isOutlined
                ? BoxDecoration(
                    border: Border.all(color: const Color(0xFFE1002D)),
                    borderRadius: BorderRadius.circular(16),
                  )
                : null,
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}