import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';

@immutable
abstract class UpdateCoinsState {}

class UpdateCoinsInitial extends UpdateCoinsState {}

class UpdateCoinsInProgress extends UpdateCoinsState {}

class UpdateCoinsSuccess extends UpdateCoinsState {
  UpdateCoinsSuccess({this.coins, this.score});

  final String? score;
  final String? coins;
}

class UpdateCoinsFailure extends UpdateCoinsState {
  UpdateCoinsFailure(this.errorMessage);

  final String errorMessage;
}

class UpdateCoinsCubit extends Cubit<UpdateCoinsState> {
  UpdateCoinsCubit(this._profileManagementRepository)
    : super(UpdateCoinsInitial());
  final ProfileManagementRepository _profileManagementRepository;

  Future<void> updateCoins({
    required String title,
    required bool addCoin,
    int? coins,
    String? type,
  }) async {
    emit(UpdateCoinsInProgress());

    await _profileManagementRepository
        .updateCoins(coins: coins, addCoin: addCoin, type: type, title: title)
        .then((result) {
          if (!isClosed) {
            emit(
              UpdateCoinsSuccess(
                coins: result.coins,
                score: result.score,
              ),
            );
          }
        })
        .catchError((Object e) {
          if (!isClosed) {
            emit(UpdateCoinsFailure(e.toString()));
          }
        });
  }
}
