import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Exercise {
  final String name;
  final String description;
  final String category;
  final String imagePath;
  final List<String> tags;

  Exercise({
    required this.name,
    required this.description,
    required this.category,
    required this.imagePath,
    required this.tags,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      description: json['description'],
      category: json['category'],
      imagePath: json['imagePath'],
      tags: List<String>.from(json['tags']),
    );
  }
}

List<Exercise> exerciseDatabase = [];

Future<void> loadExercises() async {
  final String response = await rootBundle.loadString('assets/exercises.json');
  final List<dynamic> data = json.decode(response);
  exerciseDatabase = data.map((json) => Exercise.fromJson(json)).toList();
}
