import 'package:flutter/material.dart';

/// Vector artwork scales cleanly across phone and tablet layouts.
class DairyBrand extends StatelessWidget {
  const DairyBrand({super.key, this.size = 90});
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'DairyTrace cow and leaf logo',
    child: CustomPaint(size: Size.square(size), painter: _CowLogo()),
  );
}

class _CowLogo extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    c.scale(s.width / 100, s.height / 100);
    final green = Paint()..color = const Color(0xFF006B50);
    final pale = Paint()..color = const Color(0xFFE0F5E9);
    c.drawOval(
      Rect.fromCenter(center: const Offset(23, 38), width: 32, height: 19),
      green,
    );
    c.drawOval(
      Rect.fromCenter(center: const Offset(73, 38), width: 32, height: 19),
      green,
    );
    final head = Path()
      ..moveTo(29, 33)
      ..quadraticBezierTo(24, 17, 36, 19)
      ..quadraticBezierTo(48, 9, 59, 20)
      ..quadraticBezierTo(75, 16, 69, 35)
      ..lineTo(61, 70)
      ..quadraticBezierTo(49, 86, 37, 70)
      ..close();
    c.drawPath(head, green);
    final blaze = Path()
      ..moveTo(41, 24)
      ..quadraticBezierTo(48, 18, 57, 25)
      ..lineTo(53, 51)
      ..lineTo(47, 66)
      ..lineTo(42, 48)
      ..close();
    c.drawPath(blaze, pale);
    c.drawCircle(const Offset(38, 43), 3, Paint()..color = Colors.white);
    c.drawCircle(const Offset(60, 43), 3, Paint()..color = Colors.white);
    c.drawOval(const Rect.fromLTWH(38, 62, 23, 16), pale);
    c.drawCircle(const Offset(44, 68), 2, green);
    c.drawCircle(const Offset(55, 68), 2, green);
    final leaf = Path()
      ..moveTo(57, 85)
      ..quadraticBezierTo(59, 53, 91, 47)
      ..quadraticBezierTo(91, 78, 57, 85);
    c.drawPath(leaf, Paint()..color = const Color(0xFF80B928));
    c.drawLine(
      const Offset(55, 88),
      const Offset(83, 58),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _CowLogo old) => false;
}

class FarmLandscape extends StatelessWidget {
  const FarmLandscape({super.key, this.height = 130});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: CustomPaint(painter: _FarmPainter()),
  );
}

class _FarmPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    c.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE5F8F7), Color(0xFFF5FBE7)],
        ).createShader(Offset.zero & s),
    );
    for (var i = 0; i < 4; i++) {
      final p = Path()..moveTo(0, s.height * (.25 + i * .17));
      p.cubicTo(
        s.width * .2,
        s.height * (-.1 + i * .17),
        s.width * .5,
        s.height * (.9 - i * .1),
        s.width,
        s.height * (.15 + i * .2),
      );
      p.lineTo(s.width, s.height);
      p.lineTo(0, s.height);
      p.close();
      c.drawPath(
        p,
        Paint()
          ..color = [
            const Color(0xFFB6E1CF),
            const Color(0xFF87C9A7),
            const Color(0xFF53AB78),
            const Color(0xFF8DBE40),
          ][i],
      );
    }
    final path = Path()
      ..moveTo(s.width * .56, s.height)
      ..quadraticBezierTo(
        s.width * .2,
        s.height * .8,
        s.width * .7,
        s.height * .55,
      )
      ..quadraticBezierTo(s.width * .4, s.height * .85, s.width * .8, s.height)
      ..close();
    c.drawPath(path, Paint()..color = const Color(0xFFE0DD93));
    final x = s.width * .78, y = s.height * .49;
    c.drawRect(
      Rect.fromLTWH(x, y, 35, 30),
      Paint()..color = const Color(0xFFF0C68F),
    );
    c.drawPath(
      Path()
        ..moveTo(x - 5, y)
        ..lineTo(x + 17, y - 20)
        ..lineTo(x + 40, y)
        ..close(),
      Paint()..color = const Color(0xFFB66E4D),
    );
    c.drawRect(
      Rect.fromLTWH(x + 13, y + 12, 10, 18),
      Paint()..color = const Color(0xFF54735B),
    );
    for (final dx in [.16, .34]) {
      final cx = s.width * dx, cy = s.height * .77;
      c.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: 35, height: 19),
        Paint()..color = Colors.white,
      );
      c.drawOval(
        Rect.fromCenter(center: Offset(cx - 8, cy - 2), width: 12, height: 12),
        Paint()..color = const Color(0xFF263D32),
      );
      c.drawOval(
        Rect.fromCenter(center: Offset(cx + 17, cy - 3), width: 10, height: 15),
        Paint()..color = const Color(0xFF263D32),
      );
      for (final leg in [-10.0, 10.0]) {
        c.drawLine(
          Offset(cx + leg, cy + 5),
          Offset(cx + leg, cy + 18),
          Paint()
            ..color = const Color(0xFF263D32)
            ..strokeWidth = 3,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FarmPainter old) => false;
}
