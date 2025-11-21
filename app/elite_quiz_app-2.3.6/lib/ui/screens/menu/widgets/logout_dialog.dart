import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/badges/cubits/badges_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/audio_question_bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/guess_the_word_bookmark_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';

Future<void> showLogoutDialog(BuildContext context) {
  return context.showDialog(
    title: context.tr('logoutLbl'),
    message: context.tr('logoutDialogLbl'),
    image: Assets.logoutAccount,
    confirmButtonText: context.tr('yesLogoutLbl'),
    onConfirm: () {
      context.read<BadgesCubit>().updateState(BadgesInitial());

      context.read<BookmarkCubit>().updateState(BookmarkInitial());

      context.read<GuessTheWordBookmarkCubit>().updateState(
        GuessTheWordBookmarkInitial(),
      );

      context.read<AudioQuestionBookmarkCubit>().updateState(
        AudioQuestionBookmarkInitial(),
      );

      context.read<AuthCubit>().logoutOrDeleteAccount();
      context.read<UserDetailsCubit>().logoutOrDeleteAccount();

      context.pushReplacementNamed(Routes.login);
    },
    cancelButtonText: context.tr('stayLoggedLbl'),
  );
}
