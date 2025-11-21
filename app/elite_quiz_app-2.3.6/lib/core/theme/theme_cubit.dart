import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/settings/settings_local_data_source.dart';

class ThemeCubit extends Cubit<Brightness> {
  ThemeCubit(this.settingsLocalDataSource)
    : super(
        settingsLocalDataSource.theme == Brightness.light.name
            ? Brightness.light
            : Brightness.dark,
      );

  final SettingsLocalDataSource settingsLocalDataSource;

  void changeTheme(Brightness appTheme) {
    settingsLocalDataSource.theme = appTheme.name;
    emit(appTheme);
  }
}
