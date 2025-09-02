// widgets/city_selector.dart - Shahar tanlash dropdown
// Copyright (c) 2025 Afsona Makon MCHJ. All rights reserved.

import 'package:flutter/material.dart';
import '../models/prayer_models.dart';

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
