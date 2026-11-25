// lib/widgets/season_badge.dart
import 'package:flutter/material.dart';

import '../utils/season.dart';

/// Картан дээрх улирлын өнгөт шошго.
class SeasonBadge extends StatelessWidget {
  const SeasonBadge({super.key, required this.season});

  final String season;

  @override
  Widget build(BuildContext context) {
    final s = seasonStyle(season);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: s.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            season,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
