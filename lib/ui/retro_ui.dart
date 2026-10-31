import 'package:flutter/material.dart';

/// 16-Color Classic Retro Arcade / Kairosoft Palette
class RetroPalette {
  static const Color transparent = Colors.transparent;
  static const Color black = Color(0xFF1A1C2C);
  static const Color darkNavy = Color(0xFF1E293B);
  static const Color deepBlue = Color(0xFF2B3864);
  static const Color darkBrown = Color(0xFF564064);
  static const Color darkGreen = Color(0xFF2F5738);
  static const Color darkRed = Color(0xFF8B2635);
  static const Color red = Color(0xFFDC2626);
  static const Color orange = Color(0xFFE6482E);
  static const Color gold = Color(0xFFF4B41B);
  static const Color yellow = Color(0xFFFDE047);
  static const Color green = Color(0xFF4ADE80);
  static const Color cyan = Color(0xFF38BDF8);
  static const Color skyBlue = Color(0xFF60A5FA);
  static const Color skinPeach = Color(0xFFF2B880);
  static const Color woodBrown = Color(0xFF8C532B);
  static const Color steelGrey = Color(0xFF8B9BB4);
  static const Color darkGrey = Color(0xFF3F3F74);
  static const Color creamWhite = Color(0xFFF4ECE1);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Map of characters used in pixel art matrices (fallback legacy support)
  static Color colorForChar(String char) {
    switch (char) {
      case 'X':
        return black;
      case 'W':
        return creamWhite;
      case '!':
        return pureWhite;
      case 'R':
        return red;
      case 'r':
        return darkRed;
      case 'O':
        return orange;
      case 'Y':
        return gold;
      case 'y':
        return yellow;
      case 'G':
        return green;
      case 'g':
        return darkGreen;
      case 'B':
        return cyan;
      case 'b':
        return skyBlue;
      case 'D':
        return deepBlue;
      case 'N':
        return darkNavy;
      case 'C':
        return skinPeach;
      case 'M':
        return woodBrown;
      case 'm':
        return darkBrown;
      case 'S':
        return steelGrey;
      case 'K':
        return darkGrey;
      case '.':
      default:
        return transparent;
    }
  }
}

class _TokenInfo {
  final String label;
  final Color color;
  final double width;
  final double height;
  final String assetPath;

  const _TokenInfo({
    required this.label,
    required this.color,
    this.width = 16.0,
    this.height = 16.0,
    this.assetPath = '',
  });
}

_TokenInfo _resolveToken(String token) {
  switch (token) {
    case 'PORTRAIT:BAYANI':
      return const _TokenInfo(label: 'BAYANI', color: Color(0xFF38BDF8), width: 24, height: 24, assetPath: 'portraits/bayani.png');
    case 'PORTRAIT:BERTO':
      return const _TokenInfo(label: 'BERTO', color: Color(0xFFDC2626), width: 24, height: 24, assetPath: 'portraits/berto.png');
    case 'PORTRAIT:LORENZO':
      return const _TokenInfo(label: 'LORENZO', color: Color(0xFF8B5CF6), width: 24, height: 24, assetPath: 'portraits/lorenzo.png');
    case 'PORTRAIT:KANOR':
      return const _TokenInfo(label: 'KANOR', color: Color(0xFFF4B41B), width: 24, height: 24, assetPath: 'portraits/kanor.png');
    case 'ICON:SANAY':
      return const _TokenInfo(label: 'SANAY', color: Color(0xFF38BDF8), assetPath: 'ui/icon_sanay.png');
    case 'ICON:ARAL':
      return const _TokenInfo(label: 'ARAL', color: Color(0xFF4ADE80), assetPath: 'ui/icon_aral.png');
    case 'ICON:HINGA':
      return const _TokenInfo(label: 'HINGA', color: Color(0xFF60A5FA), assetPath: 'ui/icon_hinga.png');
    case 'ICON:SPAR':
      return const _TokenInfo(label: 'SPAR', color: Color(0xFFF4B41B), assetPath: 'ui/icon_spar.png');
    case 'ICON:LABAN':
      return const _TokenInfo(label: 'LABAN', color: Color(0xFFDC2626), assetPath: 'ui/icon_laban.png');
    case 'ICON:TIANGGE':
      return const _TokenInfo(label: 'TIANGGE', color: Color(0xFFE6482E), assetPath: 'ui/icon_tiangge.png');
    case 'ICON:SET':
      return const _TokenInfo(label: 'SET', color: Color(0xFF8B9BB4), assetPath: 'ui/icon_settings.png');
    case 'ICON:P':
      return const _TokenInfo(label: 'P', color: Color(0xFFF4B41B), width: 12, height: 12, assetPath: 'ui/peso.png');
    case 'ICON:FAME':
      return const _TokenInfo(label: 'FAME', color: Color(0xFFFDE047), width: 12, height: 12, assetPath: 'ui/fame.png');
    case 'ICON:WIND':
      return const _TokenInfo(label: 'STA', color: Color(0xFF60A5FA), width: 12, height: 12, assetPath: 'ui/stamina.png');
    case 'ICON:CUP':
      return const _TokenInfo(label: 'CUP', color: Color(0xFFF4B41B), width: 14, height: 14, assetPath: 'ui/trophy.png');
    case 'ICON:RING':
      return const _TokenInfo(label: 'RING', color: Color(0xFFDC2626), width: 14, height: 14, assetPath: 'ui/ring.png');
    case 'ICON:HP':
      return const _TokenInfo(label: 'HP', color: Color(0xFFDC2626), width: 12, height: 12, assetPath: 'ui/hp.png');
    case 'ICON:STA':
      return const _TokenInfo(label: 'STA', color: Color(0xFFFDE047), width: 12, height: 12, assetPath: 'ui/stamina.png');
    case 'ICON:STK':
      return const _TokenInfo(label: 'DIS', color: Color(0xFFF4B41B), width: 12, height: 12, assetPath: 'ui/stick.png');
    case 'ICON:POW':
      return const _TokenInfo(label: 'LAK', color: Color(0xFFDC2626), width: 12, height: 12, assetPath: 'ui/power.png');
    case 'ICON:DEF':
      return const _TokenInfo(label: 'SAL', color: Color(0xFF4ADE80), width: 12, height: 12, assetPath: 'ui/defense.png');
    case 'ICON:SPD':
      return const _TokenInfo(label: 'BIL', color: Color(0xFF38BDF8), width: 12, height: 12, assetPath: 'ui/speed.png');
    case 'ICON:SHIELD':
      return const _TokenInfo(label: 'SHLD', color: Color(0xFF4ADE80), width: 12, height: 12, assetPath: 'ui/shield.png');
    case 'GEAR:SHOE':
      return const _TokenInfo(label: 'SHOE', color: Color(0xFF38BDF8), width: 16, height: 16, assetPath: 'equipment/shoe.png');
    case 'GEAR:HEAD':
      return const _TokenInfo(label: 'HEAD', color: Color(0xFFDC2626), width: 16, height: 16, assetPath: 'equipment/headgear.png');
    case 'GEAR:ARMOR':
      return const _TokenInfo(label: 'ARMOR', color: Color(0xFF1E293B), width: 16, height: 16, assetPath: 'equipment/armor.png');
    case 'WEAPON:BAHI':
      return const _TokenInfo(label: 'BAHI', color: Color(0xFF8C532B), width: 16, height: 16, assetPath: 'equipment/bahi.png');
    case 'WEAPON:KMGNG':
      return const _TokenInfo(label: 'KMGNG', color: Color(0xFF1A1C2C), width: 16, height: 16, assetPath: 'equipment/kamagong.png');
    case 'WEAPON:PADD':
      return const _TokenInfo(label: 'PADD', color: Color(0xFFDC2626), width: 16, height: 16, assetPath: 'equipment/padded.png');
    case 'WEAPON:YNTK':
      return const _TokenInfo(label: 'YNTK', color: Color(0xFFF2B880), width: 16, height: 16, assetPath: 'equipment/yantok.png');
    case 'WEAPON:DAGA':
      return const _TokenInfo(label: 'DAGA', color: Color(0xFF8B9BB4), width: 16, height: 16, assetPath: 'equipment/daga.png');
    case 'FOOD:BUKO':
      return const _TokenInfo(label: 'BUKO', color: Color(0xFF4ADE80), width: 16, height: 16, assetPath: 'equipment/buko.png');
    case 'FOOD:SABA':
      return const _TokenInfo(label: 'SABA', color: Color(0xFFFDE047), width: 16, height: 16, assetPath: 'equipment/saba.png');
    case 'FOOD:TAHO':
      return const _TokenInfo(label: 'TAHO', color: Color(0xFFF4ECE1), width: 16, height: 16, assetPath: 'equipment/taho.png');
    case 'FOOD:ADBNG':
      return const _TokenInfo(label: 'ADBNG', color: Color(0xFF8C532B), width: 16, height: 16, assetPath: 'equipment/adobo.png');
    case 'FOOD:BALUT':
      return const _TokenInfo(label: 'BALUT', color: Color(0xFF8B9BB4), width: 16, height: 16, assetPath: 'equipment/balut.png');
    case 'FOOD:MNGGA':
      return const _TokenInfo(label: 'MNGGA', color: Color(0xFFF4B41B), width: 16, height: 16, assetPath: 'equipment/mangga.png');
    case 'CHAR:BAYANI':
    case 'CHAR:PUNCH':
    case 'CHAR:SIT':
    case 'CHAR:STEP':
    case 'CHAR:KO':
    case 'CHAR:VIC':
      return const _TokenInfo(label: 'BAYANI', color: Color(0xFF38BDF8), width: 20, height: 26, assetPath: 'characters/bayani.png');
    case 'CHAR:OPP':
    case 'CHAR:OPP_STEP':
    case 'CHAR:OPP_VIC':
      return const _TokenInfo(label: 'KALABAN', color: Color(0xFFDC2626), width: 20, height: 26, assetPath: 'characters/opponent.png');
    case 'VEHICLE:TRI':
      return const _TokenInfo(label: 'TRIKE', color: Color(0xFFDC2626), width: 28, height: 18, assetPath: 'camp/vehicles/tricycle.png');
    default:
      return const _TokenInfo(label: 'PIX', color: Color(0xFF38BDF8));
  }
}

/// CustomPainter that renders crisp pixel badges / tokens
class PixelMatrixPainter extends CustomPainter {
  final List<String> matrix;
  final double pixelSize;

  PixelMatrixPainter({required this.matrix, required this.pixelSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (matrix.isEmpty) return;
    final token = matrix.first;

    // Legacy raw ASCII row fallback (if raw ASCII character matrix is passed)
    if (token.length > 8 && (token.contains('X') || token.contains('.'))) {
      final paint = Paint()
        ..isAntiAlias = false
        ..filterQuality = FilterQuality.none
        ..style = PaintingStyle.fill;

      for (int y = 0; y < matrix.length; y++) {
        final row = matrix[y];
        for (int x = 0; x < row.length; x++) {
          final char = row[x];
          if (char == '.') continue;
          paint.color = RetroPalette.colorForChar(char);
          canvas.drawRect(
            Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
            paint,
          );
        }
      }
      return;
    }

    // High-visibility token placeholder
    final info = _resolveToken(token);
    final outlinePaint = Paint()
      ..color = const Color(0xFF1A1C2C)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), outlinePaint);

    final fillPaint = Paint()
      ..color = info.color
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    canvas.drawRect(Rect.fromLTWH(1, 1, size.width - 2, size.height - 2), fillPaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    canvas.drawRect(Rect.fromLTWH(1, 1, size.width - 2, 2), highlightPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: info.label,
        style: const TextStyle(
          color: Color(0xFF1A1C2C),
          fontSize: 7.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Silkscreen',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);

    tp.paint(
      canvas,
      Offset(
        (size.width - tp.width) / 2,
        (size.height - tp.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant PixelMatrixPainter oldDelegate) {
    return oldDelegate.matrix != matrix || oldDelegate.pixelSize != pixelSize;
  }
}

/// Widget for rendering 16x16 or 24x24 pixel sprites / placeholders
class PixelSpriteWidget extends StatelessWidget {
  final List<String> matrix;
  final double pixelSize;
  final String? label;
  final Color? color;

  const PixelSpriteWidget({
    super.key,
    required this.matrix,
    this.pixelSize = 2.0,
    this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (matrix.isEmpty) return const SizedBox.shrink();
    final token = matrix.first;
    final info = _resolveToken(token);

    final width = info.width * pixelSize;
    final height = info.height * pixelSize;

    return CustomPaint(
      size: Size(width, height),
      painter: PixelMatrixPainter(matrix: matrix, pixelSize: pixelSize),
    );
  }
}

/// Catalog of pixel asset tokens (Zero procedural ASCII matrices!)
class PixelArtCatalog {
  // 1. CHARACTER PORTRAITS
  static const List<String> bayaniPortrait = ['PORTRAIT:BAYANI'];
  static const List<String> bertoPortrait = ['PORTRAIT:BERTO'];
  static const List<String> lorenzoPortrait = ['PORTRAIT:LORENZO'];
  static const List<String> coachKanorPortrait = ['PORTRAIT:KANOR'];

  // 2. FOOD & NUTRITION
  static const List<String> bukoJuice = ['FOOD:BUKO'];
  static const List<String> nilagangSaba = ['FOOD:SABA'];
  static const List<String> taho = ['FOOD:TAHO'];
  static const List<String> adobongManok = ['FOOD:ADBNG'];
  static const List<String> balut = ['FOOD:BALUT'];
  static const List<String> hinogNaMangga = ['FOOD:MNGGA'];

  // 3. WEAPONS & GEAR
  static const List<String> yantokStick = ['WEAPON:YNTK'];
  static const List<String> bahiStick = ['WEAPON:BAHI'];
  static const List<String> kamagongStick = ['WEAPON:KMGNG'];
  static const List<String> paddedStick = ['WEAPON:PADD'];
  static const List<String> daggerDaga = ['WEAPON:DAGA'];
  static const List<String> gearHeadgear = ['GEAR:HEAD'];
  static const List<String> gearArmor = ['GEAR:ARMOR'];
  static const List<String> gearShoes = ['GEAR:SHOE'];

  // 4. MAIN NAVIGATION ICONS
  static const List<String> iconSanay = ['ICON:SANAY'];
  static const List<String> iconAral = ['ICON:ARAL'];
  static const List<String> iconHinga = ['ICON:HINGA'];
  static const List<String> iconSpar = ['ICON:SPAR'];
  static const List<String> iconLaban = ['ICON:LABAN'];
  static const List<String> iconTiangge = ['ICON:TIANGGE'];
  static const List<String> iconSettings = ['ICON:SET'];

  // 5. MINI STAT & CURRENCY ICONS
  static const List<String> miniHeart = ['ICON:HP'];
  static const List<String> miniWind = ['ICON:WIND'];
  static const List<String> miniPeso = ['ICON:P'];
  static const List<String> miniPrestige = ['ICON:FAME'];
  static const List<String> miniShield = ['ICON:SHIELD'];
  static const List<String> miniLightning = ['ICON:STA'];
  static const List<String> miniMuscle = ['ICON:POW'];
  static const List<String> miniShoe = ['ICON:SPD'];
  static const List<String> miniTrunks = ['ICON:DEF'];
  static const List<String> miniBastonIcon = ['ICON:STK'];
  static const List<String> miniRing = ['ICON:RING'];
  static const List<String> miniTrophy = ['ICON:CUP'];

  // 6. CHIBI & STREET ASSETS
  static const List<String> chibiBayaniIdle = ['CHAR:BAYANI'];
  static const List<String> chibiBayaniStep = ['CHAR:STEP'];
  static const List<String> chibiBayaniPunch = ['CHAR:PUNCH'];
  static const List<String> chibiBayaniKnockdown = ['CHAR:KO'];
  static const List<String> chibiBayaniVictory = ['CHAR:VIC'];
  static const List<String> chibiBayaniSit = ['CHAR:SIT'];
  static const List<String> chibiOpponentIdle = ['CHAR:OPP'];
  static const List<String> chibiOpponentStep = ['CHAR:OPP_STEP'];
  static const List<String> chibiOpponentVictory = ['CHAR:OPP_VIC'];
  static const List<String> tricycleSprite = ['VEHICLE:TRI'];
}

/// Kairosoft-style Double-Bordered Retro Window Box
class RetroBox extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? titleTrailing;
  final Color backgroundColor;
  final Color borderColor;
  final Color bevelColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;

  const RetroBox({
    super.key,
    required this.child,
    this.title,
    this.titleTrailing,
    this.backgroundColor = const Color(0xFF1E293B),
    this.borderColor = const Color(0xFF1A1C2C),
    this.bevelColor = const Color(0xFFF4B41B),
    this.padding = const EdgeInsets.all(12),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF0F172A),
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: bevelColor.withValues(alpha: 0.6), width: 1.5),
        ),
        padding: padding,
        child: Column(
          mainAxisSize: height != null ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          color: bevelColor,
                          margin: const EdgeInsets.only(right: 6),
                        ),
                        Flexible(
                          child: Text(
                            title!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: bevelColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ?titleTrailing,
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 2,
                color: borderColor,
                margin: const EdgeInsets.only(bottom: 8),
              ),
            ],
            if (height != null)
              Expanded(child: child)
            else
              child,
          ],
        ),
      ),
    );
  }
}

/// Chunky 3D Tactile Retro Button
class RetroButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final double height;
  final double? width;

  const RetroButton({
    super.key,
    required this.child,
    this.onTap,
    this.color = const Color(0xFFE6482E),
    this.textColor = Colors.white,
    this.borderColor = const Color(0xFF1A1C2C),
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.height = 42,
    this.width,
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;
    final topOffset = _isPressed ? 3.0 : 0.0;
    final bottomOffset = _isPressed ? 0.0 : 3.0;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        width: widget.width,
        height: widget.height,
        margin: EdgeInsets.only(top: topOffset, bottom: bottomOffset),
        decoration: BoxDecoration(
          color: isEnabled ? widget.color : const Color(0xFF3F3F74),
          border: Border.all(color: widget.borderColor, width: 2.5),
          boxShadow: [
            if (!_isPressed && isEnabled)
              BoxShadow(
                color: widget.borderColor,
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Segmented Pixel Progress Bar (Kairosoft Style)
class PixelBar extends StatelessWidget {
  final double current;
  final double max;
  final Color fillColor;
  final Color backgroundColor;
  final int totalSegments;
  final double height;

  const PixelBar({
    super.key,
    required this.current,
    required this.max,
    required this.fillColor,
    this.backgroundColor = const Color(0xFF0F172A),
    this.totalSegments = 10,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (max > 0 ? (current / max) : 0.0).clamp(0.0, 1.0);
    final filledSegments = (ratio * totalSegments).round();

    return Container(
      height: height,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: const Color(0xFF1A1C2C), width: 1.5),
      ),
      child: Row(
        children: List.generate(totalSegments, (index) {
          final isFilled = index < filledSegments;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              color: isFilled ? fillColor : const Color(0xFF2B3864).withValues(alpha: 0.5),
            ),
          );
        }),
      ),
    );
  }
}
