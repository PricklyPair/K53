class LearningSection {
  const LearningSection({
    required this.id,
    required this.title,
    required this.description,
    required this.totalQuestions,
    required this.completedQuestions,
    required this.correctAnswers,
    required this.isUnlocked,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String description;
  final int totalQuestions;
  final int completedQuestions;
  final int correctAnswers;
  final bool isUnlocked;
  final String icon;
  final int color;

  double get progress =>
      totalQuestions > 0 ? completedQuestions / totalQuestions : 0.0;

  double get accuracy =>
      completedQuestions > 0 ? correctAnswers / completedQuestions : 0.0;

  bool get isComplete => progress >= 0.8 && accuracy >= 0.7;

  bool get isInProgress => completedQuestions > 0 && !isComplete;

  String get statusText {
    if (isComplete) return 'Completed';
    if (isInProgress) return 'In Progress';
    if (!isUnlocked) return 'Locked';
    return 'Start Learning';
  }

  LearningSection copyWith({
    String? id,
    String? title,
    String? description,
    int? totalQuestions,
    int? completedQuestions,
    int? correctAnswers,
    bool? isUnlocked,
    String? icon,
    int? color,
  }) {
    return LearningSection(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      completedQuestions: completedQuestions ?? this.completedQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
