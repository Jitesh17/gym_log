import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final void Function(ThemeMode) onThemeChanged;

  ProfileScreen({required this.onThemeChanged});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  int _workoutCount = 0;

  @override
  void initState() {
    super.initState();
    _loadWorkoutCount();
  }

  void _loadWorkoutCount() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString('sessions');
    if (sessionsJson != null) {
      final sessionsList = jsonDecode(sessionsJson) as List;
      setState(() {
        _workoutCount = sessionsList.length;
      });
    }
  }

  void _setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    widget.onThemeChanged(themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _showThemeDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
            ),
            SizedBox(height: 16),
            Text(
              'User Name',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Number of Workouts: $_workoutCount',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Days Exercised:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Placeholder(
              fallbackHeight: 200,
              color: Colors.grey,
              strokeWidth: 2,
            ),
            SizedBox(height: 16),
            Text(
              'Weight: 0 kg',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Height: 0 cm',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Exercise Statistics:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Placeholder(
              fallbackHeight: 200,
              color: Colors.grey,
              strokeWidth: 2,
            ),
            SizedBox(height: 16),
            // Add more placeholders or actual widgets for additional stats/info
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Light'),
                leading: Radio<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: _themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      _setThemeMode(value);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text('Dark'),
                leading: Radio<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: _themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      _setThemeMode(value);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text('System'),
                leading: Radio<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: _themeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      _setThemeMode(value);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
