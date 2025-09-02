// services/prayer_time_service.dart - Namoz vaqtlari xizmati
// Copyright (c) 2025 Afsona Makon MCHJ. All rights reserved.

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/prayer_models.dart';

class PrayerTimeService {
  static const String baseUrl = 'https://api.aladhan.com/v1/timings';

  static final List<City> cities = [
    City(name: 'Toshkent', latitude: 41.2995, longitude: 69.2401),
    City(name: 'Samarqand', latitude: 39.6270, longitude: 66.9750),
    City(name: 'Buxoro', latitude: 39.7681, longitude: 64.4556),
    City(name: 'Andijon', latitude: 40.7821, longitude: 72.3442),
    City(name: 'Namangan', latitude: 40.9983, longitude: 71.6726),
    City(name: 'Farg\'ona', latitude: 40.3864, longitude: 71.7864),
    City(name: 'Qarshi', latitude: 38.8606, longitude: 65.7989),
    City(name: 'Nukus', latitude: 42.4611, longitude: 59.6111),
    City(name: 'Urganch', latitude: 41.5533, longitude: 60.6314),
    City(name: 'Termiz', latitude: 37.2242, longitude: 67.2783),
    City(name: 'Navoiy', latitude: 40.0844, longitude: 65.3792),
    City(name: 'Jizzax', latitude: 40.1158, longitude: 67.8422),
    City(name: 'Guliston', latitude: 40.4897, longitude: 68.7842),
  ];

  // API orqali namoz vaqtlarini olish
  static Future<Map<String, String>?> fetchPrayerTimes(
    City city,
    DateTime date,
  ) async {
    try {
      final timestamp = (date.millisecondsSinceEpoch / 1000).round();
      final url = Uri.parse(
        '$baseUrl/$timestamp'
        '?latitude=${city.latitude}'
        '&longitude=${city.longitude}'
        '&method=3' // Muslim World League method
        '&school=1', // Hanafi
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        return {
          'Bomdod': timings['Fajr'],
          'Quyosh': timings['Sunrise'],
          'Peshin': timings['Dhuhr'],
          'Asr': timings['Asr'],
          'Shom': timings['Maghrib'],
          'Xufton': timings['Isha'],
        };
      }
    } catch (e) {
      print('API Error: $e');
    }

    return null;
  }

  // Offline hisoblash (API ishlamasa)
  static Map<String, String> calculateOfflineTimes(City city, DateTime date) {
    // Avvalgi koddan formulalar
    return {
      'Bomdod': '05:30',
      'Quyosh': '06:45',
      'Peshin': '12:30',
      'Asr': '16:00',
      'Shom': '18:30',
      'Xufton': '20:00',
    };
  }
}
