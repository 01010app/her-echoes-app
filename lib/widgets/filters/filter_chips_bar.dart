import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Barra de filtros horizontal para Show All.
///
/// Specs exactas:
/// - Contenedor: 32px alto, fondo #E9E9E9
/// - Texto: Inter 12px, line-height 14px, letter-spacing 9% (1.08px)
/// - Sin gap entre botones
/// - Chip activo: 24px alto exacto (padding vertical 5 + line-height 14 + padding vertical 5)
///   padding horizontal 16px, fondo #F70F3D
/// - Chip inactivo: mismo padding, fondo transparente (se apoya en el fondo
///   del contenedor #E9E9E9), así todos los chips miden 24px de alto y quedan
///   centrados dentro del contenedor de 32px (4px de margen arriba/abajo).
class FilterChipsBar extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;
  final String Function(String filter)? filterLabelBuilder;

  const FilterChipsBar({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
    this.filterLabelBuilder,
  });

  static const double _containerHeight = 32;
  static const Color _containerBg = Color(0xFFE9E9E9);
  static const Color _activeBg = Color(0xFFF70F3D);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: _containerHeight,
          color: _containerBg,
          alignment: Alignment.centerLeft,
          // FIX sesión 2026-08-18: antes el margen de 4px arriba/abajo del
          // chip activo dependía de que Align calculara el alto exacto del
          // texto (padding 5+5 + line-height 14 = 24, centrado en 32).
          // Las métricas reales de Inter no siempre coinciden con el
          // line-height teórico, así que el margen calculado variaba y a
          // veces desaparecía. Ahora se fuerza el margen con padding
          // explícito: 32 - 4 - 4 = 24px exactos, siempre.
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: filters.map((filter) {
                final isActive = filter == selected;
                final label = filterLabelBuilder != null
                    ? filterLabelBuilder!(filter)
                    : filter;
                return _FilterChip(
                  label: label,
                  isActive: isActive,
                  onTap: () => onSelected(filter),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        // 5px arriba + 14px line-height + 5px abajo = 24px exactos
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? FilterChipsBar._activeBg : Colors.transparent,
          // radius = altura/2 (24px / 2 = 12px) → píldora perfecta
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            height: 14 / 12, // line-height 14px sobre fuente 12px
            letterSpacing: 12 * 0.01, // 9% de interletrado
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF6B6B6B),
          ),
        ),
      ),
    );
  }
}