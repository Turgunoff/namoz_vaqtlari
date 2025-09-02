// screens/settings_screen.dart - Sozlamalar ekrani
// Copyright (c) 2025 Afsona Makon MCHJ. All rights reserved.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _vibrationEnabled = true;
  bool _soundEnabled = false;
  String _selectedLanguage = 'O\'zbek';
  String _selectedTheme = 'Teal';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? false;
      _selectedLanguage = prefs.getString('selected_language') ?? 'O\'zbek';
      _selectedTheme = prefs.getString('selected_theme') ?? 'Teal';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setString('selected_language', _selectedLanguage);
    await prefs.setString('selected_theme', _selectedTheme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sozlamalar'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal, Colors.teal.shade100],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Bildirishnomalar bo'limi
            _buildSectionCard(
              title: 'Bildirishnomalar',
              icon: Icons.notifications,
              children: [
                _buildSwitchTile(
                  title: 'Namoz vaqti bildirishnomalari',
                  subtitle: 'Namoz vaqtida eslatma',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildSwitchTile(
                  title: 'Vibratsiya',
                  subtitle: 'Tasbeh va bildirishnomalarda',
                  value: _vibrationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _vibrationEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildSwitchTile(
                  title: 'Ovoz',
                  subtitle: 'Bildirishnoma ovozlari',
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),

            SizedBox(height: 16),

            // Til va mavzu bo'limi
            _buildSectionCard(
              title: 'Til va Mavzu',
              icon: Icons.language,
              children: [
                _buildListTile(
                  title: 'Til',
                  subtitle: _selectedLanguage,
                  icon: Icons.translate,
                  onTap: () => _showLanguageDialog(),
                ),
                _buildListTile(
                  title: 'Mavzu',
                  subtitle: _selectedTheme,
                  icon: Icons.palette,
                  onTap: () => _showThemeDialog(),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Ma'lumotlar bo'limi
            _buildSectionCard(
              title: 'Ma\'lumotlar',
              icon: Icons.storage,
              children: [
                _buildListTile(
                  title: 'Cache tozalash',
                  subtitle: 'Saqlangan ma\'lumotlarni tozalash',
                  icon: Icons.delete_sweep,
                  onTap: () => _showClearCacheDialog(),
                ),
                _buildListTile(
                  title: 'Ma\'lumotlarni qayta yuklash',
                  subtitle: 'Namoz vaqtlarini yangilash',
                  icon: Icons.refresh,
                  onTap: () => _refreshData(),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Ilova haqida bo'limi
            _buildSectionCard(
              title: 'Ilova haqida',
              icon: Icons.info,
              children: [
                _buildListTile(
                  title: 'Versiya',
                  subtitle: '1.0.0',
                  icon: Icons.info_outline,
                  onTap: null,
                ),
                _buildListTile(
                  title: 'Rivojlantiruvchi',
                  subtitle: 'Afsona Makon MCHJ',
                  icon: Icons.business,
                  onTap: null,
                ),
                _buildListTile(
                  title: 'Aloqa',
                  subtitle: 'afsonamakonmchj@gmail.com',
                  icon: Icons.email,
                  onTap: () => _showContactDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.teal.shade700),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.teal,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null ? Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Til tanlash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text('O\'zbek'),
              value: 'O\'zbek',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                _saveSettings();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                _saveSettings();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mavzu tanlash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text('Teal'),
              value: 'Teal',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                _saveSettings();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text('Blue'),
              value: 'Blue',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                _saveSettings();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text('Green'),
              value: 'Green',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                _saveSettings();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cache tozalash'),
        content: Text(
          'Barcha saqlangan ma\'lumotlarni o\'chirishni xohlaysizmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Cache tozalandi')));
            },
            child: Text('Tozalash', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _refreshData() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Ma\'lumotlar yangilandi')));
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aloqa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Afsona Makon MCHJ'),
            SizedBox(height: 8),
            Text('Email: afsonamakonmchj@gmail.com'),
            SizedBox(height: 8),
            Text('Telegram: @afsonamakon'),
            SizedBox(height: 8),
            Text('Telefon: +998 90 123 45 67'),
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
