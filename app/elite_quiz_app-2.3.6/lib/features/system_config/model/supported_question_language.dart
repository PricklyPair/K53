class QuizLanguage {
  const QuizLanguage({
    required this.id,
    required this.language,
    required this.languageCode,
    required this.isDefault,
  });

  QuizLanguage.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      language = json['language'] as String,
      languageCode = json['code'] as String,
      isDefault = (json['default_active'] as String) == '1';

  final String id;
  final String language;
  final String languageCode;
  final bool isDefault;
}
