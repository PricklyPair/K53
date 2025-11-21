import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';

@immutable
abstract class UnlockedLevelState {}

class UnlockedLevelInitial extends UnlockedLevelState {}

class UnlockedLevelFetchInProgress extends UnlockedLevelState {}

class UnlockedLevelFetchSuccess extends UnlockedLevelState {
  UnlockedLevelFetchSuccess(
    this.categoryId,
    this.subcategoryId,
    this.unlockedLevel,
  );

  final int unlockedLevel;
  final String? categoryId;
  final String? subcategoryId;
}

class UnlockedLevelFetchFailure extends UnlockedLevelState {
  UnlockedLevelFetchFailure(this.errorMessage);

  final String errorMessage;
}

class UnlockedLevelCubit extends Cubit<UnlockedLevelState> {
  UnlockedLevelCubit(this._quizRepository) : super(UnlockedLevelInitial());
  final QuizRepository _quizRepository;

  // TODO(J): make subcategoryId optional
  Future<void> fetchUnlockLevel(
    String category,
    String subCategory, {
    required QuizTypes quizType,
  }) async {
    emit(UnlockedLevelFetchInProgress());
    await _quizRepository
        .getUnlockedLevel(category, subCategory, quizType: quizType)
        .then(
          (val) => emit(UnlockedLevelFetchSuccess(category, subCategory, val)),
        )
        .catchError((Object e) {
          emit(UnlockedLevelFetchFailure(e.toString()));
        });
  }
}
