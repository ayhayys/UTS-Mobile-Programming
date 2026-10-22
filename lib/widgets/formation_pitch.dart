import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/match_detail_model.dart';
import '../models/match_model.dart';

class FormationPitch extends StatelessWidget {
  final Team homeTeam;
  final Team awayTeam;
  final TeamLineup? home;
  final TeamLineup? away;

  const FormationPitch({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.home,
    required this.away,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.7,
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final h = box.maxHeight;
          final markers = <Widget>[
            ..._place(away, isHome: false, w: w, h: h),
            ..._place(home, isHome: true, w: w, h: h),
          ];
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _PitchPainter())),
                Positioned(
                  top: 14,
                  left: 14,
                  child: _FormationTag(
                    '${awayTeam.abbr.isEmpty ? 'AWAY' : awayTeam.abbr}  ${away?.formation ?? '-'}',
                  ),
                ),
                Positioned(
                  bottom: 14,
                  left: 14,
                  child: _FormationTag(
                    '${homeTeam.abbr.isEmpty ? 'HOME' : homeTeam.abbr}  ${home?.formation ?? '-'}',
                  ),
                ),
                ...markers,
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _place(TeamLineup? lineup,
      {required bool isHome, required double w, required double h}) {
    final rows = lineup?.formationRows;
    if (lineup == null || rows == null) return const [];

    final starters = lineup.starters;
    final lines = <List<LineupPlayer>>[
      [starters[0]],
    ];
    var cursor = 1;
    for (final count in rows) {
      lines.add(starters.sublist(cursor, cursor + count));
      cursor += count;
    }

    final gk = isHome ? 0.92 : 0.08;
    final front = isHome ? 0.58 : 0.42;
    final widgets = <Widget>[];

    for (var i = 0; i < lines.length; i++) {
      final yFrac = gk + (front - gk) * (i / (lines.length - 1));
      var line = lines[i];
      if (!isHome) line = line.reversed.toList();
      for (var j = 0; j < line.length; j++) {
        final xFrac = (j + 1) / (line.length + 1);
        widgets.add(Positioned(
          left: w * xFrac - 31,
          top: h * yFrac - 17,
          width: 62,
          child: _PlayerMarker(player: line[j], isHome: isHome),
        ));
      }
    }
    return widgets;
  }
}

class _PlayerMarker extends StatelessWidget {
  final LineupPlayer player;
  final bool isHome;
  const _PlayerMarker({required this.player, required this.isHome});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isHome ? AppColors.lime : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.ink, width: 1.2),
          ),
          child: Text(
            player.jersey,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          player.shortName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black54, blurRadius: 3)],
          ),
        ),
      ],
    );
  }
}

class _FormationTag extends StatelessWidget {
  final String text;
  const _FormationTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(110),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2F8034), Color(0xFF256B2A)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bg);

    final stripe = Paint()..color = const Color(0x14FFFFFF);
    const stripes = 8;
    for (var i = 0; i < stripes; i += 2) {
      canvas.drawRect(Rect.fromLTWH(0, h / stripes * i, w, h / stripes), stripe);
    }

    final line = Paint()
      ..color = const Color(0xB3FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const m = 10.0;

    canvas.drawRect(Rect.fromLTRB(m, m, w - m, h - m), line);
    canvas.drawLine(Offset(m, h / 2), Offset(w - m, h / 2), line);
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.13, line);

    final boxW = w * 0.5;
    final boxH = h * 0.13;
    canvas.drawRect(Rect.fromLTWH((w - boxW) / 2, m, boxW, boxH), line);
    canvas.drawRect(Rect.fromLTWH((w - boxW) / 2, h - m - boxH, boxW, boxH), line);

    final goalW = w * 0.24;
    final goalH = h * 0.05;
    canvas.drawRect(Rect.fromLTWH((w - goalW) / 2, m, goalW, goalH), line);
    canvas.drawRect(Rect.fromLTWH((w - goalW) / 2, h - m - goalH, goalW, goalH), line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
