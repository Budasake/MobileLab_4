// lib/utils/season.dart
import 'package:flutter/material.dart';

/// Улирал бүрийн дүрс, өнгө, шинж чанар.
class SeasonStyle {
  const SeasonStyle({
    required this.icon,
    required this.color,
    required this.temperature,
    required this.activities,
    required this.tip,
  });

  final IconData icon;
  final Color color;
  final String temperature; // Монголын ойролцоо дундаж
  final String activities;
  final String tip;
}

SeasonStyle seasonStyle(String season) => switch (season) {
      'Хавар' => const SeasonStyle(
          icon: Icons.local_florist,
          color: Color(0xFF43A047),
          temperature: '−5°C ~ +15°C',
          activities: 'Цэцэг ногоо, шувуу ажиглалт, байгалийн алхалт',
          tip: 'Салхи ихтэй, өдөр шөнийн температур их зөрнө.',
        ),
      'Зун' => const SeasonStyle(
          icon: Icons.wb_sunny,
          color: Color(0xFFF9A825),
          temperature: '+15°C ~ +30°C',
          activities: 'Морин аялал, нуурын аялал, зуслан, Наадам',
          tip: 'Аяллын оргил үе, байр захиалгыг түрүүлж хий.',
        ),
      'Намар' => const SeasonStyle(
          icon: Icons.eco,
          color: Color(0xFFEF6C00),
          temperature: '−5°C ~ +15°C',
          activities: 'Алтан намрын зураг авалт, загасчлал, ой дундуур алхах',
          tip: 'Шөнө хүйтэрнэ, дулаан хувцас авч яв.',
        ),
      'Өвөл' => const SeasonStyle(
          icon: Icons.ac_unit,
          color: Color(0xFF1E88E5),
          temperature: '−30°C ~ −10°C',
          activities: 'Мөсөн нуур, цанын аялал, цасан тоглоом',
          tip: 'Маш хүйтэн, зам цасжиж болно, бэлтгэлтэй яв.',
        ),
      _ => const SeasonStyle(
          icon: Icons.calendar_today,
          color: Colors.grey,
          temperature: '—',
          activities: '—',
          tip: '',
        ),
    };
