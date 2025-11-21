import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/constants/constants.dart';
import 'package:flutterquiz/features/battle_room/battle_room_repository.dart';
import 'package:flutterquiz/features/battle_room/models/battle_room.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/user_battle_room_details.dart';
import 'package:flutterquiz/features/system_config/model/room_code_char_type.dart';

@immutable
class MultiUserBattleRoomState {}

class MultiUserBattleRoomInitial extends MultiUserBattleRoomState {}

class MultiUserBattleRoomInProgress extends MultiUserBattleRoomState {}

class MultiUserBattleRoomSuccess extends MultiUserBattleRoomState {
  MultiUserBattleRoomSuccess({
    required this.battleRoom,
    required this.isRoomExist,
    required this.questions,
  });

  final BattleRoom battleRoom;

  final bool isRoomExist;
  final List<Question> questions;
}

class MultiUserBattleRoomFailure extends MultiUserBattleRoomState {
  MultiUserBattleRoomFailure(this.errorMessageCode);

  final String errorMessageCode;
}

class MultiUserBattleRoomCubit extends Cubit<MultiUserBattleRoomState> {
  MultiUserBattleRoomCubit(this._battleRoomRepository)
    : super(MultiUserBattleRoomInitial());
  final BattleRoomRepository _battleRoomRepository;

  StreamSubscription<DocumentSnapshot>? _battleRoomStreamSubscription;

  final _rnd = Random.secure();

  void updateState(
    MultiUserBattleRoomState newState, {
    bool cancelSubscription = false,
  }) {
    if (cancelSubscription) {
      _battleRoomStreamSubscription?.cancel();
    }
    emit(newState);
  }

  //subscribe battle room
  void subscribeToMultiUserBattleRoom(
    String battleRoomDocumentId,
    List<Question> questions,
  ) {
    _battleRoomStreamSubscription = _battleRoomRepository
        .subscribeToBattleRoom(battleRoomDocumentId, forMultiUser: true)
        .listen(
          (event) {
            //to check if room destroyed by owner
            if (event.exists) {
              emit(
                MultiUserBattleRoomSuccess(
                  battleRoom: BattleRoom.fromDocumentSnapshot(event),
                  isRoomExist: true,
                  questions: questions,
                ),
              );
            } else {
              //update state with room does not exist
              emit(
                MultiUserBattleRoomSuccess(
                  battleRoom: (state as MultiUserBattleRoomSuccess).battleRoom,
                  isRoomExist: false,
                  questions: (state as MultiUserBattleRoomSuccess).questions,
                ),
              );
            }
          },
          onError: (e) {
            emit(MultiUserBattleRoomFailure(errorCodeDefaultMessage));
          },
          cancelOnError: true,
        );
  }

  //to create room for multiuser
  Future<void> createRoom({
    required String categoryId,
    required String categoryName,
    required String categoryImage,
    required RoomCodeCharType charType,
    String? name,
    String? profileUrl,
    String? uid,
    String? roomType,
    int? entryFee,
    String? questionLanguageId,
  }) async {
    emit(MultiUserBattleRoomInProgress());
    try {
      final roomCode = generateRoomCode(charType, 6);
      final documentSnapshot = await _battleRoomRepository
          .createMultiUserBattleRoom(
            categoryId: categoryId,
            categoryName: categoryName,
            categoryImage: categoryImage,
            name: name,
            profileUrl: profileUrl,
            uid: uid,
            roomCode: roomCode,
            roomType: 'public',
            entryFee: entryFee,
            questionLanguageId: questionLanguageId,
          );
      final questions = await _battleRoomRepository.getQuestions(
        categoryId: '',
        forMultiUser: true,
        matchId: roomCode,
        roomDocumentId: documentSnapshot.id,
        roomCreator: true,
        languageId: questionLanguageId!,
        entryCoin: entryFee,
      );
      subscribeToMultiUserBattleRoom(documentSnapshot.id, questions);
    } on Exception catch (e) {
      emit(MultiUserBattleRoomFailure(e.toString()));
    }
  }

  //to join multi user battle room
  Future<void> joinRoom({
    required String currentCoin,
    String? name,
    String? profileUrl,
    String? uid,
    String? roomCode,
  }) async {
    emit(MultiUserBattleRoomInProgress());
    try {
      final (:roomId, :questions) = await _battleRoomRepository
          .joinMultiUserBattleRoom(
            name: name,
            profileUrl: profileUrl,
            roomCode: roomCode,
            uid: uid,
            currentCoin: int.parse(currentCoin),
          );

      subscribeToMultiUserBattleRoom(roomId, questions);
    } on Exception catch (e) {
      emit(MultiUserBattleRoomFailure(e.toString()));
    }
  }

  //this will be call when user submit answer and marked questions attempted
  //if time expired for given question then default "-1" answer will be submitted
  void updateQuestionAnswer(String questionId, String submittedAnswerId) {
    if (state is MultiUserBattleRoomSuccess) {
      final updatedQuestions = (state as MultiUserBattleRoomSuccess).questions;
      //fetching index of question that need to update with submittedAnswer
      final questionIndex = updatedQuestions.indexWhere(
        (element) => element.id == questionId,
      );
      //update question at given questionIndex with submittedAnswerId
      updatedQuestions[questionIndex] = updatedQuestions[questionIndex]
          .updateQuestionWithAnswer(submittedAnswerId: submittedAnswerId);
      emit(
        MultiUserBattleRoomSuccess(
          isRoomExist: (state as MultiUserBattleRoomSuccess).isRoomExist,
          battleRoom: (state as MultiUserBattleRoomSuccess).battleRoom,
          questions: updatedQuestions,
        ),
      );
    }
  }

  //delete room after quiting the game or finishing the game
  void deleteMultiUserBattleRoom() {
    if (state is MultiUserBattleRoomSuccess) {
      _battleRoomRepository.deleteBattleRoom(
        (state as MultiUserBattleRoomSuccess).battleRoom.roomId,
        isGroupBattle: true,
        roomCode: (state as MultiUserBattleRoomSuccess).battleRoom.roomCode,
      );
    }
  }

  void deleteUserFromRoom(String userId) {
    if (state is MultiUserBattleRoomSuccess) {
      final battleRoom = (state as MultiUserBattleRoomSuccess).battleRoom;
      if (userId == battleRoom.user1!.uid) {
        _battleRoomRepository.deleteUserFromMultiUserRoom(1, battleRoom);
      } else if (userId == battleRoom.user2!.uid) {
        _battleRoomRepository.deleteUserFromMultiUserRoom(2, battleRoom);
      } else if (userId == battleRoom.user3!.uid) {
        _battleRoomRepository.deleteUserFromMultiUserRoom(3, battleRoom);
      } else {
        _battleRoomRepository.deleteUserFromMultiUserRoom(4, battleRoom);
      }
    }
  }

  void startGame() {
    if (state is MultiUserBattleRoomSuccess) {
      _battleRoomRepository.startMultiUserQuiz(
        (state as MultiUserBattleRoomSuccess).battleRoom.roomId,
        isMultiUserRoom: true,
      );
    }
  }

  void submitAnswer(
    String currentUserId,
    String submittedAnswer, {
    required String questionId,
    required bool isCorrectAnswer,
  }) {
    if (state is MultiUserBattleRoomSuccess) {
      final battleRoom = (state as MultiUserBattleRoomSuccess).battleRoom;
      final questions = (state as MultiUserBattleRoomSuccess).questions;

      late final String userNo;
      late final UserBattleRoomDetails user;
      if (currentUserId == battleRoom.user1!.uid) {
        userNo = '1';
        user = battleRoom.user1!;
      } else if (currentUserId == battleRoom.user2!.uid) {
        userNo = '2';
        user = battleRoom.user2!;
      } else if (currentUserId == battleRoom.user3!.uid) {
        userNo = '3';
        user = battleRoom.user3!;
      } else {
        userNo = '4';
        user = battleRoom.user4!;
      }

      if (user.answers.length != questions.length) {
        _battleRoomRepository.submitAnswerForMultiUserBattleRoom(
          battleRoomDocumentId: battleRoom.roomId,
          correctAnswers: isCorrectAnswer
              ? (user.correctAnswers + 1)
              : user.correctAnswers,
          userNumber: userNo,
          submittedAnswer: List.from(user.answers)
            ..add({'answer': submittedAnswer, 'id': questionId}),
        );
      }
    }
  }

  //get questions in quiz battle
  List<Question> getQuestions() {
    if (state is MultiUserBattleRoomSuccess) {
      return (state as MultiUserBattleRoomSuccess).questions;
    }
    return [];
  }

  BattleRoom? get battleRoom {
    if (state is MultiUserBattleRoomSuccess) {
      return (state as MultiUserBattleRoomSuccess).battleRoom;
    }
    return null;
  }

  String getRoomCode() {
    if (state is MultiUserBattleRoomSuccess) {
      return (state as MultiUserBattleRoomSuccess).battleRoom.roomCode!;
    }
    return '';
  }

  String getRoomId() {
    if (state is MultiUserBattleRoomSuccess) {
      return (state as MultiUserBattleRoomSuccess).battleRoom.roomId!;
    }
    return '';
  }

  //get questions in quiz battle
  int getEntryFee() {
    if (state is MultiUserBattleRoomSuccess) {
      return (state as MultiUserBattleRoomSuccess).battleRoom.entryFee!;
    }
    return 0;
  }

  String get categoryName => state is MultiUserBattleRoomSuccess
      ? (state as MultiUserBattleRoomSuccess).battleRoom.categoryName!
      : '';

  String get categoryImage => state is MultiUserBattleRoomSuccess
      ? (state as MultiUserBattleRoomSuccess).battleRoom.categoryImage!
      : '';

  List<UserBattleRoomDetails?> getUsers() {
    if (state is MultiUserBattleRoomSuccess) {
      final users = <UserBattleRoomDetails?>[];
      final battleRoom = (state as MultiUserBattleRoomSuccess).battleRoom;
      if (battleRoom.user1!.uid.isNotEmpty) {
        users.add(battleRoom.user1);
      }
      if (battleRoom.user2!.uid.isNotEmpty) {
        users.add(battleRoom.user2);
      }
      if (battleRoom.user3!.uid.isNotEmpty) {
        users.add(battleRoom.user3);
      }
      if (battleRoom.user4!.uid.isNotEmpty) {
        users.add(battleRoom.user4);
      }

      return users;
    }
    return [];
  }

  /// Returns true if the current user is the only one remaining in the battle room
  bool isCurrentUserAloneInRoom(String currentUserId) {
    final activeUsers = getUsers();

    return activeUsers.length == 1 && activeUsers.single!.uid == currentUserId;
  }

  UserBattleRoomDetails? getUser(String userId) {
    final users = getUsers();
    return users[users.indexWhere((element) => element!.uid == userId)];
  }

  List<UserBattleRoomDetails?> getOpponentUsers(String userId) {
    return getUsers()..removeWhere((e) => e!.uid == userId);
  }

  String generateRoomCode(RoomCodeCharType charType, int length) =>
      String.fromCharCodes(
        Iterable.generate(
          length,
          (_) => charType.value.codeUnitAt(_rnd.nextInt(charType.value.length)),
        ),
      );

  //to close the stream subscription
  @override
  Future<void> close() async {
    await _battleRoomStreamSubscription?.cancel();
    return super.close();
  }
}
