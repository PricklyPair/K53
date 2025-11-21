import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/settings/settings_repository.dart';
import 'package:flutterquiz/features/system_config/model/system_language.dart';

class AppLocalizationState {
  const AppLocalizationState(this.language, this.systemLanguages);

  final SystemLanguage language;
  final List<SystemLanguage> systemLanguages;
}

class AppLocalizationCubit extends Cubit<AppLocalizationState> {
  AppLocalizationCubit(this._settingsRepository)
    : super(AppLocalizationState(_settingsRepository.systemLanguage, []));

  final SettingsRepository _settingsRepository;

  Future<void> init() async {
    // fetch all available languages
    final systemLanguages = await _settingsRepository
        .getSupportedLanguageList();

    /// When app is launched for the first time, Selected Language will be Empty.
    /// So we are just adding the available languages to the state
    /// But, if the language is already selected, then we are just updating the state with available languages
    emit(AppLocalizationState(state.language, systemLanguages));

    /// FIRST TIME APP LAUNCH
    /// doesn't matter if app is opened for the first time or not
    /// when app is opened first time, curr language will be empty
    /// and we will check if it is available or not, which it won't be
    /// so we will just set the language to default language

    /// FOR CONSECUTIVE LAUNCHES
    /// Check if curr app language is still available
    /// otherwise change to default language, cause admin has disabled it.
    final available = state.systemLanguages.any(
      (e) => e.name == state.language.name,
    );

    if (available) {
      final newVersion = state.systemLanguages.firstWhere(
        (e) => e.name == state.language.name,
      );
      if (state.language.version != newVersion.version) {
        await changeLanguage(newVersion.name, newVersion.title);
      }

      if (state.language.isRTL != newVersion.isRTL) {
        await changeRTLStatus(isRTL: newVersion.isRTL);
      }
    } else {
      final defaultLanguage = state.systemLanguages.firstWhere(
        (e) => e.isDefault,
      );

      await changeLanguage(defaultLanguage.name, defaultLanguage.title);
    }
  }

  Future<void> changeLanguage(String name, String title) async {
    final systemLanguage = await _settingsRepository.getSystemLanguage(
      name,
      title,
    );

    emit(AppLocalizationState(systemLanguage, state.systemLanguages));
  }

  Future<void> changeRTLStatus({required bool isRTL}) async {
    final systemLanguage = state.language.copyWith(isRTL: isRTL);

    emit(AppLocalizationState(systemLanguage, state.systemLanguages));
  }

  SystemLanguage get activeLanguage => state.language;

  String? tr(String key) => state.language.translations?[key];
}
