import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  final VoidCallback onStartNewWorkout;
  final VoidCallback? onResumeWorkout;

  MainScreen({required this.onStartNewWorkout, this.onResumeWorkout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onStartNewWorkout,
              child: Text('Start New Workout'),
            ),
            if (onResumeWorkout != null)
              ElevatedButton(
                onPressed: onResumeWorkout,
                child: Text('Resume Workout'),
              ),
          ],
        ),
      ),
    );
  }
}
