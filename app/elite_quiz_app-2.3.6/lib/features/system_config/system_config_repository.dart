import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/system_config/model/supported_question_language.dart';
import 'package:flutterquiz/features/system_config/model/system_config_model.dart';
import 'package:flutterquiz/features/system_config/model/system_language.dart';
import 'package:flutterquiz/features/system_config/system_config_exception.dart';
import 'package:flutterquiz/features/system_config/system_config_remote_data_source.dart';

class SystemConfigRepository {
  factory SystemConfigRepository() {
    _systemConfigRepository._systemConfigRemoteDataSource =
        SystemConfigRemoteDataSource();
    return _systemConfigRepository;
  }

  SystemConfigRepository._internal();

  static final SystemConfigRepository _systemConfigRepository =
      SystemConfigRepository._internal();
  late SystemConfigRemoteDataSource _systemConfigRemoteDataSource;

  Future<SystemConfigModel> getSystemConfig() async {
    try {
      final result = await _systemConfigRemoteDataSource.getSystemConfig();
      log(name: 'System Config', result.toString());
      return SystemConfigModel.fromJson(result);
    } catch (e) {
      log(name: 'System Config Exception', e.toString());
      throw SystemConfigException(errorMessageCode: e.toString());
    }
  }

  Future<List<QuizLanguage>> getSupportedQuestionLanguages() async {
    try {
      final result = await _systemConfigRemoteDataSource
          .getSupportedQuestionLanguages();
      return result.map((e) => QuizLanguage.fromJson(Map.from(e))).toList();
    } catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    }
  }

  Future<List<SystemLanguage>> getSupportedLanguageList() async {
    try {
      final result = await _systemConfigRemoteDataSource
          .getSupportedLanguageList();

      return result.map(SystemLanguage.fromJson).toList();
    } catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    }
  }

  Future<String> getAppSettings(String type) async {
    try {
      final result = await _systemConfigRemoteDataSource.getAppSettings(type);
      return result;
    } catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    }
  }

  Future<List<String>> getProfileImages() async {
    try {
      final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = assetManifest.listAssets();

      const path = Assets.profileImagesPath;

      // Filter for images in the profile directory
      final profileImages =
          assets
              .where((asset) => asset.startsWith(path))
              .map((asset) => asset.split('/').last)
              .toList()
            ..sort((a, b) => a.compareTo(b));

      // Validate that we found some images
      if (profileImages.isEmpty) {
        throw SystemConfigException(
          errorMessageCode: 'No images found in $path',
        );
      }

      return profileImages;
    } on FormatException catch (e) {
      throw SystemConfigException(
        errorMessageCode: 'Failed to parse AssetManifest.json: ${e.message}',
      );
    } on PlatformException catch (e) {
      throw SystemConfigException(
        errorMessageCode: 'Failed to load AssetManifest.json: ${e.message}',
      );
    } on Exception catch (e) {
      throw SystemConfigException(
        errorMessageCode: 'Unexpected error loading images: $e',
      );
    }
  }

  Future<List<String>> getEmojiImages() async {
    try {
      final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = assetManifest.listAssets();

      const path = Assets.emojisPath;

      // Filter for PNG files in the profile directory
      final profileImages =
          assets
              .where((asset) => asset.startsWith(path))
              .map((asset) => asset.split('/').last)
              .toList()
            ..sort((a, b) => a.compareTo(b));

      // Validate that we found some images
      if (profileImages.isEmpty) {
        throw SystemConfigException(
          errorMessageCode: 'No images found in $path',
        );
      }

      return profileImages;
    } on FormatException catch (e) {
      throw SystemConfigException(
        errorMessageCode: 'Failed to parse AssetManifest.json: ${e.message}',
      );
    } on PlatformException catch (e) {
      throw SystemConfigException(
        errorMessageCode: 'Failed to load AssetManifest.json: ${e.message}',
      );
    } on Exception catch (e) {
      throw SystemConfigException(
        errorMessageCode: 'Unexpected error loading images: $e',
      );
    }
  }
}
