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

  // Map of characters used in pixel art matrices
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

/// CustomPainter that renders a `List<String>` pixel matrix with crisp edges
class PixelMatrixPainter extends CustomPainter {
  final List<String> matrix;
  final double pixelSize;

  PixelMatrixPainter({required this.matrix, required this.pixelSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.none
      ..style = PaintingStyle.fill;

    for (int y = 0; y < matrix.length; y++) {
      final row = matrix[y];
      for (int x = 0; x < row.length; x++) {
        final char = row[x];
        if (char == '.') continue;
        final color = RetroPalette.colorForChar(char);
        paint.color = color;
        canvas.drawRect(
          Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PixelMatrixPainter oldDelegate) {
    return oldDelegate.matrix != matrix || oldDelegate.pixelSize != pixelSize;
  }
}

/// Widget for rendering 16x16 or 24x24 pixel sprites
class PixelSpriteWidget extends StatelessWidget {
  final List<String> matrix;
  final double pixelSize;

  const PixelSpriteWidget({
    super.key,
    required this.matrix,
    this.pixelSize = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    if (matrix.isEmpty) return const SizedBox.shrink();
    final width = matrix[0].length * pixelSize;
    final height = matrix.length * pixelSize;

    return CustomPaint(
      size: Size(width, height),
      painter: PixelMatrixPainter(matrix: matrix, pixelSize: pixelSize),
    );
  }
}

/// Library of custom pixel-art matrices (Zero Emojis!)
class PixelArtCatalog {
  // 1. CHARACTER PORTRAITS (16x16)
  static const List<String> bayaniPortrait = [
    '.....XXXXX......',
    '....XKKKKKX.....',
    '...XKKKKKKKX....',
    '..XRRRRRRRRRX...',
    '..XR!RRRRR!RX...',
    '..XCCCCCCCCCX...',
    '..XCXCXXCXCXC...',
    '..XCCCCCCCCCX...',
    '..XCCXCCCXCCX...',
    '..XCCXXXXXCCX...',
    '...XCCCCCCCX....',
    '....XXXXXXX.....',
    '..XXXXXXXXXXX...',
    '.XNNNNNNNNNNNX..',
    '.XNNNNNNNNNNNX..',
    '.XXXXXXXXXXXXX..',
  ];

  static const List<String> bertoPortrait = [
    '.....XXXXX......',
    '....XmmmmmX.....',
    '...XmmmmmmmX....',
    '..XmmmmmmmmmX...',
    '..XCCCCCCCCCX...',
    '..XCXXCCCXXCX...',
    '..XCXCCCCXCCX...',
    '..XCCCCCCCCCX...',
    '..XCCXMMMXCCX...',
    '..XCCXXXXXCCX...',
    '...XCCCCCCCX....',
    '....XXXXXXX.....',
    '..XXXXXXXXXXX...',
    '.XbbbbbbbbbbX...',
    '.XbbbbbbbbbbX...',
    '.XXXXXXXXXXXX...',
  ];

  static const List<String> lorenzoPortrait = [
    '.....XXXXX......',
    '....XYYYYYX.....',
    '...XYYYYYYYX....',
    '..XYYYYYYYYYX...',
    '..X!WWWWWWW!X...',
    '..XCCCCCCCCCX...',
    '..XCXXCCCXXCX...',
    '..XCCCCCCCCCX...',
    '..XCCCWWWCCCX...',
    '..XCCXXXXXCCX...',
    '...XCCCCCCCX....',
    '....XXXXXXX.....',
    '..XXXXXXXXXXX...',
    '.XSSSSSSSSSSX...',
    '.XSSSSSSSSSSX...',
    '.XXXXXXXXXXXX...',
  ];

  static const List<String> coachKanorPortrait = [
    '.....XXXXX......',
    '....XSSSSSX.....',
    '...XSSSSSSSX....',
    '..XSSSSSSSSSX...',
    '..XWWWWWWWWWX...',
    '..XCCCCCCCCCX...',
    '..XCXXCCCXXCX...',
    '..XCCCCCCCCCX...',
    '..XCSSSSSSSCX...',
    '..XCXXXXXXXXX...',
    '...XCCCCCCCX....',
    '....XXXXXXX.....',
    '..XXXXXXXXXXX...',
    '.XggXXXXXXXXX...',
    '.XggggggggggX...',
    '.XXXXXXXXXXXX...',
  ];

  // 2. FOOD & NUTRITION ITEMS (16x16)
  static const List<String> bukoJuice = [
    '........Y.......',
    '.......Y........',
    '......YY........',
    '....XXXXXX......',
    '...XGGGGGGX.....',
    '..XGGWWWWGGX....',
    '..XGWWWWWWGX....',
    '.XGGWWWWWWGGX...',
    '.XGGWWWWWWGGX...',
    '.XGGWWWWWWGGX...',
    '..XGGWWWWGGX....',
    '..XGGGGGGGGX....',
    '...XGGGGGGX.....',
    '....XXXXXX......',
    '................',
    '................',
  ];

  static const List<String> nilagangSaba = [
    '................',
    '.....XXXX.......',
    '....XYYYYX......',
    '...XYYYYYYX.....',
    '..XYYYYYYYYX....',
    '.XYYYYYYYYYYX...',
    '.XYWWWWWWWWYX...',
    '.XYWWWWWWWWYX...',
    '.XYYYYYYYYYYX...',
    '..XYYYYYYYYX....',
    '...XYYYYYYX.....',
    '....XYYYYX......',
    '.....XMMX.......',
    '......XX........',
    '................',
    '................',
  ];

  static const List<String> taho = [
    '.....XXXX.......',
    '....XSSSSX......',
    '....XSSSSX......',
    '...XXXXXXXX.....',
    '..XWWWWWWWWX....',
    '..XWWMMMMWWX....',
    '.XWWMMMMMMWWX...',
    '.XWWWWWWWWWWX...',
    '.XWWMMMMMMWWX...',
    '.XWWWWWWWWWWX...',
    '..XWWMMMMWWX....',
    '..XWWWWWWWWX....',
    '...XXXXXXXX.....',
    '....XMMMMX......',
    '.....XXXX.......',
    '................',
  ];

  static const List<String> adobongManok = [
    '................',
    '.....XXXXX......',
    '....XMMMMMX.....',
    '...XMMMMMMMX....',
    '..XMMMMMMMMMX...',
    '.XMMMMMMMMMMMX..',
    '.XMMWWWWWWWMMX..',
    '.XMMWWWWWWWMMX..',
    '.XMMMMMMMMMMMX..',
    '..XMMMMMMMMMX...',
    '...XMMMMMMMX....',
    '....XMMMMMX.....',
    '.....XXXXX......',
    '....XSSSSSSX....',
    '...XXXXXXXXXX...',
    '................',
  ];

  static const List<String> balut = [
    '......XXXX......',
    '....XXWWWWXX....',
    '...XWWWWWWWWX...',
    '..XWWWWWWWWWWX..',
    '..XWWWWWWWWWWX..',
    '.XWWWWWWWWWWWWX.',
    '.XWWWWYYWWWWWWX.',
    '.XWWWWYYWWWWWWX.',
    '.XWWWWWWWWWWWWX.',
    '..XWWWWWWWWWWX..',
    '..XWWWWWWWWWWX..',
    '...XWWWWWWWWX...',
    '....XXWWWWXX....',
    '.....XXXXXX.....',
    '...XMMMMMMMMX...',
    '...XXXXXXXXXX...',
  ];

  static const List<String> hinogNaMangga = [
    '......XX........',
    '.....XgX........',
    '....XggX........',
    '...XXYYXX.......',
    '..XYYYYYYX......',
    '.XYYYYYYYYX.....',
    '.XYYYYYYYYYX....',
    '.XYYYYYYYYYX....',
    '.XYYYYYYYYYX....',
    '..XYYYYYYYYX....',
    '..XYYYYYYYX.....',
    '...XYYYYYX......',
    '....XYYYX.......',
    '.....XYX........',
    '......X.........',
    '................',
  ];

  // 3. WEAPONS & GEAR (16x16)
  static const List<String> yantokStick = [
    '..............XX',
    '.............XMX',
    '............XMYX',
    '...........XMMX.',
    '..........XMYX..',
    '.........XMMX...',
    '........XMYX....',
    '.......XMMX.....',
    '......XMYX......',
    '.....XMMX.......',
    '....XMYX........',
    '...XMMX.........',
    '..XMYX..........',
    '.XMMX...........',
    'XMMX............',
    'XX..............',
  ];

  static const List<String> bahiStick = [
    '..............XX',
    '.............XmX',
    '............XmmX',
    '...........XmMX.',
    '..........XmmX..',
    '.........XmMX...',
    '........XmmX....',
    '.......XmMX.....',
    '......XmmX......',
    '.....XmMX.......',
    '....XmmX........',
    '...XmMX.........',
    '..XmmX..........',
    '.XmMX...........',
    'XmmX............',
    'XX..............',
  ];

  static const List<String> kamagongStick = [
    '..............XX',
    '.............XKX',
    '............XKKX',
    '...........XKKX.',
    '..........XKKX..',
    '.........XKKX...',
    '........XKKX....',
    '.......XKKX.....',
    '......XKKX......',
    '.....XKKX.......',
    '....XKKX........',
    '...XKKX.........',
    '..XKKX..........',
    '.XKKX...........',
    'XKKX............',
    'XX..............',
  ];

  static const List<String> paddedStick = [
    '..............XX',
    '.............XRX',
    '............XRRX',
    '...........XR!X.',
    '..........XRRX..',
    '.........XR!X...',
    '........XRRX....',
    '.......XR!X.....',
    '......XRRX......',
    '.....XR!X.......',
    '....XRRX........',
    '...XWWWX........',
    '..XWXXWX........',
    '.XWWWWX.........',
    'XWXXWX..........',
    'XX..............',
  ];

  static const List<String> daggerDaga = [
    '............XX..',
    '...........X!X..',
    '..........X!SX..',
    '.........X!SX...',
    '........X!SX....',
    '.......X!SX.....',
    '..XXXXX!SX......',
    '.XMMMMM!XXXXX...',
    'XMMMMMMMMMMMX...',
    '.XMMMMMXXXXX....',
    '..XXXXX.........',
    '................',
    '................',
    '................',
    '................',
    '................',
  ];

  static const List<String> gearHeadgear = [
    '....XXXXXX......',
    '...XRRRRRRX.....',
    '..XRRRRRRRRX....',
    '.XRRRSSSSRRRX...',
    '.XRSSXSSXSSRX...',
    '.XRSSSSSSSSRX...',
    '.XRSSXSSXSSRX...',
    '.XRSSSSSSSSRX...',
    '.XRSSXSSXSSRX...',
    '.XRRRSSSSRRRX...',
    '..XRRRRRRRRX....',
    '...XRRRRRRX.....',
    '....XXXXXX......',
    '................',
    '................',
    '................',
  ];

  static const List<String> gearArmor = [
    '..XXXX..XXXX....',
    '.XRRRRXXRRRRX...',
    'XRRRRRRRRRRRRX..',
    'XRRRRRRRRRRRRX..',
    'XRRR!RRRR!RRRX..',
    'XRRR!RRRR!RRRX..',
    'XRRRRRRRRRRRRX..',
    'XRRRRRRRRRRRRX..',
    '.XRRRBBBRRRRX...',
    '.XRRRBBBRRRRX...',
    '..XRRRRRRRRX....',
    '..XRRRRRRRRX....',
    '...XXXXXXXX.....',
    '................',
    '................',
    '................',
  ];

  static const List<String> gearShoes = [
    '................',
    '................',
    '......XXXXX.....',
    '.....XRRRRX.....',
    '.....XRRRRX.....',
    '.....XRRRRX.....',
    '.....XRRRRXXXX..',
    '....XRRRRRRRRX..',
    '...XRRRRRRRRRX..',
    '..XRRRRRRRRRRX..',
    '.XRRRRRRRRRRRX..',
    '.XWWWWWWWWWWWWX.',
    '.XXXXXXXXXXXXXX.',
    '................',
    '................',
    '................',
  ];

  // 4. ACTION BAR & SYSTEM ICONS (16x16)
  static const List<String> iconSanay = [
    '..XXXX....XXXX..',
    '.XKKKKX..XKKKKX.',
    'XKKXXKKXXKKXXKKX',
    'XKKXXKKSSKKXXKKX',
    'XKKXXKKSSKKXXKKX',
    '.XKKKKXSSXKKKKX.',
    '..XXXXSSSSXXXX..',
    '......SSSS......',
    '......SSSS......',
    '..XXXXSSSSXXXX..',
    '.XKKKKXSSXKKKKX.',
    'XKKXXKKSSKKXXKKX',
    'XKKXXKKSSKKXXKKX',
    'XKKXXKKXXKKXXKKX',
    '.XKKKKX..XKKKKX.',
    '..XXXX....XXXX..',
  ];

  static const List<String> iconAral = [
    '.....XXXXXX.....',
    '...XXWWWWWWXX...',
    '..XWWWWWWWWWWX..',
    '.XWWWWWWWWWWWWX.',
    'XWWWWWWWWWWWWWWX',
    'XWSSSWWWWWWSSSWX',
    'XWSSSWWWWWWSSSWX',
    'XWSSSWWWWWWSSSWX',
    'XWSSSWWWWWWSSSWX',
    'XWWWWWWWWWWWWWWX',
    'XWSSSWWWWWWSSSWX',
    'XWSSSWWWWWWSSSWX',
    'XWWWWWWWWWWWWWWX',
    '.XMMMMMMMMMMMMX.',
    '..XXXXXXXXXXXX..',
    '................',
  ];

  static const List<String> iconHinga = [
    '.....XXXXX......',
    '...XXYYYYYXX....',
    '..XYYYYYYYYYX...',
    '.XYYYYYYXXXXX...',
    '.XYYYYYX........',
    'XYYYYYX.........',
    'XYYYYYX.........',
    'XYYYYYX.........',
    'XYYYYYX.........',
    '.XYYYYYX........',
    '.XYYYYYYXXXXX...',
    '..XYYYYYYYYYX...',
    '...XXYYYYYXX....',
    '.....XXXXX......',
    '................',
    '................',
  ];

  static const List<String> iconSpar = [
    'X..............X',
    'XX............XX',
    '.XMX........XMX.',
    '..XMX......XMX..',
    '...XMYX..XMYX...',
    '....XMYXXMYX....',
    '.....XMYMYX.....',
    '......XMMX......',
    '.....XMYMYX.....',
    '....XMYXXMYX....',
    '...XMYX..XMYX...',
    '..XMX......XMX..',
    '.XMX........XMX.',
    'XX............XX',
    'X..............X',
    '................',
  ];

  static const List<String> iconLaban = [
    '..XXXXXXXXXXXX..',
    '.XYYYYYYYYYYYYX.',
    'XYYYYYYYYYYYYYYX',
    'XYXXYYYYYYYYXXYX',
    'XX..XYYYYYYX..XX',
    '....XYYYYYYX....',
    '....XYYYYYYX....',
    '.....XYYYYX.....',
    '......XYYX......',
    '......XYYX......',
    '.....XYYYYX.....',
    '....XYYYYYYX....',
    '..XXXXXXXXXXXX..',
    '.XSSSSSSSSSSSSX.',
    '.XXXXXXXXXXXXXX.',
    '................',
  ];

  static const List<String> iconTiangge = [
    '..XXXXXXXXXXXX..',
    '.XRWRWRWRWRWRWX.',
    'XRWRWRWRWRWRWRWX',
    'XRRRRRRRRRRRRRRX',
    '.XXXXXXXXXXXXXX.',
    '..XSSX....XSSX..',
    '..XSSX....XSSX..',
    '..XSSX....XSSX..',
    '..XSSXXXXXXSSX..',
    '..XMMMMMMMMMMX..',
    '..XMMMMMMMMMMX..',
    '..XMMMMMMMMMMX..',
    '..XXXXXXXXXXXX..',
    '................',
    '................',
    '................',
  ];

  static const List<String> iconSettings = [
    '......XXXX......',
    '....XXSSSSXX....',
    '...XSSXXXXSSX...',
    '..XSSXSSSSXSSX..',
    '.XSSXSSXXSSXSSX.',
    '.XSSXSSXXSSXSSX.',
    'XSSXSSSSSSSSXSSX',
    'XSSXSSSSSSSSXSSX',
    'XSSXSSSSSSSSXSSX',
    'XSSXSSSSSSSSXSSX',
    '.XSSXSSXXSSXSSX.',
    '.XSSXSSXXSSXSSX.',
    '..XSSXSSSSXSSX..',
    '...XSSXXXXSSX...',
    '....XXSSSSXX....',
    '......XXXX......',
  ];

  // 5. ATTRIBUTE & STATUS MINI ICONS (8x8)
  static const List<String> miniHeart = [
    '.XX..XX.',
    'XRRXXRRX',
    'XRRRRRRX',
    'XRRRRRRX',
    '.XRRRRX.',
    '..XRRX..',
    '...XX...',
    '........',
  ];

  static const List<String> miniWind = [
    '...XXXX.',
    '..XBBBBX',
    'XBBBBX..',
    '..XXXX..',
    '.XBBBBX.',
    'XBBBBX..',
    '.XXXX...',
    '........',
  ];

  static const List<String> miniPeso = [
    '..XXXX..',
    '.XYYYYX.',
    'XYXYYYYX',
    'XYXXXX..',
    'XYXYYYX.',
    'XYXXXXX.',
    '.XYYYYX.',
    '..XXXX..',
  ];

  static const List<String> miniPrestige = [
    '...XX...',
    '..XYYX..',
    'XXYYYYXX',
    '.XYYYYX.',
    '..XYYX..',
    '.XYXXYX.',
    'XX....XX',
    '........',
  ];

  static const List<String> miniShield = [
    'XXXXXXXX',
    'XGGGGGGX',
    'XGGGGGGX',
    'XGGGGGGX',
    '.XGGGGX.',
    '..XGGX..',
    '...XX...',
    '........',
  ];

  static const List<String> miniLightning = [
    '....XX..',
    '...XYX..',
    '..XYX...',
    '.XYYYX..',
    '..XYX...',
    '.XYX....',
    '.XX.....',
    '........',
  ];

  // 6. STREET ELEMENTS (Tricycle 24x16)
  static const List<String> tricycleSprite = [
    '........................',
    '.....XXXXXXXXXXXX.......',
    '....XRRRRRRRRRRRRX......',
    '...XRRRRRRRRRRRRRRX.....',
    '..XRRXXXXXXXXXXXXRRX....',
    '..XRXWWWWWWWWWWWWXRX....',
    '..XRXWWWWWWWWWWWWXRX....',
    '..XRXXXXXXXXXXXXXXRX....',
    '..XRRRRRRRRRRRRRRRRX....',
    '..XRRRRRRRRRRRRRRRRX.XX.',
    '.XXRRRRRRRRRRRRRRRRXXXMX',
    'XKKXRRRRRRRRRRRRRRXKKXMX',
    'XKKXRRRRRRRRRRRRRRXKKXMX',
    '.XX.XXXXXXXXXXXXXX.XX.XX',
    '........................',
    '........................',
  ];
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
          mainAxisSize: MainAxisSize.min,
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
