import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xFFF70F3D).withOpacity(0.64),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PhosphorIcon(
            PhosphorIcons.lockKey(PhosphorIconsStyle.fill),
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            "PRO",
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