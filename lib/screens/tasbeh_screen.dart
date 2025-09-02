// screens/tasbeh_screen.dart - VIBRATSIYA TUZATILGAN
// Asosiy o'zgarish: vibratsiya sozlamasini har safar tekshirish

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool vibrationEnabled = true; // YANGI: vibratsiya sozlamasi

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
      vibrationEnabled = prefs.getBool('vibration_enabled') ?? true; // YANGI

      for (String dhikr in dhikrTypes) {
        dhikrCounters[dhikr] = prefs.getInt('dhikr_$dhikr') ?? 0;
      }

      isLoading = false;
    });
  }

  // YANGI: Vibratsiya sozlamasini qayta yuklash
  Future<void> _checkVibrationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    });
  }

  Future<void> _saveCounters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbehCounter', counter);
    await prefs.setString('selectedDhikr', selectedDhikr);

    for (String dhikr in dhikrTypes) {
      await prefs.setInt('dhikr_$dhikr', dhikrCounters[dhikr]!);
    }
  }

  void _incrementCounter() async {
    // YANGI: Har safar vibratsiya sozlamasini tekshirish
    await _checkVibrationSetting();

    setState(() {
      counter++;
      dhikrCounters[selectedDhikr] = dhikrCounters[selectedDhikr]! + 1;

      // Vibratsiya faqat yoqilgan bo'lsa ishlaydi
      if (vibrationEnabled) {
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
        } else {
          // Har bosganda engil feedback
          HapticFeedback.selectionClick();
        }
      } else {
        // Vibratsiya o'chirilgan bo'lsa ham counter reset
        if (counter == 33) {
          counter = 0;
        }
      }
    });

    await _saveCounters();
  }

  void _resetCounter() async {
    // YANGI: Reset bosganda ham sozlamani tekshirish
    await _checkVibrationSetting();

    if (vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }

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
              await _checkVibrationSetting();
              if (vibrationEnabled) {
                HapticFeedback.heavyImpact();
              }

              setState(() {
                counter = 0;
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

  // YANGI: Screen ga qaytganda sozlamalarni yangilash
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkVibrationSetting();
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
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        await _checkVibrationSetting(); // YANGI
                        if (vibrationEnabled) {
                          HapticFeedback.selectionClick();
                        }
                        setState(() {
                          selectedDhikr = newValue;
                        });
                        _saveCounters();
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
                      onTap: _incrementCounter,
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
