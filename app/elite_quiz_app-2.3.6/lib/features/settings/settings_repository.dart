import 'package:flutterquiz/features/settings/settings_local_data_source.dart';
import 'package:flutterquiz/features/system_config/model/system_language.dart';
import 'package:flutterquiz/features/system_config/system_config_remote_data_source.dart';

class SettingsRepository {
  factory SettingsRepository() {
    _settingsRepository._settingsLocalDataSource = SettingsLocalDataSource();
    _settingsRepository._systemConfigRemoteDataSource =
        SystemConfigRemoteDataSource();
    return _settingsRepository;
  }

  SettingsRepository._internal();

  static final SettingsRepository _settingsRepository =
      SettingsRepository._internal();
  late SystemConfigRemoteDataSource _systemConfigRemoteDataSource;
  late SettingsLocalDataSource _settingsLocalDataSource;

  Map<String, dynamic> getCurrentSettings() {
    return {
      'showIntroSlider': _settingsLocalDataSource.showIntroSlider,
      'sound': _settingsLocalDataSource.sound,
      'rewardEarned': _settingsLocalDataSource.rewardEarned,
      'vibration': _settingsLocalDataSource.vibration,
      'theme': _settingsLocalDataSource.theme,
      'playAreaFontSize': _settingsLocalDataSource.playAreaFontSize,
    };
  }

  bool get showIntroSlider => _settingsLocalDataSource.showIntroSlider;

  set showIntroSlider(bool value) =>
      _settingsLocalDataSource.showIntroSlider = value;

  bool get sound => _settingsLocalDataSource.sound;

  set sound(bool value) => _settingsLocalDataSource.sound = value;

  bool get vibration => _settingsLocalDataSource.vibration;

  set vibration(bool value) => _settingsLocalDataSource.vibration = value;

  double get playAreaFontSize => _settingsLocalDataSource.playAreaFontSize;

  set playAreaFontSize(double value) =>
      _settingsLocalDataSource.playAreaFontSize = value;

  SystemLanguage get systemLanguage => _settingsLocalDataSource.systemLanguage;

  set systemLanguage(SystemLanguage value) =>
      _settingsLocalDataSource.systemLanguage = value;

  Future<List<SystemLanguage>> getSupportedLanguageList() async {
    final result = await _systemConfigRemoteDataSource
        .getSupportedLanguageList();

    return result.map(SystemLanguage.fromJson).toList();
  }

  Future<SystemLanguage> getSystemLanguage(
    String languageName,
    String title,
  ) async {
    final result = SystemLanguage.fromJson(
      await _systemConfigRemoteDataSource.getSystemLanguage(
        languageName,
        title,
      ),
    );

    // Save Locally
    systemLanguage = result;

    return result;
  }
}
