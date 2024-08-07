import 'package:flutter/material.dart';
import 'log_workout_screen.dart';
import 'history_screen.dart';
import 'exercise_database.dart'; // Import the new exercise loader file
import 'main_screen.dart'; // Import the new main screen file
import 'profile_screen.dart'; // Import the new profile screen file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadExercises(); // Load exercises from JSON
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _updateTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Logger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: HomeScreen(onThemeChanged: _updateTheme),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final void Function(ThemeMode) onThemeChanged;

  HomeScreen({required this.onThemeChanged});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  WorkoutSession? _currentSession;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _startNewWorkoutSession() {
    setState(() {
      _currentSession = WorkoutSession(name: '', startTime: DateTime.now(), workouts: []);
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LogWorkoutScreen(onSessionEnd: _endSession)),
    );
  }

  void _endSession() {
    setState(() {
      _currentSession = null;
    });
  }

  List<Widget> _widgetOptions() => <Widget>[
        MainScreen(
          onStartNewWorkout: _startNewWorkoutSession,
          onResumeWorkout: _currentSession != null ? _resumeWorkoutSession : null,
        ),
        HistoryScreen(),
        ProfileScreen(onThemeChanged: widget.onThemeChanged),
      ];

  void _resumeWorkoutSession() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LogWorkoutScreen(onSessionEnd: _endSession)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
