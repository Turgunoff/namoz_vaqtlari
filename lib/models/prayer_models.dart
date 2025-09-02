// models/prayer_models.dart - Namoz vaqtlari modellari
// Copyright (c) 2025 Afsona Makon MCHJ. All rights reserved.

class PrayerTime {
  final String name;
  final String time;
  final bool isActive;
  final bool isNextTime;

  PrayerTime({
    required this.name,
    required this.time,
    this.isActive = false,
    this.isNextTime = false,
  });
}

class City {
  final String name;
  final double latitude;
  final double longitude;
  final int timezone;

  City({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.timezone = 5,
  });
}
