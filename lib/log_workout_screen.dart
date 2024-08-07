import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'exercise_database.dart';

class LogWorkoutScreen extends StatefulWidget {
  @override
  _LogWorkoutScreenState createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  WorkoutSession? _currentSession;

  @override
  void initState() {
    super.initState();
    _loadCurrentSession();
  }

  void _startNewSession() {
    setState(() {
      _currentSession = WorkoutSession(startTime: DateTime.now(), workouts: []);
    });
    _saveCurrentSession();
  }

  void _endSession() async {
    if (_currentSession == null) return;

    setState(() {
      _currentSession!.endTime = DateTime.now();
    });

    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString('sessions');
    List<WorkoutSession> sessions = sessionsJson != null
        ? (jsonDecode(sessionsJson) as List).map((json) => WorkoutSession.fromJson(json)).toList()
        : [];
    sessions.add(_currentSession!);

    final updatedSessionsJson = jsonEncode(sessions.map((session) => session.toJson()).toList());
    prefs.setString('sessions', updatedSessionsJson);

    _startNewSession();
  }

  void _deleteCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('current_session');
    setState(() {
      _currentSession = null;
    });
  }

  void _addWorkout(Exercise exercise) {
    setState(() {
      _currentSession!.workouts.add(Workout(
        exercise: exercise,
        sets: [SetController(Set(weight: 0, reps: 0))],
        dateTime: DateTime.now(),
      ));
    });
    _saveCurrentSession();
  }

  void _deleteWorkout(int index) {
    setState(() {
      _currentSession!.workouts.removeAt(index);
    });
    _saveCurrentSession();
  }

  void _addSetToWorkout(Workout workout) {
    setState(() {
      workout.sets.add(SetController(Set(weight: 0, reps: 0)));
    });
    _saveCurrentSession();
  }

  void _deleteSetFromWorkout(Workout workout, int index) {
    setState(() {
      workout.sets.removeAt(index);
    });
    _saveCurrentSession();
  }

  void _updateSetInWorkout(Workout workout, int index, Set updatedSet) {
    setState(() {
      workout.sets[index].set = updatedSet;
    });
    _saveCurrentSession();
  }

  void _saveCurrentSession() async {
    if (_currentSession != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('current_session', jsonEncode(_currentSession!.toJson()));
    }
  }

  void _loadCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('current_session');
    if (sessionJson != null) {
      setState(() {
        _currentSession = WorkoutSession.fromJson(jsonDecode(sessionJson));
      });
    } else {
      _startNewSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Workout'),
        actions: [
          ElevatedButton(
            onPressed: _endSession,
            child: Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton(
            onPressed: _deleteCurrentSession,
            child: Text('Delete Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _currentSession?.workouts.length ?? 0,
              itemBuilder: (context, index) {
                final workout = _currentSession!.workouts[index];
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(workout.exercise.name),
                        subtitle: Text(workout.exercise.description),
                        trailing: PopupMenuButton<String>(
                          onSelected: (String result) {
                            if (result == 'delete') {
                              _deleteWorkout(index);
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete Exercise'),
                            ),
                          ],
                        ),
                      ),
                      ...workout.sets.asMap().entries.map((entry) {
                        int idx = entry.key;
                        SetController setController = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Weight (kg)',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      _updateSetInWorkout(workout, idx, Set(weight: int.parse(value), reps: setController.set.reps));
                                    }
                                  },
                                  controller: setController.weightController,
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Reps',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      _updateSetInWorkout(workout, idx, Set(weight: setController.set.weight, reps: int.parse(value)));
                                    }
                                  },
                                  controller: setController.repsController,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteSetFromWorkout(workout, idx),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      ElevatedButton(
                        onPressed: () {
                          _addSetToWorkout(workout);
                        },
                        child: Text('Add Set'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _showAddExerciseDialog(context);
            },
            child: Text('Add Exercise'),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    List<Exercise> filteredExercises = exerciseDatabase;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Exercise'),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Exercises',
                      ),
                      onChanged: (query) {
                        setState(() {
                          filteredExercises = exerciseDatabase
                              .where((exercise) =>
                                  exercise.name.toLowerCase().contains(query.toLowerCase()) ||
                                  exercise.category.toLowerCase().contains(query.toLowerCase()) ||
                                  exercise.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
                              .toList();
                        });
                      },
                    ),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = filteredExercises[index];
                          return ListTile(
                            leading: Image.asset(exercise.imagePath),
                            title: Text(exercise.name),
                            subtitle: Text(exercise.category),
                            onTap: () {
                              _addWorkout(exercise);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class WorkoutSession {
  final DateTime startTime;
  DateTime? endTime;
  final List<Workout> workouts;

  WorkoutSession({required this.startTime, required this.workouts, this.endTime});

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'workouts': workouts.map((workout) => workout.toJson()).toList(),
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      workouts: (json['workouts'] as List).map((workoutJson) => Workout.fromJson(workoutJson)).toList(),
    );
  }

  Duration get duration {
    if (endTime == null) return Duration.zero;
    return endTime!.difference(startTime);
  }

  double get totalVolume {
    return workouts.fold(0, (sum, workout) {
      return sum + workout.sets.fold(0, (sum, setController) => sum + setController.set.weight * setController.set.reps);
    });
  }
}

class Workout {
  final Exercise exercise;
  final DateTime dateTime;
  List<SetController> sets;

  Workout({required this.exercise, required this.sets, required this.dateTime});

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.name,
      'dateTime': dateTime.toIso8601String(),
      'sets': sets.map((setController) => setController.set.toJson()).toList(),
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      exercise: exerciseDatabase.firstWhere((exercise) => exercise.name == json['exercise']),
      sets: (json['sets'] as List).map((setJson) => SetController(Set.fromJson(setJson))).toList(),
      dateTime: DateTime.parse(json['dateTime']),
    );
  }
}

class Set {
  final int weight;
  final int reps;

  Set({required this.weight, required this.reps});

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'reps': reps,
    };
  }

  factory Set.fromJson(Map<String, dynamic> json) {
    return Set(
      weight: json['weight'],
      reps: json['reps'],
    );
  }
}

class SetController {
  Set set;
  TextEditingController weightController;
  TextEditingController repsController;

  SetController(this.set)
      : weightController = TextEditingController(text: set.weight.toString()),
        repsController = TextEditingController(text: set.reps.toString());
}
