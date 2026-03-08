import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SettingsListItem extends StatefulWidget {
  final PhosphorIconData Function([PhosphorIconsStyle])? icon;
  final String label;
  final String? description;
  final bool showChevron;
  final bool isError;
  final VoidCallback? onTap;

  const SettingsListItem({
    super.key,
    this.icon,
    required this.label,
    this.description,
    this.showChevron = true,
    this.isError = false,
    this.onTap,
  });

  @override
  State<SettingsListItem> createState() => _SettingsListItemState();
}

class _SettingsListItemState extends State<SettingsListItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final labelColor =
        widget.isError ? const Color(0xFFE20000) : const Color(0xFF434343);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _pressed
            ? Colors.black.withOpacity(0.05) // 👈 5% black overlay
            : Colors.transparent,
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.only(
          top: 16,
          bottom: 16,
          right: 16,
        ),
        child: Row(
          children: [

            if (widget.icon != null) ...[
              PhosphorIcon(
                widget.icon!(PhosphorIconsStyle.bold),
                size: 24,
                color: const Color(0xFF949494),
              ),
              const SizedBox(width: 8),
            ],

            Expanded(
              child: Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  letterSpacing: -0.5,
                  color: labelColor,
                ),
              ),
            ),

            if (widget.description != null) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  widget.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    letterSpacing: -0.5,
                    color: const Color(0xFF787575),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            if (widget.showChevron)
              PhosphorIcon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                size: 20,
                color: const Color(0xFFF70F3D),
              ),
          ],
        ),
      ),
    );
  }
}