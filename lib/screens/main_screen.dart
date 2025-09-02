// screens/main_screen.dart - Asosiy ekran
// Copyright (c) 2025 Afsona Makon MCHJ. All rights reserved.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_models.dart';
import '../services/prayer_time_service.dart';
import '../widgets/prayer_time_card.dart';
import '../widgets/city_selector.dart';

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
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    String? nextPrayerName = _getNextPrayerTime(currentMinutes);

    return prayerTimes.entries.map((entry) {
      return PrayerTime(
        name: entry.key,
        time: entry.value,
        isActive: _isActiveTime(entry.value),
        isNextTime: entry.key == nextPrayerName,
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

  String? _getNextPrayerTime(int currentMinutes) {
    if (currentDate.day != DateTime.now().day) return null;

    // Namoz vaqtlari tartibini belgilash
    final prayerOrder = ['Bomdod', 'Quyosh', 'Peshin', 'Asr', 'Shom', 'Xufton'];

    // Hozirgi vaqtdan keyingi namoz vaqtini topish
    for (String prayerName in prayerOrder) {
      if (prayerTimes.containsKey(prayerName)) {
        try {
          final parts = prayerTimes[prayerName]!.split(':');
          final prayerMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);

          // Agar namoz vaqti hozirgi vaqtdan keyin bo'lsa
          if (prayerMinutes > currentMinutes) {
            return prayerName;
          }
        } catch (e) {
          continue;
        }
      }
    }

    // Agar bugun barcha namoz vaqtlari o'tib ketgan bo'lsa, ertangi Bomdod
    return 'Bomdod';
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

            // // Tasbeh tugmasi
            // Container(
            //   margin: EdgeInsets.all(16),
            //   child: ElevatedButton.icon(
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (context) => TasbehScreen()),
            //       );
            //     },
            //     icon: Icon(Icons.fiber_smart_record),
            //     label: Text('Tasbeh', style: TextStyle(fontSize: 18)),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.white,
            //       foregroundColor: Colors.teal,
            //       padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(30),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
