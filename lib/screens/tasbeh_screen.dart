// screens/tasbeh_screen.dart - Tasbeh ekrani
// Copyright (c) 2025 Afsona Makon MCHJ. All rights reserved.

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
