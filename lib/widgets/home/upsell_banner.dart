import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:superellipse_shape/superellipse_shape.dart';

class UpsellBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final PhosphorIconData Function([PhosphorIconsStyle]) icon;
  final VoidCallback onTap;

  const UpsellBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF70F3D).withOpacity(0.80),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [

            // ÍCONO
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: PhosphorIcon(
                  icon(PhosphorIconsStyle.regular),
                  size: 28,
                  color: const Color(0xFFF70F3D),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // TEXTOS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // CHEVRON
            SizedBox(
              width: 20,
              height: 20,
              child: PhosphorIcon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                size: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}