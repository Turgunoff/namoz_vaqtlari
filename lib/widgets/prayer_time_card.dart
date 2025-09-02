// widgets/prayer_time_card.dart - Namoz vaqti kartasi
// Copyright (c) 2025 Afsona Makon MCHJ. All rights reserved.

import 'package:flutter/material.dart';
import '../models/prayer_models.dart';

class PrayerTimeCard extends StatelessWidget {
  final PrayerTime prayerTime;

  const PrayerTimeCard({Key? key, required this.prayerTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Keyingi namoz vaqti uchun maxsus ranglar
    final isNextTime = prayerTime.isNextTime;
    final isActive = prayerTime.isActive;

    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    Color textColor;
    Color timeColor;
    double borderWidth;

    if (isActive) {
      // Hozirgi faol namoz vaqti
      backgroundColor = Colors.teal.shade50;
      borderColor = Colors.teal;
      iconColor = Colors.teal.shade700;
      textColor = Colors.teal.shade700;
      timeColor = Colors.teal.shade900;
      borderWidth = 2;
    } else if (isNextTime) {
      // Keyingi namoz vaqti - oltin rangda
      backgroundColor = Colors.orange.shade50;
      borderColor = Colors.orange;
      iconColor = Colors.orange.shade700;
      textColor = Colors.orange.shade700;
      timeColor = Colors.orange.shade900;
      borderWidth = 2;
    } else {
      // Oddiy namoz vaqti
      backgroundColor = Colors.white;
      borderColor = Colors.transparent;
      iconColor = Colors.teal;
      textColor = Colors.black87;
      timeColor = Colors.teal.shade700;
      borderWidth = 0;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: borderWidth > 0
            ? Border.all(color: borderColor, width: borderWidth)
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
          color: iconColor,
          size: 30,
        ),
        title: Text(
          prayerTime.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        trailing: Text(
          prayerTime.time,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: timeColor,
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
        return Icons.brightness_4;
      case 'Xufton':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
}
