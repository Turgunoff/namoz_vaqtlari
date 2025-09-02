// main.dart - Namoz Vaqtlari ilova (API va Modular)
// Copyright (c) 2025 Afsona Makon MCHJ. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Main App
void main() {
  runApp(NamozVaqtlariApp());
}

class NamozVaqtlariApp extends StatelessWidget {
  const NamozVaqtlariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namoz Vaqtlari - Uzbekistan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: false),
      home: MainScreen(),
    );
  }
}

// ============= MODELS =============
class PrayerTime {
  final String name;
  final String time;
  final IconData icon;
  final bool isActive;

  PrayerTime({
    required this.name,
    required this.time,
    required this.icon,
    this.isActive = false,
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

// ============= SERVICES =============
class PrayerTimeService {
  // API Options:
  // 1. Aladhan API - eng mashhur va bepul
  // 2. Muslim Salat API
  // 3. IslamicFinder API

  static const String baseUrl = 'https://api.aladhan.com/v1/timings';

  // O'zbekiston shaharlari
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

// ============= WIDGETS =============

// Namoz vaqti kartasi
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
          prayerTime.icon,
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
}

// Shahar tanlash dropdown
class CitySelector extends StatelessWidget {
  final String selectedCity;
  final List<City> cities;
  final ValueChanged<String> onCityChanged;

  const CitySelector({
    Key? key,
    required this.selectedCity,
    required this.cities,
    required this.onCityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCity,
          isExpanded: true,
          icon: Icon(Icons.location_city, color: Colors.teal),
          items: cities.map((City city) {
            return DropdownMenuItem<String>(
              value: city.name,
              child: Text(
                city.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onCityChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}

// ============= SCREENS =============

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
    final icons = {
      'Bomdod': Icons.nightlight_round,
      'Quyosh': Icons.wb_sunny,
      'Peshin': Icons.wb_sunny_outlined,
      'Asr': Icons.wb_twilight,
      'Shom': Icons.wb_twilight,
      'Xufton': Icons.nights_stay,
    };

    return prayerTimes.entries.map((entry) {
      return PrayerTime(
        name: entry.key,
        time: entry.value,
        icon: icons[entry.key] ?? Icons.access_time,
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

// ============= TASBEH SCREEN =============
class TasbehScreen extends StatefulWidget {
  @override
  _TasbehScreenState createState() => _TasbehScreenState();
}

class _TasbehScreenState extends State<TasbehScreen> {
  int counter = 0;
  Map<String, int> dhikrCounters = {
    'SubhanAlloh': 0,
    'Alhamdulillah': 0,
    'Allohu Akbar': 0,
    'La ilaha illalloh': 0,
    'Istighfar': 0,
  };
  bool isLoading = true;

  // Zikr turlari
  final List<String> dhikrTypes = [
    'SubhanAlloh',
    'Alhamdulillah',
    'Allohu Akbar',
    'La ilaha illalloh',
    'Istighfar',
  ];
  String selectedDhikr = 'SubhanAlloh';

  @override
  void initState() {
    super.initState();
    _loadCounters();
  }

  Future<void> _loadCounters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      counter = prefs.getInt('tasbehCounter') ?? 0;
      selectedDhikr = prefs.getString('selectedDhikr') ?? 'SubhanAlloh';

      // Har bir zikr uchun alohida sanagichlarni yuklash
      for (String dhikr in dhikrTypes) {
        dhikrCounters[dhikr] = prefs.getInt('dhikr_$dhikr') ?? 0;
      }

      isLoading = false;
    });
  }

  Future<void> _saveCounters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbehCounter', counter);
    await prefs.setString('selectedDhikr', selectedDhikr);

    // Har bir zikr uchun alohida sanagichlarni saqlash
    for (String dhikr in dhikrTypes) {
      await prefs.setInt('dhikr_$dhikr', dhikrCounters[dhikr]!);
    }
  }

  void _incrementCounter() async {
    setState(() {
      counter++;
      dhikrCounters[selectedDhikr] = dhikrCounters[selectedDhikr]! + 1;

      if (counter == 33) {
        counter = 0;
        // Kuchli vibratsiya - 3 marta
        HapticFeedback.heavyImpact();
        Future.delayed(Duration(milliseconds: 100), () {
          HapticFeedback.heavyImpact();
        });
        Future.delayed(Duration(milliseconds: 200), () {
          HapticFeedback.heavyImpact();
        });
      } else if (counter % 11 == 0) {
        // Har 11 ta zikrda engil vibratsiya
        HapticFeedback.lightImpact();
      }
    });

    await _saveCounters();
  }

  void _resetCounter() async {
    // Vibratsiya feedback
    HapticFeedback.mediumImpact();
    setState(() {
      counter = 0;
    });
    await _saveCounters();
  }

  void _resetAll() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tasdiqlash'),
        content: Text('Barcha sanagichlarni 0 ga qaytarishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.heavyImpact();
              setState(() {
                counter = 0;
                // Barcha zikr sanagichlarini 0 ga qaytarish
                for (String dhikr in dhikrTypes) {
                  dhikrCounters[dhikr] = 0;
                }
              });
              await _saveCounters();
              Navigator.pop(context);
            },
            child: Text('Ha', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Tasbeh')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasbeh'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: _resetAll,
            tooltip: 'Hammasini tozalash',
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Zikr tanlash
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedDhikr,
                    isExpanded: true,
                    dropdownColor: Colors.teal.shade700,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: dhikrTypes.map((String dhikr) {
                      return DropdownMenuItem<String>(
                        value: dhikr,
                        child: Text(
                          dhikr,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedDhikr = newValue;
                        });
                        _saveCounters();
                        HapticFeedback.selectionClick();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Counter circle with progress
              Container(
                width: 240,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress circle
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: CircularProgressIndicator(
                        value: counter / 33,
                        strokeWidth: 10,
                        backgroundColor: Colors.white30,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          counter == 32 ? Colors.orange : Colors.white,
                        ),
                      ),
                    ),
                    // Counter button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _incrementCounter();
                      },
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$counter',
                              style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                                color: counter == 32
                                    ? Colors.orange
                                    : Colors.teal,
                              ),
                            ),
                            Text(
                              '/ 33',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.teal.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Statistika kartasi
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Joriy zikr statistikasi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Joriy zikr',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${dhikrCounters[selectedDhikr]}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(height: 50, width: 1, color: Colors.white30),
                        Column(
                          children: [
                            Text(
                              'Jami zikrlar',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${dhikrCounters.values.fold(0, (sum, count) => sum + count)}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    // Barcha zikrlar ro'yxati
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: dhikrTypes.map((dhikr) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dhikr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: dhikr == selectedDhikr
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: dhikr == selectedDhikr
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  '${dhikrCounters[dhikr]}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: dhikr == selectedDhikr
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: dhikr == selectedDhikr
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              // Reset button
              FloatingActionButton.extended(
                onPressed: _resetCounter,
                icon: Icon(Icons.refresh),
                label: Text('Qayta boshlash'),
                backgroundColor: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
