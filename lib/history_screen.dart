import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'log_workout_screen.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<WorkoutSession> _workoutHistory = [];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  void _loadWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString('sessions');
    if (sessionsJson != null) {
      final sessionsList = jsonDecode(sessionsJson) as List;
      setState(() {
        _workoutHistory = sessionsList.map((json) => WorkoutSession.fromJson(json)).toList();
      });
    }
  }

  void _deleteWorkoutSession(int index) async {
    setState(() {
      _workoutHistory.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    final updatedSessionsJson = jsonEncode(_workoutHistory.map((session) => session.toJson()).toList());
    prefs.setString('sessions', updatedSessionsJson);
  }

  Future<void> _exportToExcel() async {
    if (await Permission.storage.request().isGranted) {
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];

      sheet.getRangeByName('A1').setText('Date');
      sheet.getRangeByName('B1').setText('Time');
      sheet.getRangeByName('C1').setText('Duration (min)');
      sheet.getRangeByName('D1').setText('Volume (kg)');
      sheet.getRangeByName('E1').setText('Exercise');
      sheet.getRangeByName('F1').setText('Sets');

      int rowIndex = 2;
      for (var session in _workoutHistory) {
        for (var workout in session.workouts) {
          String sets = workout.sets.map((setController) => '${setController.set.weight}kg x ${setController.set.reps}').join(', ');
          sheet.getRangeByName('A$rowIndex').setText(session.startTime.toLocal().toString().split(' ')[0]);
          sheet.getRangeByName('B$rowIndex').setText('${session.startTime.toLocal().toString().split(' ')[1].substring(0, 5)} - ${session.endTime?.toLocal().toString().split(' ')[1].substring(0, 5) ?? 'In Progress'}');
          sheet.getRangeByName('C$rowIndex').setText(session.duration.inMinutes.toString());
          sheet.getRangeByName('D$rowIndex').setText(session.totalVolume.toString());
          sheet.getRangeByName('E$rowIndex').setText(workout.exercise.name);
          sheet.getRangeByName('F$rowIndex').setText(sets);
          rowIndex++;
        }
      }

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        final String path = '${directory.path}/WorkoutHistory.xlsx';
        final File file = File(path);
        await file.writeAsBytes(bytes, flush: true);
        await OpenFilex.open(path);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Exported to $path")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to get storage directory")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Storage permission denied")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout History'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: _exportToExcel,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _workoutHistory.length,
        itemBuilder: (context, index) {
          final session = _workoutHistory[index];
          return Card(
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${session.startTime.toLocal().toString().split(' ')[0]} ${session.startTime.toLocal().toString().split(' ')[1].substring(0, 5)} - ${session.endTime?.toLocal().toString().split(' ')[1].substring(0, 5) ?? 'In Progress'}'),
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      if (result == 'delete') {
                        _deleteWorkoutSession(index);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete Session'),
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: Text(
                  'Duration: ${session.duration.inMinutes} min, Volume: ${session.totalVolume} kg'),
              children: session.workouts
                  .map((workout) => ListTile(
                        title: Text(workout.exercise.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: workout.sets
                              .asMap()
                              .entries
                              .map((entry) {
                                int idx = entry.key;
                                SetController setController = entry.value;
                                return Text('Set ${idx + 1}: ${setController.set.weight} kg x ${setController.set.reps} reps');
                              })
                              .toList(),
                        ),
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
