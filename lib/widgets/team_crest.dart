import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/match_model.dart';

/// Logo tim dari jaringan, dengan fallback lingkaran berisi singkatan tim.
class TeamCrest extends StatelessWidget {
  final Team team;
  final double size;

  const TeamCrest({super.key, required this.team, this.size = 40});

  Widget _fallback() {
    final text = team.abbr.isNotEmpty
        ? team.abbr
        : (team.shortName.isNotEmpty ? team.shortName.substring(0, 1) : '?');
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.border,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: size * 0.28,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: team.logo.isEmpty
          ? _fallback()
          : Image.network(
              team.logo,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _fallback(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : _fallback(),
            ),
    );
  }
}
