import 'package:flutterquiz/core/config/config.dart';
import 'package:flutterquiz/core/constants/constants.dart';
import 'package:flutterquiz/features/system_config/model/system_language.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsLocalDataSource {
  Box<dynamic> get _box => Hive.box<dynamic>(settingsBox);

  bool get showIntroSlider =>
      _box.get(showIntroSliderKey, defaultValue: true) as bool;

  set showIntroSlider(bool value) => _box.put(showIntroSliderKey, value);

  bool get sound => _box.get(soundKey, defaultValue: true) as bool;

  set sound(bool value) => _box.put(soundKey, value);

  bool get vibration => _box.get(vibrationKey, defaultValue: true) as bool;

  set vibration(bool value) => _box.put(vibrationKey, value);

  String get quizLanguageCode =>
      _box.get('quiz_language', defaultValue: '') as String;

  set quizLanguageCode(String value) => _box.put('quiz_language', value);
  double get playAreaFontSize =>
      _box.get(fontSizeKey, defaultValue: 16.0) as double;

  set playAreaFontSize(double value) => _box.put(fontSizeKey, value);

  bool get rewardEarned =>
      _box.get(rewardEarnedKey, defaultValue: false) as bool;

  set rewardEarned(bool value) => _box.put(rewardEarnedKey, value);

  String get theme =>
      _box.get(settingsThemeKey, defaultValue: defaultTheme.name) as String;

  set theme(String value) => _box.put(settingsThemeKey, value);

  SystemLanguage get systemLanguage {
    final values =
        (_box.get(
                  'system_language',
                  defaultValue: SystemLanguage.empty.toJson(),
                )
                as Map)
            .cast<String, dynamic>();

    return SystemLanguage.fromJson(values);
  }

  set systemLanguage(SystemLanguage value) =>
      _box.put('system_language', value.toJson());
}
