class SystemLanguage {
  const SystemLanguage({
    required this.name,
    required this.title,
    required this.isRTL,
    required this.version,
    required this.isDefault,
    this.translations,
  });

  SystemLanguage.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      // note: added later so for some time, will need to keep it in here, for backwards compatibility.
      // in old there was no title, so we use the name.
      title = json['title'] as String? ?? json['name'] as String,
      isRTL = (json['app_rtl_support'] as String) == '1',
      version = json['app_version'] as String,
      isDefault = (json['app_default'] as String) == '1',
      translations = json['translations'] != null
          ? (json['translations'] as Map).cast<String, String>()
          : null;

  final String name;
  final String title;
  final bool isRTL;
  final String version;
  final bool isDefault;
  final Map<String, String>? translations;

  SystemLanguage copyWith({
    String? name,
    String? title,
    bool? isRTL,
    String? version,
    bool? isDefault,
    Map<String, String>? translations,
  }) => SystemLanguage(
    name: name ?? this.name,
    title: title ?? this.title,
    isRTL: isRTL ?? this.isRTL,
    version: version ?? this.version,
    isDefault: isDefault ?? this.isDefault,
    translations: translations ?? this.translations,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'title': title,
    'app_rtl_support': isRTL ? '1' : '0',
    'app_version': version,
    'app_default': isDefault ? '1' : '0',
    'translations': translations,
  };

  static const empty = SystemLanguage(
    name: '',
    title: '',
    isRTL: false,
    version: '',
    isDefault: false,
  );
}
