// Generates the MediConnect brand logo PNGs via golden rendering.
// Run:  flutter test test/logo_golden_test.dart --update-goldens
// Outputs land in test/goldens/ and are copied to their targets by
// tool/copy_logo_assets.ps1.
//
// Design: rounded square in the brand gradient (#1A73E8 → #00BFA5),
// white medical cross with a heartbeat pulse cut across it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sizes = [512, 192, 144, 96, 72, 48];
  for (final s in sizes) {
    testWidgets('logo_$s', (tester) async {
      tester.view.physicalSize = Size(s.toDouble(), s.toDouble());
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        RepaintBoundary(
          key: ValueKey('logo_$s'),
          child: MediConnectLogo(size: s.toDouble()),
        ),
      );
      await expectLater(
        find.byKey(ValueKey('logo_$s')),
        matchesGoldenFile('goldens/logo_$s.png'),
      );
    });

    // Maskable variants: content scaled into the 80% safe zone so Android
    // / PWA circular masks never clip the cross.
    if (s == 512 || s == 192) {
      testWidgets('logo_maskable_$s', (tester) async {
        tester.view.physicalSize = Size(s.toDouble(), s.toDouble());
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          RepaintBoundary(
            key: ValueKey('logo_maskable_$s'),
            child: MediConnectLogo(size: s.toDouble(), insetScale: 0.76),
          ),
        );
        await expectLater(
          find.byKey(ValueKey('logo_maskable_$s')),
          matchesGoldenFile('goldens/logo_maskable_$s.png'),
        );
      });
    }
  }
}

/// The MediConnect app icon, drawn as vectors so it stays crisp at every
/// generated size (48 px launcher → 512 px store listing).
class MediConnectLogo extends StatelessWidget {
  final double size;

  /// Scales the artwork inside the canvas (used for maskable icons).
  final double insetScale;

  const MediConnectLogo({super.key, this.size = 512, this.insetScale = 1.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _LogoPainter(insetScale: insetScale),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double insetScale;
  _LogoPainter({required this.insetScale});

  static const Color brandBlue = Color(0xFF1A73E8);
  static const Color brandTeal = Color(0xFF00BFA5);
  static const Color pulseBlue = Color(0xFF0D47A1);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);
    if (insetScale != 1.0) {
      final offset = s * (1 - insetScale) / 2;
      canvas.translate(offset, offset);
      canvas.scale(insetScale);
    }

    // ── Rounded-square gradient background ──
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [brandBlue, brandTeal],
      ).createShader(Offset.zero & Size.square(s));
    final bgRadius = Radius.circular(s * 0.22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & Size.square(s), bgRadius),
      bgPaint,
    );

    // Soft top-left highlight, clipped to the background so it has no hard
    // circular edge.
    canvas.save();
    canvas.clipPath(
      Path()
        ..addRRect(
            RRect.fromRectAndRadius(Offset.zero & Size.square(s), bgRadius)),
    );
    canvas.drawRect(
      Offset.zero & Size.square(s),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x2EFFFFFF), Color(0x00FFFFFF)],
        ).createShader(Offset.zero & Size.square(s)),
    );
    canvas.restore();

    // ── Medical cross (two rounded bars, slightly above center) ──
    final cx = s * 0.5;
    final cy = s * 0.47;
    final armW = s * 0.23;
    final armL = s * 0.62;
    final barRadius = Radius.circular(s * 0.055);

    final vertical = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: armW, height: armL),
      barRadius,
    );
    final horizontal = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: armL, height: armW),
      barRadius,
    );

    // White cross fill.
    final crossFill = Paint()..color = Colors.white;
    canvas.drawRRect(vertical, crossFill);
    canvas.drawRRect(horizontal, crossFill);

    // ── Heartbeat pulse, clipped to the cross union ──
    final crossPath = Path()
      ..addRRect(vertical)
      ..addRRect(horizontal);

    final pulse = Path()..moveTo(cx - armL * 0.62, cy);
    final pulsePoints = [
      Offset(cx - armL * 0.34, cy),
      Offset(cx - armL * 0.22, cy - s * 0.13),
      Offset(cx - armL * 0.05, cy + s * 0.15),
      Offset(cx + armL * 0.06, cy - s * 0.08),
      Offset(cx + armL * 0.16, cy),
      Offset(cx + armL * 0.62, cy),
    ];
    for (final p in pulsePoints) {
      pulse.lineTo(p.dx, p.dy);
    }

    canvas.save();
    canvas.clipPath(crossPath);
    canvas.drawPath(
      pulse,
      Paint()
        ..color = pulseBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.045
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.insetScale != insetScale;
}
