import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool showDot;
  final Color dotColor;
  final VoidCallback? onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.showDot = false,
    this.dotColor = AppColors.limeDark,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          if (showDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
          ],
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
              letterSpacing: 0.4,
              color: AppColors.ink,
            ),
          ),
          const Spacer(),
          if (onViewAll != null)
            InkWell(
              onTap: onViewAll,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        size: 18, color: AppColors.muted),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
