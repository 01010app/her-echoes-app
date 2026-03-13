import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/subscription_provider.dart';
import '../../core/favorites_provider.dart';
import '../../core/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_shapes.dart';
import 'pro_badge.dart';
import 'wildcard_badge.dart';

// ─── Particle model ───────────────────────────────────────────────────────────

class _Particle {
  double x, y, vx, vy, size, alpha, maxLife, life, twinkle, twinkleSpeed;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.alpha,
    required this.life,
    required this.twinkle,
    required this.twinkleSpeed,
    required this.color,
  }) : maxLife = life;
}

// ─── Painter ──────────────────────────────────────────────────────────────────

class _FairyDustPainter extends CustomPainter {
  final List<_Particle> particles;

  _FairyDustPainter(this.particles);

  void _drawStar(Canvas canvas, Paint paint, double cx, double cy, double outerR, double innerR) {
    const spikes = 4;
    double rot = -pi / 2;
    const step = pi / spikes;
    final path = Path();
    path.moveTo(cx + cos(rot) * outerR, cy + sin(rot) * outerR);
    for (int i = 0; i < spikes; i++) {
      rot += step;
      path.lineTo(cx + cos(rot) * innerR, cy + sin(rot) * innerR);
      rot += step;
      path.lineTo(cx + cos(rot) * outerR, cy + sin(rot) * outerR);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final progress = p.life / p.maxLife;
      final fade = progress < 0.3 ? progress / 0.3 : 1.0;
      final twinkle = 0.5 + 0.5 * sin(p.twinkle);
      final alpha = (p.alpha * fade * twinkle).clamp(0.0, 1.0);
      final r = p.size * (0.7 + 0.3 * twinkle);

      final paint = Paint()
        ..color = p.color.withOpacity(alpha)
        ..style = PaintingStyle.fill;

      _drawStar(canvas, paint, p.x, p.y, r, r * 0.4);
    }
  }

  @override
  bool shouldRepaint(_FairyDustPainter old) => true;
}

// ─── Animated overlay ─────────────────────────────────────────────────────────

class _FairyDustOverlay extends StatefulWidget {
  final double width;
  final double height;

  const _FairyDustOverlay({required this.width, required this.height});

  @override
  State<_FairyDustOverlay> createState() => _FairyDustOverlayState();
}

class _FairyDustOverlayState extends State<_FairyDustOverlay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<_Particle> _particles = [];
  final Random _rnd = Random();

  static const _colors = [
    Color(0xFFFFE066),
    Color(0xFFFFB3DE),
    Color(0xFFB8F0FF),
    Color(0xFFFFFFFF),
    Color(0xFFFFD6A5),
    Color(0xFFC9B1FF),
  ];

  double _rand(double a, double b) => a + _rnd.nextDouble() * (b - a);

  void _spawn() {
    final w = widget.width;
    final zoneH = widget.height * 0.38;
    _particles.add(_Particle(
      x: _rand(0, w),
      y: _rand(0, zoneH),
      vx: _rand(-0.3, 0.3),
      vy: _rand(-0.15, 0.4),
      size: _rand(1.5, 3.2),
      alpha: _rand(0.5, 1.0),
      life: _rand(55, 130),
      twinkle: _rand(0, pi * 2),
      twinkleSpeed: _rand(0.05, 0.12),
      color: _colors[_rnd.nextInt(_colors.length)],
    ));
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      setState(() {
        if (_particles.length < 55) _spawn();
        for (final p in _particles) {
          p.x += p.vx;
          p.y += p.vy;
          p.life--;
          p.twinkle += p.twinkleSpeed;
        }
        _particles.removeWhere((p) => p.life <= 0);
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FairyDustPainter(List.from(_particles)),
      size: Size(widget.width, widget.height),
    );
  }
}

// ─── HomeMiniCard ─────────────────────────────────────────────────────────────

class HomeMiniCard extends StatelessWidget {
  final String fullName;
  final String profession;
  final String imagePath;
  final bool isPro;
  final bool isWildcard;
  final VoidCallback onTap;
  final Map<String, dynamic>? woman;

  const HomeMiniCard({
    super.key,
    required this.fullName,
    required this.profession,
    required this.imagePath,
    required this.onTap,
    this.isPro = false,
    this.isWildcard = false,
    this.woman,
  });

  @override
  Widget build(BuildContext context) {
    final userIsPro = context.watch<SubscriptionProvider>().isPro;
    final isEnglish = context.watch<LanguageProvider>().isEnglish;
    final showProBadge = isPro && !userIsPro;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final womanId = woman?['woman_id']?.toString() ?? '';
    final isFav = womanId.isNotEmpty ? favoritesProvider.isFavorite(womanId) : false;

    const double cardSize = 156;

    return GestureDetector(
      onTap: onTap,
      child: Material(
        shape: AppShapes.card,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: cardSize,
          height: cardSize,
          child: Stack(
            children: [

              /// IMAGE
              Positioned(
                top: -24,
                left: 0,
                right: 0,
                bottom: 0,
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.high,
                ),
              ),

              /// GRADIENT
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 62,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color.fromRGBO(0, 0, 0, 0.8),
                        Color.fromRGBO(0, 0, 0, 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              /// FAIRY DUST — solo wildcard, solo tercio superior
              if (isWildcard)
                Positioned.fill(
                  child: IgnorePointer(
                    child: _FairyDustOverlay(
                      width: cardSize,
                      height: cardSize,
                    ),
                  ),
                ),

              /// TEXT
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 14,
                        height: 1.4,
                        letterSpacing: -0.14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      profession,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 11,
                        height: 1.4,
                        color: AppColors.textSecondary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              /// WILDCARD BADGE
              if (isWildcard)
                Positioned(
                  top: 8,
                  left: 8,
                  child: WildcardBadge(isEnglish: isEnglish),
                ),

              /// PRO BADGE
              if (showProBadge)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: ProBadge(),
                ),

              /// FAVORITE BUTTON
              if (userIsPro && woman != null && !isWildcard)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => favoritesProvider.toggle(woman!),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isFav
                            ? const Color(0xFFF70F3D)
                            : Colors.black.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav
                            ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                            : PhosphorIcons.heart(PhosphorIconsStyle.regular),
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}