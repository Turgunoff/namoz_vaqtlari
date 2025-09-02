// widgets/prayer_time_card.dart - Namoz vaqti kartasi
// Copyright (c) 2025 Afsona Makon MCHJ. All rights reserved.

import 'package:flutter/material.dart';
import '../models/prayer_models.dart';

class PrayerTimeCard extends StatelessWidget {
  final PrayerTime prayerTime;

  const PrayerTimeCard({Key? key, required this.prayerTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: prayerTime.isActive ? Colors.teal.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: prayerTime.isActive
            ? Border.all(color: Colors.teal, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          _getIconForPrayer(prayerTime.name),
          color: prayerTime.isActive ? Colors.teal.shade700 : Colors.teal,
          size: 30,
        ),
        title: Text(
          prayerTime.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: prayerTime.isActive ? Colors.teal.shade700 : null,
          ),
        ),
        trailing: Text(
          prayerTime.time,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: prayerTime.isActive
                ? Colors.teal.shade900
                : Colors.teal.shade700,
          ),
        ),
      ),
    );
  }

  IconData _getIconForPrayer(String prayerName) {
    switch (prayerName) {
      case 'Bomdod':
        return Icons.nightlight_round;
      case 'Quyosh':
        return Icons.wb_sunny;
      case 'Peshin':
        return Icons.wb_sunny_outlined;
      case 'Asr':
        return Icons.wb_twilight;
      case 'Shom':
        return Icons.wb_twilight;
      case 'Xufton':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
}
