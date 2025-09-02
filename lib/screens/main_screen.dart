// screens/main_screen.dart - Asosiy ekran
// Copyright (c) 2025 Afsona Makon MCHJ. All rights reserved.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_models.dart';
import '../services/prayer_time_service.dart';
import '../widgets/prayer_time_card.dart';
import '../widgets/city_selector.dart';
import 'tasbeh_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String selectedCityName = 'Toshkent';
  DateTime currentDate = DateTime.now();
  Map<String, String> prayerTimes = {};
  bool isLoading = false;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCityName = prefs.getString('selectedCity') ?? 'Toshkent';
    });
    _loadPrayerTimes();
  }

  Future<void> _saveCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', city);
  }

  City get selectedCity => PrayerTimeService.cities.firstWhere(
    (city) => city.name == selectedCityName,
  );

  Future<void> _loadPrayerTimes() async {
    setState(() {
      isLoading = true;
    });

    // Avval API orqali urinib ko'ramiz
    final apiTimes = await PrayerTimeService.fetchPrayerTimes(
      selectedCity,
      currentDate,
    );

    setState(() {
      if (apiTimes != null) {
        prayerTimes = apiTimes;
        isOffline = false;
      } else {
        // API ishlamasa, offline hisoblash
        prayerTimes = PrayerTimeService.calculateOfflineTimes(
          selectedCity,
          currentDate,
        );
        isOffline = true;
      }
      isLoading = false;
    });
  }

  List<PrayerTime> getPrayerTimesList() {
    return prayerTimes.entries.map((entry) {
      return PrayerTime(
        name: entry.key,
        time: entry.value,
        isActive: _isActiveTime(entry.value),
      );
    }).toList();
  }

  bool _isActiveTime(String timeStr) {
    if (currentDate.day != DateTime.now().day) return false;

    try {
      final parts = timeStr.split(':');
      final prayerMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      final now = DateTime.now();
      final currentMinutes = now.hour * 60 + now.minute;
      return (currentMinutes - prayerMinutes).abs() < 60;
    } catch (e) {
      return false;
    }
  }

  String getFormattedDate() {
    final months = [
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktabr',
      'Noyabr',
      'Dekabr',
    ];

    final weekDays = [
      'Dushanba',
      'Seshanba',
      'Chorshanba',
      'Payshanba',
      'Juma',
      'Shanba',
      'Yakshanba',
    ];

    int weekDay = currentDate.weekday - 1;
    return '${weekDays[weekDay]}, ${currentDate.day} ${months[currentDate.month - 1]} ${currentDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Namoz Vaqtlari'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (isOffline)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.wifi_off, color: Colors.white70),
            ),
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadPrayerTimes),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal, Colors.teal.shade100],
          ),
        ),
        child: Column(
          children: [
            // Shahar tanlash
            CitySelector(
              selectedCity: selectedCityName,
              cities: PrayerTimeService.cities,
              onCityChanged: (city) {
                setState(() {
                  selectedCityName = city;
                });
                _saveCity(city);
                _loadPrayerTimes();
              },
            ),

            // Sana
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    getFormattedDate(),
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: currentDate,
                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (picked != null && picked != currentDate) {
                        setState(() {
                          currentDate = picked;
                        });
                        _loadPrayerTimes();
                      }
                    },
                    icon: Icon(Icons.calendar_today, color: Colors.white70),
                    label: Text(
                      'Boshqa sana',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),

            // Namoz vaqtlari ro'yxati
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPrayerTimes,
                      child: ListView(
                        padding: EdgeInsets.all(16),
                        children: getPrayerTimesList()
                            .map((pt) => PrayerTimeCard(prayerTime: pt))
                            .toList(),
                      ),
                    ),
            ),

            // Tasbeh tugmasi
            Container(
              margin: EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TasbehScreen()),
                  );
                },
                icon: Icon(Icons.fiber_smart_record),
                label: Text('Tasbeh', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ilova haqida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Namoz Vaqtlari - Uzbekistan'),
            SizedBox(height: 8),
            Text('Versiya: 1.0.0'),
            SizedBox(height: 8),
            Text('© 2025 Afsona Makon MCHJ'),
            SizedBox(height: 16),
            Text(
              'Ma\'lumotlar Aladhan.com API orqali\nolinadi yoki offline hisoblanadi.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Aloqa:\nafsonamakonmchj@gmail.com',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
