import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/badges/cubits/badges_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/audio_question_bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmark_cubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/guess_the_word_bookmark_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/delete_account_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';

void showDeleteAccountDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) => BlocProvider(
      create: (_) => DeleteAccountCubit(ProfileManagementRepository()),
      child: BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
        listener: (context, state) {
          if (state is DeleteAccountFailure) {
            dialogCtx.shouldPop();
            context.showSnack(
              context.tr(convertErrorCodeToLanguageKey(state.errorMessage))!,
            );
          }
          if (state is DeleteAccountSuccess) {
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

            context.showSnack(
              context.tr(accountDeletedSuccessfullyKey)!,
            );

            dialogCtx.shouldPop();
            globalCtx.pushReplacementNamed(Routes.login);
          }
        },
        builder: (context, state) {
          return QDialog(
            isLoading: state is DeleteAccountInProgress,
            loadingText: state is DeleteAccountInProgress
                ? context.tr(deletingAccountKey)
                : null,
            title: context.tr('deleteAccountLbl'),
            message: context.tr('deleteAccConfirmation'),
            image: Assets.deleteAccount,
            confirmButtonText: context.tr('yesDeleteAcc'),
            cancelButtonText: context.tr('keepAccount'),
            onConfirm: () =>
                context.read<DeleteAccountCubit>().deleteUserAccount(),
            onCancel: () => dialogCtx.shouldPop(),
          );
        },
      ),
    ),
  );
}
