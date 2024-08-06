class Exercise {
  final String name;
  final String description;
  final String category;
  final String imagePath;

  Exercise({
    required this.name,
    required this.description,
    required this.category,
    required this.imagePath,
  });
}

List<Exercise> exerciseDatabase = [
  Exercise(
      name: 'Bench Press',
      description: 'Chest exercise',
      category: 'Chest',
      imagePath: 'assets/images/bench_press.png'),
  Exercise(
      name: 'Squat',
      description: 'Leg exercise',
      category: 'Legs',
      imagePath: 'assets/images/squat.png'),
  Exercise(
      name: 'Deadlift',
      description: 'Back exercise',
      category: 'Back',
      imagePath: 'assets/images/deadlift.png'),
  // Add more exercises with appropriate categories and images
];
