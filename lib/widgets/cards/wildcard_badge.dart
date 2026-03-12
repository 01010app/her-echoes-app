import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class WildcardBadge extends StatelessWidget {
  final bool isEnglish;
  const WildcardBadge({super.key, this.isEnglish = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF28A52A).withOpacity(0.85),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PhosphorIcon(
            PhosphorIcons.shootingStar(PhosphorIconsStyle.fill),
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isEnglish ? "Special" : "Especial",
            style: GoogleFonts.inter(
              fontSize: 10,
              height: 1.0,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}