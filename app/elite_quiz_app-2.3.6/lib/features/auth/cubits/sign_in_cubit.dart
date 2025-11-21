import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/auth/auth_repository.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';

sealed class SignInState {
  const SignInState();
}

final class SignInInitial extends SignInState {
  const SignInInitial();
}

final class SignInProgress extends SignInState {
  const SignInProgress(this.authProvider);

  final AuthProviders authProvider;
}

final class SignInSuccess extends SignInState {
  const SignInSuccess({
    required this.authProvider,
    required this.user,
    required this.isNewUser,
  });

  final User user;
  final AuthProviders authProvider;
  final bool isNewUser;
}

final class SignInFailure extends SignInState {
  const SignInFailure(this.errorMessage, this.authProvider);

  final String errorMessage;
  final AuthProviders authProvider;
}

class SignInCubit extends Cubit<SignInState> {
  SignInCubit(this._authRepository) : super(const SignInInitial());
  final AuthRepository _authRepository;

  //to signIn user
  void signInUser(
    AuthProviders authProvider, {
    String email = '',
    String verificationId = '',
    String smsCode = '',
    String password = '',
    String? appLanguage,
  }) {
    emit(SignInProgress(authProvider));

    _authRepository
        .signInUser(
          authProvider,
          email: email,
          password: password,
          smsCode: smsCode,
          verificationId: verificationId,
          appLanguage: appLanguage,
        )
        .then((v) async {
          await FirebaseAnalytics.instance.logLogin(
            loginMethod: authProvider.name,
          );

          emit(
            SignInSuccess(
              user: v.user,
              authProvider: authProvider,
              isNewUser: v.isNewUser,
            ),
          );
        })
        .catchError((dynamic e) {
          emit(SignInFailure(e.toString(), authProvider));
        });
  }
}
