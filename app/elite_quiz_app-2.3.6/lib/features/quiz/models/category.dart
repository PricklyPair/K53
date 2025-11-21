class Category {
  const Category({
    required this.isPlayed,
    required this.requiredCoins,
    required this.subcategoriesCount,
    required this.questionsCount,
    this.languageId,
    this.categoryName,
    this.image,
    this.maxLevel,
    this.isPremium = false,
    this.hasUnlocked = false,
    this.id,
  });

  Category.fromJson(Map<String, dynamic> json)
    : isPlayed = (json['is_play'] as String? ?? '1') == '1',
      id = json['id'] as String?,
      languageId = json['language_id'] as String?,
      categoryName = json['category_name'] as String?,
      image = json['image'] as String?,
      subcategoriesCount = int.parse(json['no_of'] as String? ?? '0'),
      questionsCount = int.parse(json['no_of_que'] as String? ?? '0'),
      maxLevel = json['maxlevel'] as String?,
      isPremium = (json['is_premium'] ?? '0') == '1',
      hasUnlocked = (json['has_unlocked'] ?? '0') == '1',
      requiredCoins = int.parse(json['coins'] as String? ?? '0');

  final String? id;
  final String? languageId;
  final String? categoryName;
  final String? image;
  final int subcategoriesCount;
  final int questionsCount;
  final String? maxLevel;
  final bool isPlayed;
  final bool isPremium;
  final bool hasUnlocked;
  final int requiredCoins;

  bool get hasSubcategories => subcategoriesCount > 0;

  bool get hasQuestions => questionsCount > 0;
  bool get hasLevels => maxLevel != '0';

  Category copyWith({bool? hasUnlocked}) {
    return Category(
      isPlayed: isPlayed,
      id: id,
      languageId: languageId,
      categoryName: categoryName,
      image: image,
      subcategoriesCount: subcategoriesCount,
      questionsCount: questionsCount,
      maxLevel: maxLevel,
      isPremium: isPremium,
      hasUnlocked: hasUnlocked ?? this.hasUnlocked,
      requiredCoins: requiredCoins,
    );
  }
}
