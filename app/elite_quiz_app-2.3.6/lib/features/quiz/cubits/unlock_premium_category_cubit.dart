import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/quiz_repository.dart';

part 'unlock_premium_category_state.dart';

class UnlockPremiumCategoryCubit extends Cubit<UnlockPremiumCategoryState> {
  UnlockPremiumCategoryCubit(this._quizRepository)
    : super(UnlockPremiumCategoryInitial());
  final QuizRepository _quizRepository;

  void unlockPremiumCategory({required String categoryId}) {
    emit(UnlockPremiumCategoryInProgress());

    _quizRepository
        .unlockPremiumCategory(categoryId: categoryId)
        .then((_) => emit(UnlockPremiumCategorySuccess()))
        .catchError(
          (Object e) => emit(UnlockPremiumCategoryFailure(e.toString())),
        );
  }

  void reset() => emit(UnlockPremiumCategoryInitial());
}
