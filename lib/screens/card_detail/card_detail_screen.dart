import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/language_provider.dart';
import '../../core/subscription_provider.dart';
import '../../core/favorites_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/modals/upsell_modal_free.dart';
import '../../widgets/system/app_button.dart';

// ─── E-Card widget (se renderiza offscreen) ────────────────────────────────

class _ShareECard extends StatelessWidget {
  final Map<String, dynamic> woman;
  final bool isEnglish;
  final ui.Image? photo;

  const _ShareECard({
    required this.woman,
    required this.isEnglish,
    this.photo,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 1080;
    final name = (woman['full_name'] ?? '') as String;
    final tag1 = isEnglish ? (woman['pro-tag01_en'] ?? '') : (woman['pro-tag01_es'] ?? '');
    final tag2 = isEnglish ? (woman['pro-tag02_en'] ?? '') : (woman['pro-tag02_es'] ?? '');
    final profession = [tag1, tag2].where((t) => t.toString().isNotEmpty).join(' · ');
    final quote = isEnglish
        ? (woman['quote_text_en'] ?? '')
        : (woman['quote_text_es'] ?? '');
    final isWildcard = woman['_is_wildcard'] == true;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [

          // FOTO
          if (photo != null)
            Positioned.fill(
              child: RawImage(
                image: photo,
                fit: BoxFit.cover,
              ),
            )
          else
            Positioned.fill(
              child: Container(color: const Color(0xFF1A0A30)),
            ),

          // DEGRADADO rojo HerEchoes
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.12),
                    Color.fromRGBO(80, 0, 15, 0.55),
                    Color.fromRGBO(183, 0, 30, 0.92),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // BADGE WILDCARD
          if (isWildcard)
            Positioned(
              top: 48,
              left: 48,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xCCF70F3D),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Text(
                  isEnglish ? '✦ Special' : '✦ Especial',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

          // CONTENIDO inferior
          Positioned(
            left: 64,
            right: 64,
            bottom: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                // QUOTE
                if (quote.toString().isNotEmpty) ...[
                  Text(
                    '"$quote"',
                    style: GoogleFonts.lora(
                      fontSize: 38,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withOpacity(0.92),
                      height: 1.45,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 32),
                ],

                // NOMBRE
                Text(
                  name,
                  style: GoogleFonts.lora(
                    fontSize: 72,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.05,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // PROFESIÓN
                Text(
                  profession,
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.78),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 40),

                // LOGO
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF70F3D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HerEchoes',
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'herechoes.app',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            color: Colors.white.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CardDetailScreen ─────────────────────────────────────────────────────────

class CardDetailScreen extends StatefulWidget {
  final Map<String, dynamic> woman;

  const CardDetailScreen({
    super.key,
    required this.woman,
  });

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  int _selectedTab = 0;
  final ScrollController _scrollController = ScrollController();
  double _imageHeight = 520;
  final GlobalKey _menuKey = GlobalKey();
  OverlayEntry? _menuOverlay;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      setState(() {
        _imageHeight = (520 - offset).clamp(320.0, 520.0);
      });
    });
  }

  @override
  void dispose() {
    _closeMenu();
    _scrollController.dispose();
    super.dispose();
  }

  String get imageUrl {
    final rawId = (widget.woman['image_card_ID'] ?? '').toString();
    if (rawId.startsWith('http')) return rawId;
    return "https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/$rawId.webp";
  }

  bool get isEnglish => context.read<LanguageProvider>().isEnglish;

  // ─── Share ───────────────────────────────────────────────────────────────

  Future<void> _shareCard() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      // 1. Descargar foto
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(imageUrl));
      final response = await request.close();
      final bytes = Uint8List.fromList(await response.expand((b) => b).toList());

      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final photo = frame.image;

      const double size = 1080;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

      // 2. Foto con crop tipo minicard:
      //    - ocupa 100% ancho
      //    - se cropea verticalmente (imagen más alta que el canvas)
      //    - se sube un poco (-24px proporcional)
      final double photoW = photo.width.toDouble();
      final double photoH = photo.height.toDouble();
      final double scale = size / photoW; // escala para que ancho = 1080
      final double scaledH = photoH * scale;
      const double topOffset = -24.0 * (size / 393); // proporcional a 393px base
      final double srcW = photoW;
      final double srcH = photoW; // cuadrado del ancho
      final double srcTop = ((photoH - srcH) * 0.3).clamp(0, photoH - srcH); // crop desde arriba

      canvas.drawImageRect(
        photo,
        Rect.fromLTWH(0, srcTop, srcW, srcH),
        Rect.fromLTWH(0, topOffset, size, size - topOffset),
        Paint(),
      );

      // 3. Degradado rojo HerEchoes
      final gradientPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(0, 0, 0, 0.12),
            Color.fromRGBO(80, 0, 15, 0.55),
            Color.fromRGBO(183, 0, 30, 0.92),
          ],
          stops: [0.0, 0.45, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size, size));
      canvas.drawRect(Rect.fromLTWH(0, 0, size, size), gradientPaint);

      final w = widget.woman;
      final eng = isEnglish;
      final name = (w['full_name'] ?? '') as String;
      final tag1 = eng ? (w['pro-tag01_en'] ?? '') : (w['pro-tag01_es'] ?? '');
      final tag2 = eng ? (w['pro-tag02_en'] ?? '') : (w['pro-tag02_es'] ?? '');
      final profession = [tag1, tag2].where((t) => t.toString().isNotEmpty).join(' · ');
      final quote = (eng ? w['quote_text_en'] : w['quote_text_es'])?.toString() ?? '';

      // 4. Textos — empezamos desde abajo
      const double marginLeft = 64;
      const double marginBottom = 8;
      const double logoH = 48 * (size / 148); // altura proporcional del SVG (viewBox 148x48)
      const double logoW = size * 0.25;        // 20% del ancho
      const double logoY = size - marginBottom - logoH;

      double currentY = logoY - 40;

      // Profesión
      currentY = _drawTextBlock(canvas, profession,
        x: marginLeft, y: currentY,
        fontSize: 34, color: Colors.white.withOpacity(0.9),
        maxWidth: size - marginLeft * 2,
        lineHeight: 1.3,
        goUp: true,
      );
      currentY -= 16;

      // Nombre
      currentY = _drawTextBlock(canvas, name,
        x: marginLeft, y: currentY,
        fontSize: 78, bold: true, color: Colors.white,
        maxWidth: size - marginLeft * 2,
        lineHeight: 1.1,
        goUp: true,
      );
      currentY -= 40;

      // Quote
      if (quote.isNotEmpty) {
        _drawTextBlock(canvas, '"$quote"',
          x: marginLeft, y: currentY,
          fontSize: 40, italic: true, color: Colors.white.withOpacity(0.92),
          maxWidth: size - marginLeft * 2,
          lineHeight: 1.45,
          goUp: true,
        );
      }

      // 5. Logo SVG blanco en esquina inferior izquierda
      _drawHerEchoesLogo(canvas, x: marginLeft, y: logoY, width: logoW);

      // 6. Convertir a PNG
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // 7. Guardar y compartir
      final dir = await getTemporaryDirectory();
      final womanId = (w['woman_id'] ?? 'herechoes').toString();
      final file = File('${dir.path}/herechoes_$womanId.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: eng
            ? 'Discover her story on HerEchoes 👉 https://callmehector.cl/apps/herechoes/?ref=share'
            : 'Descubre su historia en HerEchoes 👉 https://callmehector.cl/apps/herechoes/?ref=share',
      );
    } catch (e) {
      debugPrint('Share error: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  // Dibuja texto y retorna la Y superior del bloque (para apilar hacia arriba)
  double _drawTextBlock(
    Canvas canvas,
    String text, {
    required double x,
    required double y,
    required double fontSize,
    bool bold = false,
    bool italic = false,
    required Color color,
    required double maxWidth,
    required double lineHeight,
    bool goUp = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          color: color,
          height: lineHeight,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 4,
    )..layout(maxWidth: maxWidth);

    final drawY = goUp ? y - tp.height : y;
    tp.paint(canvas, Offset(x, drawY));
    return drawY;
  }

  void _drawHerEchoesLogo(Canvas canvas, {
    required double x,
    required double y,
    required double width,
  }) {
    // SVG viewBox: 148 x 48
    const double svgW = 148;
    const double svgH = 48;
    final double scale = width / svgW;
    final double height = svgH * scale;

    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Path 1 — corazón interior
    final p1 = Path();
    p1.fillType = PathFillType.evenOdd;
    p1.addPath(_parseSvgPath('M34.1652 23.2727C35.7411 23.2727 37.2524 23.8857 38.3667 24.9768C39.481 26.0679 40.107 27.5478 40.107 29.0909C40.107 35.7298 30.7741 40.3764 30.3738 40.5743C30.1674 40.6754 29.9397 40.7282 29.7089 40.7282C29.4781 40.7282 29.2504 40.6754 29.044 40.5743C28.6437 40.3765 19.3108 35.7298 19.3108 29.0909C19.3118 27.9096 19.6799 26.7565 20.3663 25.7851C21.0528 24.8136 22.0253 24.0697 23.1539 23.6524C24.2827 23.2352 25.5144 23.1645 26.6853 23.4494C27.8561 23.7342 28.9109 24.3612 29.7089 25.2472C30.2653 24.6264 30.951 24.1293 31.7195 23.7888C32.488 23.4483 33.3217 23.2723 34.1652 23.2727ZM34.1652 26.1819C33.3773 26.1819 32.6219 26.4886 32.0648 27.0341C31.525 27.5626 31.2142 28.2733 31.1953 29.0187L31.1939 29.127C31.1844 29.4997 31.029 29.8551 30.7592 30.1194C30.4806 30.3921 30.1029 30.5455 29.7089 30.5455C29.3149 30.5455 28.9372 30.3921 28.6586 30.1194C28.3887 29.8551 28.2334 29.4997 28.2239 29.127L28.2225 29.0187C28.2036 28.2734 27.8928 27.5626 27.3531 27.0341C26.796 26.4886 26.0405 26.1819 25.2526 26.1819C24.4646 26.1819 23.7092 26.4886 23.1521 27.0341C22.5949 27.5797 22.2817 28.3194 22.2817 29.0909C22.2817 32.76 27.1484 36.2072 29.7089 37.6236C32.2694 36.2091 37.1361 32.7618 37.1361 29.0909C37.1361 28.3194 36.8229 27.5797 36.2658 27.0341C35.7086 26.4886 34.9532 26.1819 34.1652 26.1819Z'), Offset.zero);
    canvas.drawPath(p1, paint);

    // Path 2 — calendario exterior
    final p2 = Path();
    p2.fillType = PathFillType.evenOdd;
    p2.addPath(_parseSvgPath('M26.738 0C27.132 0 27.5097 0.153348 27.7883 0.426128C28.0669 0.698908 28.2234 1.06881 28.2234 1.45457V2.90906H32.6798C33.4677 2.90906 34.2232 3.21584 34.7803 3.7614C35.3375 4.30696 35.6507 5.04668 35.6507 5.8182V13.0909H37.1361V11.6364C37.1361 11.2506 37.2927 10.8807 37.5713 10.608C37.8499 10.3352 38.2276 10.1818 38.6216 10.1818C39.0155 10.1818 39.3933 10.3352 39.6718 10.608C39.9504 10.8807 40.107 11.2506 40.107 11.6364V13.0909H44.5633C45.3513 13.0909 46.1067 13.3976 46.6639 13.9431C47.221 14.4887 47.5342 15.2285 47.5342 16V45.0909C47.5342 45.8625 47.221 46.6022 46.6639 47.1477C46.1067 47.6933 45.3513 48 44.5633 48H14.8544C14.0665 48 13.3111 47.6933 12.754 47.1477C12.1968 46.6022 11.8836 45.8625 11.8836 45.0909V37.8182H2.97089C2.18297 37.8182 1.42757 37.5115 0.870424 36.9659C0.31328 36.4204 6.88847e-06 35.6806 0 34.9091V5.8182C0 5.04666 0.313274 4.30696 0.870424 3.7614C1.42757 3.21584 2.18296 2.90906 2.97089 2.90906H7.42722V1.45457C7.42722 1.06881 7.58382 0.698908 7.86239 0.426128C8.14096 0.153348 8.5187 0 8.91267 0C9.30663 0 9.68437 0.153348 9.96295 0.426128C10.2415 0.698908 10.3981 1.06881 10.3981 1.45457V2.90906H25.2526V1.45457C25.2526 1.06881 25.4092 0.698908 25.6877 0.426128C25.9663 0.153348 26.344 0 26.738 0ZM15.8447 16C15.2978 16 14.8545 16.4341 14.8544 16.9697V44.1212C14.8545 44.6568 15.2978 45.0909 15.8447 45.0909H43.5731C44.12 45.0909 44.5633 44.6568 44.5633 44.1212V16.9697C44.5633 16.4341 44.12 16 43.5731 16H40.107V17.4545C40.107 17.8403 39.9504 18.2102 39.6718 18.483C39.3933 18.7557 39.0155 18.9091 38.6216 18.9091C38.2276 18.9091 37.8499 18.7557 37.5713 18.483C37.2927 18.2102 37.1361 17.8403 37.1361 17.4545V16H22.2817V17.4545C22.2817 17.8403 22.1251 18.2102 21.8465 18.483C21.5679 18.7557 21.1902 18.9091 20.7962 18.9091C20.4023 18.9091 20.0245 18.7557 19.7459 18.483C19.4674 18.2102 19.3108 17.8403 19.3108 17.4545V16H15.8447ZM2.97089 34.9091H11.8836V26.8405C9.5938 24.8418 7.42722 22.1071 7.42722 18.9091C7.4282 17.7278 7.79632 16.5747 8.48277 15.6032C9.16927 14.6318 10.1417 13.8879 11.2704 13.4707C12.2151 13.1215 13.1146 13.0856 14.2249 13.0888C14.4402 13.0894 14.6411 13.0909 14.8544 13.0909H19.3108V11.6364C19.3108 11.2506 19.4674 10.8807 19.7459 10.608C20.0245 10.3352 20.4023 10.1818 20.7962 10.1818C21.1902 10.1818 21.5679 10.3352 21.8465 10.608C22.1251 10.8807 22.2817 11.2506 22.2817 11.6364V13.0909H32.6798V5.8182H28.2234V7.27268C28.2234 7.65845 28.0668 8.02835 27.7883 8.30113C27.5097 8.57391 27.132 8.72726 26.738 8.72726C26.344 8.72726 25.9663 8.57391 25.6877 8.30113C25.4092 8.02835 25.2526 7.65845 25.2526 7.27268V5.8182H10.3981V7.27268C10.3981 7.65845 10.2415 8.02835 9.96295 8.30113C9.68437 8.57391 9.30663 8.72726 8.91267 8.72726C8.5187 8.72726 8.14096 8.57391 7.86239 8.30113C7.58382 8.02835 7.42722 7.65845 7.42722 7.27268V5.8182H2.97089V34.9091ZM11.8836 16.3901C11.6607 16.5161 11.4537 16.671 11.2685 16.8523C10.7114 17.3978 10.3981 18.1375 10.3981 18.9091C10.3981 20.1945 10.9972 21.4512 11.8836 22.6042V16.3901Z'), Offset.zero);
    canvas.drawPath(p2, paint);

    // Paths del texto "echoes" y letras
    final textPaths = [
      // e (primera)
      'M60.921 24.4939C62.1898 24.4939 63.3234 24.7587 64.3218 25.2882C65.341 25.7973 66.1834 26.4796 66.849 27.3349C67.5146 28.1903 67.993 29.178 68.2842 30.2981C68.5962 31.3978 68.6794 32.5383 68.5338 33.7195H56.6777C56.6777 34.3305 56.761 34.9211 56.9274 35.4913C57.1146 36.0616 57.3849 36.5606 57.7385 36.9883C58.0921 37.4159 58.5394 37.7622 59.0802 38.0269C59.621 38.2713 60.2658 38.3935 61.0146 38.3935C62.0546 38.3935 62.8865 38.1796 63.5105 37.7519C64.1553 37.3039 64.6338 36.642 64.9458 35.7663H68.3154C68.1282 36.6216 67.8057 37.3854 67.3481 38.0574C66.8905 38.7295 66.3394 39.2998 65.6946 39.7682C65.0498 40.2162 64.3217 40.5522 63.5105 40.7763C62.7201 41.0207 61.8881 41.1429 61.0146 41.1429C59.7458 41.1429 58.6225 40.9392 57.6449 40.5319C56.6673 40.1245 55.8353 39.5544 55.1489 38.8212C54.4833 38.088 53.9738 37.2123 53.6202 36.194C53.2874 35.1757 53.1209 34.0556 53.1209 32.8337C53.1209 31.7136 53.2977 30.6545 53.6513 29.6566C54.0257 28.6383 54.5457 27.7524 55.2113 26.9988C55.8977 26.2249 56.7193 25.6139 57.6761 25.1659C58.6329 24.7179 59.7146 24.4939 60.921 24.4939ZM60.921 27.2432C60.297 27.2432 59.7249 27.3552 59.2049 27.5792C58.7057 27.7829 58.2689 28.0782 57.8945 28.4652C57.5409 28.8317 57.2498 29.2696 57.021 29.7787C56.813 30.2879 56.6985 30.8378 56.6777 31.4284H64.9769C64.9353 30.8786 64.8106 30.349 64.6026 29.8399C64.4154 29.3308 64.145 28.8928 63.7914 28.5262C63.4586 28.1393 63.0426 27.8338 62.5434 27.6098C62.065 27.3654 61.5242 27.2432 60.921 27.2432Z',
      // c
      'M76.8537 24.4939C77.7897 24.4939 78.6738 24.6161 79.5058 24.8605C80.3586 25.0845 81.1074 25.4307 81.7522 25.8991C82.4178 26.3675 82.9586 26.9581 83.3746 27.6709C83.7906 28.3837 84.0402 29.2289 84.1234 30.2064H80.5665C80.4209 29.2289 80.0153 28.4958 79.3498 28.007C78.705 27.4979 77.8833 27.2432 76.8849 27.2432C76.4273 27.2432 75.9385 27.3247 75.4185 27.4877C74.8985 27.6302 74.4201 27.9153 73.9834 28.343C73.5466 28.7503 73.1825 29.3307 72.8913 30.0842C72.6001 30.8174 72.4545 31.7848 72.4545 32.9863C72.4545 33.638 72.5274 34.2898 72.673 34.9415C72.8394 35.5932 73.0889 36.1736 73.4217 36.6828C73.7753 37.1919 74.2225 37.6094 74.7633 37.9353C75.3041 38.2407 75.9593 38.3935 76.7289 38.3935C77.7689 38.3935 78.6218 38.0779 79.2874 37.4465C79.9738 36.8152 80.4001 35.9292 80.5665 34.7888H84.1234C83.7906 36.8457 82.9897 38.424 81.7209 39.5238C80.4729 40.6031 78.8089 41.1429 76.7289 41.1429C75.4601 41.1429 74.337 40.9392 73.3594 40.5319C72.4026 40.1042 71.5913 39.534 70.9257 38.8212C70.2601 38.088 69.7505 37.2224 69.3969 36.2245C69.0641 35.2266 68.8977 34.1472 68.8977 32.9863C68.8977 31.8051 69.0641 30.6952 69.3969 29.6566C69.7297 28.6179 70.2289 27.7219 70.8945 26.9683C71.5601 26.1944 72.3818 25.5936 73.3594 25.1659C74.3578 24.7179 75.5225 24.4939 76.8537 24.4939Z',
      // o
      'M109.205 24.4939C110.494 24.4939 111.638 24.7077 112.637 25.1354C113.656 25.5427 114.509 26.1129 115.195 26.8461C115.902 27.5792 116.433 28.455 116.786 29.4733C117.161 30.4916 117.348 31.6015 117.348 32.8031C117.348 34.025 117.161 35.1451 116.786 36.1634C116.433 37.1817 115.902 38.0574 115.195 38.7906C114.509 39.5238 113.656 40.1042 112.637 40.5319C111.638 40.9392 110.494 41.1429 109.205 41.1429C107.915 41.1429 106.761 40.9392 105.741 40.5319C104.743 40.1042 103.89 39.5238 103.183 38.7906C102.497 38.0574 101.966 37.1817 101.592 36.1634C101.238 35.1451 101.061 34.025 101.061 32.8031C101.061 31.6015 101.238 30.4916 101.592 29.4733C101.966 28.455 102.497 27.5792 103.183 26.8461C103.89 26.1129 104.743 25.5427 105.741 25.1354C106.761 24.7077 107.915 24.4939 109.205 24.4939ZM109.205 27.2432C108.414 27.2432 107.728 27.4061 107.145 27.732C106.563 28.0578 106.085 28.4856 105.71 29.0151C105.336 29.5242 105.055 30.1149 104.868 30.7869C104.701 31.459 104.618 32.131 104.618 32.8031C104.618 33.4955 104.701 34.1778 104.868 34.8498C105.055 35.5015 105.336 36.0922 105.71 36.6217C106.085 37.1512 106.563 37.5788 107.145 37.9047C107.728 38.2305 108.414 38.3935 109.205 38.3935C109.995 38.3935 110.681 38.2305 111.264 37.9047C111.846 37.5788 112.325 37.1512 112.699 36.6217C113.073 36.0922 113.344 35.5015 113.51 34.8498C113.697 34.1778 113.791 33.4955 113.791 32.8031C113.791 32.131 113.697 31.459 113.51 30.7869C113.344 30.1149 113.073 29.5242 112.699 29.0151C112.325 28.4856 111.846 28.0578 111.264 27.732C110.681 27.4061 109.995 27.2432 109.205 27.2432Z',
      // e (segunda)
      'M125.765 24.4939C127.034 24.4939 128.167 24.7586 129.166 25.2882C130.185 25.7973 131.027 26.4796 131.693 27.3349C132.358 28.1903 132.837 29.178 133.128 30.2981C133.44 31.3978 133.523 32.5383 133.378 33.7195H121.522C121.522 34.3305 121.605 34.9211 121.771 35.4913C121.958 36.0616 122.229 36.5606 122.582 36.9883C122.936 37.4159 123.383 37.7622 123.924 38.0269C124.465 38.2713 125.11 38.3935 125.858 38.3935C126.898 38.3935 127.73 38.1796 128.354 37.7519C128.999 37.3039 129.478 36.642 129.79 35.7663H133.159C132.972 36.6216 132.65 37.3854 132.192 38.0574C131.734 38.7295 131.183 39.2998 130.538 39.7682C129.894 40.2162 129.166 40.5522 128.354 40.7763C127.564 41.0207 126.732 41.1429 125.858 41.1429C124.59 41.1429 123.466 40.9392 122.489 40.5319C121.511 40.1245 120.679 39.5544 119.993 38.8212C119.327 38.088 118.818 37.2123 118.464 36.194C118.131 35.1757 117.965 34.0556 117.965 32.8337C117.965 31.7136 118.142 30.6545 118.495 29.6566C118.87 28.6383 119.39 27.7524 120.055 26.9988C120.742 26.2249 121.563 25.6139 122.52 25.1659C123.477 24.7179 124.558 24.4939 125.765 24.4939ZM125.765 27.2432C125.141 27.2432 124.569 27.3552 124.049 27.5792C123.55 27.7829 123.113 28.0782 122.738 28.4652C122.385 28.8317 122.094 29.2696 121.865 29.7787C121.657 30.2879 121.542 30.8378 121.522 31.4284H129.821C129.779 30.8786 129.654 30.3491 129.446 29.8399C129.259 29.3308 128.989 28.8928 128.635 28.5262C128.302 28.1393 127.886 27.8338 127.387 27.6098C126.909 27.3654 126.368 27.2432 125.765 27.2432Z',
      // s
      'M140.73 24.4939C141.562 24.4939 142.353 24.5855 143.102 24.7688C143.871 24.9317 144.558 25.2067 145.161 25.5937C145.785 25.9806 146.294 26.4897 146.69 27.1211C147.106 27.732 147.366 28.4754 147.47 29.3511H143.757C143.59 28.5161 143.195 27.956 142.571 27.6709C141.968 27.3858 141.271 27.2432 140.481 27.2432C140.231 27.2432 139.93 27.2636 139.576 27.3043C139.243 27.3451 138.921 27.4266 138.609 27.5487C138.318 27.6506 138.068 27.8135 137.86 28.0375C137.652 28.2412 137.548 28.5161 137.548 28.8623C137.548 29.29 137.694 29.6362 137.985 29.901C138.297 30.1658 138.692 30.3897 139.17 30.573C139.67 30.7359 140.231 30.8786 140.855 31.0008C141.479 31.1229 142.124 31.2553 142.79 31.3978C143.434 31.5404 144.069 31.7135 144.693 31.9172C145.317 32.1208 145.868 32.3958 146.346 32.742C146.846 33.0882 147.241 33.5261 147.532 34.0556C147.844 34.5851 148 35.2368 148 36.0107C148 36.9475 147.782 37.7418 147.345 38.3935C146.908 39.0452 146.336 39.5747 145.629 39.982C144.942 40.3893 144.173 40.6847 143.32 40.8679C142.467 41.0512 141.625 41.1429 140.793 41.1429C139.774 41.1429 138.827 41.0309 137.954 40.8069C137.101 40.5828 136.352 40.2467 135.707 39.7987C135.083 39.3303 134.584 38.7601 134.21 38.088C133.856 37.3956 133.669 36.5809 133.648 35.6441H137.205C137.309 36.6624 137.704 37.3752 138.39 37.7825C139.077 38.1898 139.898 38.3935 140.855 38.3935C141.188 38.3935 141.562 38.3731 141.978 38.3323C142.415 38.2713 142.821 38.1695 143.195 38.0269C143.57 37.8844 143.871 37.6807 144.1 37.4159C144.35 37.1308 144.464 36.7642 144.443 36.3162C144.422 35.8681 144.256 35.5015 143.944 35.2164C143.632 34.9313 143.226 34.7073 142.727 34.5443C142.249 34.3611 141.698 34.2083 141.074 34.0861C140.45 33.9639 139.815 33.8316 139.17 33.689C138.505 33.5464 137.86 33.3733 137.236 33.1697C136.633 32.966 136.082 32.6911 135.582 32.3448C135.104 31.9986 134.719 31.5608 134.428 31.0312C134.137 30.4814 133.991 29.8093 133.991 29.0151C133.991 28.1597 134.199 27.4469 134.615 26.8767C135.052 26.2861 135.593 25.8176 136.238 25.4714C136.903 25.1048 137.631 24.8503 138.422 24.7077C139.233 24.5652 140.002 24.4939 140.73 24.4939Z',
      // h
      'M89.0113 26.9988H89.0737C89.5105 26.286 90.1553 25.6955 91.0081 25.2271C91.8817 24.7383 92.8489 24.4939 93.9097 24.4939C95.6777 24.4939 97.0714 24.9419 98.0906 25.838C99.1098 26.7341 99.6193 28.0782 99.6193 29.8704V40.7152H96.0625V30.7869C96.0209 29.5446 95.7506 28.6485 95.2514 28.0986C94.7522 27.5283 93.9721 27.2432 92.9113 27.2432C92.3081 27.2432 91.7673 27.3552 91.2889 27.5792C90.8105 27.7829 90.4049 28.0782 90.0721 28.4652C89.7393 28.8317 89.4793 29.2696 89.2921 29.7787C89.1049 30.2879 89.0113 30.8276 89.0113 31.3978V40.7152H85.4545V18.9035H89.0113V26.9988Z',
      // "her" parte superior: e
      'M70.4643 9.96582C71.4659 9.96582 72.3386 10.1569 73.0822 10.5391C73.8259 10.9066 74.433 11.4064 74.9034 12.0385C75.3891 12.6707 75.7381 13.391 75.9506 14.1995C76.163 15.008 76.2389 15.8533 76.1782 16.7354H67.687C67.7326 17.7497 67.9981 18.4847 68.4838 18.9404C68.9694 19.3961 69.6675 19.624 70.5781 19.624C71.2307 19.624 71.7922 19.4696 72.2627 19.1609C72.7331 18.8375 73.0215 18.4994 73.1277 18.1466H75.9733C75.518 19.5137 74.8199 20.4913 73.879 21.0794C72.938 21.6674 71.7998 21.9614 70.4643 21.9614C69.5385 21.9614 68.7038 21.8217 67.9602 21.5424C67.2166 21.2484 66.5867 20.8368 66.0708 20.3076C65.5548 19.7783 65.1525 19.1462 64.8642 18.4112C64.591 17.6762 64.4545 16.8677 64.4545 15.9856C64.4545 15.133 64.5986 14.3392 64.8869 13.6042C65.1753 12.8691 65.5851 12.237 66.1162 11.7078C66.6474 11.1639 67.2772 10.7376 68.0057 10.4289C68.7493 10.1202 69.5689 9.96583 70.4643 9.96582ZM70.3732 12.3252C69.8572 12.3252 69.4247 12.4134 69.0757 12.5898C68.7418 12.7515 68.4686 12.9573 68.2561 13.2073C68.0588 13.4572 67.9147 13.7218 67.8236 14.0011C67.7477 14.2804 67.7022 14.5303 67.687 14.7508H72.9456C72.7939 13.957 72.5207 13.3543 72.1261 12.9427C71.7467 12.531 71.1624 12.3252 70.3732 12.3252Z',
      // h de "her"
      'M55.2172 11.8622H55.2855C55.6952 11.2007 56.2189 10.7229 56.8563 10.4289C57.4937 10.1202 58.1159 9.96582 58.723 9.96582C59.588 9.96583 60.2937 10.0834 60.8401 10.3186C61.4016 10.5391 61.8417 10.8551 62.1604 11.2667C62.4791 11.6637 62.6992 12.1562 62.8206 12.7442C62.9572 13.3175 63.0254 13.957 63.0254 14.6626V21.6747H59.7928V15.2359C59.7928 14.2951 59.6411 13.5968 59.3376 13.1411C59.0341 12.6707 58.4953 12.4355 57.7213 12.4354C56.8411 12.4354 56.2037 12.6927 55.8091 13.2073C55.4145 13.7071 55.2172 14.5376 55.2172 15.699V21.6747H51.9846V5.9305H55.2172V11.8622Z',
      // r de "her"
      'M84.515 9.96582C84.7275 9.96582 84.9627 10.0025 85.2207 10.076V12.9867C85.069 12.9573 84.8869 12.9353 84.6744 12.9206C84.462 12.8912 84.257 12.8765 84.0598 12.8765C83.4679 12.8765 82.9671 12.9721 82.5573 13.1632C82.1475 13.3543 81.8137 13.6189 81.5557 13.957C81.3128 14.2804 81.1382 14.6626 81.032 15.1036C80.9258 15.5446 80.8727 16.0224 80.8727 16.5369V21.6747H77.6401V10.2745H80.7133V12.3914H80.7588C80.9106 12.0386 81.1155 11.7151 81.3735 11.4211C81.6315 11.1124 81.9274 10.8552 82.2613 10.6494C82.5952 10.4289 82.9519 10.2598 83.3313 10.1422C83.7107 10.0246 84.1052 9.96583 84.515 9.96582Z',
    ];

    for (final d in textPaths) {
      final p = Path();
      p.fillType = PathFillType.evenOdd;
      p.addPath(_parseSvgPath(d), Offset.zero);
      canvas.drawPath(p, paint);
    }

    canvas.restore();
  }

  Path _parseSvgPath(String d) {
    final path = Path();
    final RegExp cmd = RegExp(r'([MmLlHhVvCcSsQqTtAaZz])([^MmLlHhVvCcSsQqTtAaZz]*)');
    double cx = 0, cy = 0;

    for (final match in cmd.allMatches(d)) {
      final op = match.group(1)!;
      final raw = match.group(2)!.trim();
      final nums = raw.isEmpty
          ? <double>[]
          : raw.split(RegExp(r'[\s,]+(?=[-]?[0-9])|[\s,]+')).where((s) => s.isNotEmpty).map(double.parse).toList();

      switch (op) {
        case 'M':
          for (int i = 0; i + 1 < nums.length; i += 2) {
            cx = nums[i]; cy = nums[i + 1];
            i == 0 ? path.moveTo(cx, cy) : path.lineTo(cx, cy);
          }
        case 'm':
          for (int i = 0; i + 1 < nums.length; i += 2) {
            cx += nums[i]; cy += nums[i + 1];
            i == 0 ? path.moveTo(cx, cy) : path.lineTo(cx, cy);
          }
        case 'L':
          for (int i = 0; i + 1 < nums.length; i += 2) { cx = nums[i]; cy = nums[i+1]; path.lineTo(cx, cy); }
        case 'l':
          for (int i = 0; i + 1 < nums.length; i += 2) { cx += nums[i]; cy += nums[i+1]; path.lineTo(cx, cy); }
        case 'H': for (final x in nums) { cx = x; path.lineTo(cx, cy); }
        case 'h': for (final x in nums) { cx += x; path.lineTo(cx, cy); }
        case 'V': for (final y in nums) { cy = y; path.lineTo(cx, cy); }
        case 'v': for (final y in nums) { cy += y; path.lineTo(cx, cy); }
        case 'C':
          for (int i = 0; i + 5 < nums.length; i += 6) {
            cx = nums[i+4]; cy = nums[i+5];
            path.cubicTo(nums[i], nums[i+1], nums[i+2], nums[i+3], cx, cy);
          }
        case 'c':
          for (int i = 0; i + 5 < nums.length; i += 6) {
            path.cubicTo(cx+nums[i], cy+nums[i+1], cx+nums[i+2], cy+nums[i+3], cx+nums[i+4], cy+nums[i+5]);
            cx += nums[i+4]; cy += nums[i+5];
          }
        case 'Z': case 'z': path.close();
      }
    }
    return path;
  }

  void _drawText(
    Canvas canvas,
    String text, {
    required double x,
    required double y,
    required double fontSize,
    bool bold = false,
    bool italic = false,
    required Color color,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          color: color,
          height: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x, y));
  }

  double _drawTextMultiline(
    Canvas canvas,
    String text, {
    required double x,
    required double y,
    required double fontSize,
    bool bold = false,
    bool italic = false,
    required Color color,
    required double maxWidth,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          color: color,
          height: 1.15,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 4,
    )..layout(maxWidth: maxWidth);
    tp.paint(canvas, Offset(x, y));
    return y;
  }

  // ─── Upsell ──────────────────────────────────────────────────────────────

  void _showUpsell() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const UpsellModalFree(),
    );
  }

  void _showFavoriteConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.heart(PhosphorIconsStyle.fill),
                size: 28,
                color: const Color(0xFFF70F3D),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEnglish ? "Added to Favorites!" : "¡Añadido a Favoritas!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEnglish
                  ? "You can find it in your Favorites tab."
                  : "Puedes encontrarla en tu pestaña de Favoritas.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF777777),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: isEnglish ? "Continue" : "Continuar",
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Menu ─────────────────────────────────────────────────────────────────

  void _showMenu() {
    final isWildcard = widget.woman['_is_wildcard'] == true;
    final isPro = context.read<SubscriptionProvider>().isPro;
    final favoritesProvider = context.read<FavoritesProvider>();
    final womanId = widget.woman['woman_id']?.toString() ?? '';
    final isFav = womanId.isNotEmpty ? favoritesProvider.isFavorite(womanId) : false;

    final RenderBox button = _menuKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset pos = button.localToGlobal(Offset.zero, ancestor: overlay);

    const menuWidth = 280.0;
    final left = pos.dx + button.size.width - menuWidth;
    final top = pos.dy + button.size.height + 8;

    _menuOverlay = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeMenu,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              left: left,
              top: top,
              width: menuWidth,
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(50, 50, 93, 0.25),
                            offset: Offset(0, 50),
                            blurRadius: 100,
                            spreadRadius: -20,
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.3),
                            offset: Offset(0, 30),
                            blurRadius: 60,
                            spreadRadius: -30,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isWildcard) ...[
                              _menuRow(
                                icon: isFav
                                    ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                                    : PhosphorIcons.heart(PhosphorIconsStyle.bold),
                                label: isFav
                                    ? (isEnglish ? "Added to Favorites" : "Añadido a Favoritas")
                                    : (isEnglish ? "Add to Favorites" : "Añadir a Favoritas"),
                                onTap: () {
                                  _closeMenu();
                                  if (isPro) {
                                    favoritesProvider.toggle(widget.woman);
                                    if (!isFav) _showFavoriteConfirmation();
                                  } else {
                                    _showUpsell();
                                  }
                                },
                              ),
                              _menuDivider(),
                            ],
                            _menuRow(
                              icon: PhosphorIcons.shareNetwork(PhosphorIconsStyle.bold),
                              label: isEnglish ? "Share with friends" : "Compartir con amigos",
                              onTap: () {
                                _closeMenu();
                                _shareCard();
                              },
                            ),
                            _menuDivider(),
                            _menuRow(
                              icon: PhosphorIcons.warning(PhosphorIconsStyle.bold),
                              label: isEnglish ? "Report issue" : "Reportar problema",
                              subtitle: isEnglish
                                  ? "Incorrect info, copyright, deceased?"
                                  : "¿Info incorrecta, copyright, fallecida?",
                              onTap: () async {
                                  _closeMenu();
                                  final name = (widget.woman['full_name'] ?? '').toString();
                                  final id   = (widget.woman['woman_id'] ?? '').toString();
                                  final subject = Uri.encodeComponent(
                                      isEnglish ? 'Report issue: $name' : 'Reportar problema: $name');
                                  final body = Uri.encodeComponent(
                                      isEnglish
                                          ? 'Woman ID: $id\n\nDescribe the issue:\n'
                                          : 'ID: $id\n\nDescribe el problema:\n');
                                  final uri = Uri.parse(
                                      'mailto:herechoes.info@callmehector.cl?subject=$subject&body=$body');
                                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                                },
                              ),
                            ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_menuOverlay!);
  }

  void _closeMenu() {
    _menuOverlay?.remove();
    _menuOverlay = null;
  }

  Widget _menuDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: Colors.black.withOpacity(0.16),
      ),
    );
  }

  Widget _menuRow({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Icon(icon, size: 20, color: const Color(0xFF3C3C3C)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      height: 16 / 18,
                      letterSpacing: -0.5,
                      color: const Color(0xFF3C3C3C),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 16 / 12,
                        letterSpacing: -0.5,
                        color: const Color(0xFF5D5D5D),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final w = widget.woman;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHero(w),
          if (_imageHeight > 320) const SizedBox(height: 16),
          _buildTabs(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _selectedTab == 0 ? _buildBiography(w) : _buildLegacy(w),
                  _buildBottomActions(context),
                  SizedBox(height: MediaQuery.of(context).padding.bottom - 11),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(Map<String, dynamic> w) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          height: _imageHeight,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: _imageHeight <= 320
                ? BorderRadius.zero
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => Image.network(
                'https://raw.githubusercontent.com/01010app/her-echoes-app/main/images/cards/not_found.webp',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          height: _imageHeight,
          child: ClipRRect(
            borderRadius: _imageHeight <= 320
                ? BorderRadius.zero
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  isEnglish ? w['pro-tag01_en'] : w['pro-tag01_es'],
                  isEnglish ? w['pro-tag02_en'] : w['pro-tag02_es'],
                ].where((t) => (t ?? '').toString().isNotEmpty).join(' • '),
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                (w['full_name'] ?? '') as String,
                style: GoogleFonts.gloock(
                  color: Colors.white,
                  fontSize: 32,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold),
                size: 18,
                color: AppColors.accent,
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 16,
          child: GestureDetector(
            key: _menuKey,
            onTap: _showMenu,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.bold),
                size: 18,
                color: AppColors.accent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final isCollapsed = _imageHeight <= 320;
    return Container(
      height: 45,
      margin: EdgeInsets.only(
        left: isCollapsed ? 0 : 16,
        right: isCollapsed ? 0 : 16,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: isCollapsed ? BorderRadius.zero : BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTab(isEnglish ? "Biography" : "Biografía", 0),
          const SizedBox(width: 4),
          _buildTab(isEnglish ? "Legacy" : "Legado", 1),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (_selectedTab != index) setState(() => _selectedTab = index);
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFFE1002D).withOpacity(0.10),
          highlightColor: const Color(0xFFE1002D).withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 37,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  letterSpacing: 0,
                  color: isSelected
                      ? const Color(0xFFE1002D)
                      : const Color(0xFF6D6D6D),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventBlock(Map<String, dynamic> w) {
    final now = DateTime.now();
    final months = isEnglish
        ? ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
        : ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    final dateStr = "${months[now.month - 1]} ${now.day}, ${now.year}";
    final pastDate = w['past_date']?.toString() ?? '';
    final label = isEnglish ? "On $dateStr, $pastDate" : "En $dateStr, $pastDate";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.calendarDots(PhosphorIconsStyle.regular),
            size: 24,
            color: const Color(0xFFAB5666),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    letterSpacing: -0.5,
                    color: const Color(0xFFAB5666),
                  ),
                ),
                Text(
                  (isEnglish ? w['on_this_date_en'] : w['on_this_date_es']) ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    color: const Color(0xFFAB5666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioTag({
    required IconData icon,
    required String date,
    required String place,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFBF4F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: const Color(0xFFAB5666)),
              const SizedBox(width: 6),
              Text(
                date,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: const Color(0xFFAB5666),
                ),
              ),
            ],
          ),
        ),
        if (place.isNotEmpty)
          Text(
            place,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: const Color(0xFF555555),
            ),
          ),
      ],
    );
  }

  Widget _buildBiography(Map<String, dynamic> w) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          if ((w['on_this_date_en'] ?? '').isNotEmpty) _buildEventBlock(w),
          if ((w['birth_date'] ?? '').isNotEmpty)
            _buildBioTag(
              icon: PhosphorIcons.baby(PhosphorIconsStyle.regular),
              date: w['birth_date'] as String,
              place: w['birth_place'] as String? ?? '',
            ),
          const SizedBox(height: 8),
          ..._parseBlocks(isEnglish ? w['bio_en'] ?? '' : w['bio_es'] ?? ''),
          const SizedBox(height: 8),
          _buildBioTag(
            icon: PhosphorIcons.skull(PhosphorIconsStyle.regular),
            date: (w['death_date'] ?? '').toString().isNotEmpty
                ? w['death_date'] as String
                : (isEnglish ? 'Still alive' : 'Aún con vida'),
            place: w['death_place'] as String? ?? '',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLegacy(Map<String, dynamic> w) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          if ((w['quote_text_en'] ?? '').isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF4F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.quotes(PhosphorIconsStyle.bold),
                    size: 16,
                    color: const Color(0xFFAB5666),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      (isEnglish ? w['quote_text_en'] : w['quote_text_es']) ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: const Color(0xFFAB5666),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ..._parseBlocks(isEnglish ? w['legacy_en'] ?? '' : w['legacy_es'] ?? ''),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  List<Widget> _parseBlocks(String raw) {
    final widgets = <Widget>[];
    int cursor = 0;
    while (cursor < raw.length) {
      if (raw.startsWith('[S]', cursor)) {
        cursor += 3;
        final end = raw.indexOf(RegExp(r'\[S\]|\[P\]'), cursor);
        final text = (end == -1 ? raw.substring(cursor) : raw.substring(cursor, end)).trim();
        if (text.isNotEmpty) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(text, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
          ));
        }
        cursor = end == -1 ? raw.length : end;
      } else if (raw.startsWith('[P]', cursor)) {
        cursor += 3;
        final end = raw.indexOf(RegExp(r'\[S\]|\[P\]'), cursor);
        final text = (end == -1 ? raw.substring(cursor) : raw.substring(cursor, end)).trim();
        if (text.isNotEmpty) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF404040), height: 1.6)),
          ));
        }
        cursor = end == -1 ? raw.length : end;
      } else {
        cursor++;
      }
    }
    return widgets;
  }

  Widget _buildBottomActions(BuildContext context) {
    final isPro = context.watch<SubscriptionProvider>().isPro;
    final favoritesProvider = context.watch<FavoritesProvider>();
    final womanId = widget.woman['woman_id']?.toString() ?? '';
    final isFav = womanId.isNotEmpty ? favoritesProvider.isFavorite(womanId) : false;
    final favAdded = isPro && isFav;
    final isWildcard = widget.woman['_is_wildcard'] == true;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: _isSharing
                  ? (isEnglish ? "Preparing..." : "Preparando...")
                  : (isEnglish ? "Share" : "Compartir"),
              isOutlined: true,
              onPressed: _isSharing ? () {} : _shareCard,
            ),
          ),
          if (!isWildcard) ...[
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                label: isPro
                    ? (isFav
                        ? (isEnglish ? "Added ♥" : "Añadido ♥")
                        : (isEnglish ? "Add to Favorites" : "Añadir a Favoritas"))
                    : (isEnglish ? "Add to Favorites" : "Añadir a Favoritas"),
                onPressed: favAdded
                    ? () {}
                    : () {
                        if (isPro) {
                          favoritesProvider.toggle(widget.woman);
                          if (!isFav) _showFavoriteConfirmation();
                        } else {
                          _showUpsell();
                        }
                      },
              ),
            ),
          ],
        ],
      ),
    );
  }
}