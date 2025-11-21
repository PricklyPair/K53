import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/auth/auth_model.dart';
import 'package:flutterquiz/features/auth/auth_repository.dart';

//authentication provider
enum AuthProviders { gmail, email, mobile, apple }

//State
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class Authenticated extends AuthState {
  const Authenticated({required this.authModel});

  //to store authDetials
  final AuthModel authModel;
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(const AuthInitial()) {
    _checkAuthStatus();
  }

  final AuthRepository _authRepository;

  AuthProviders getAuthProvider() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.authProvider;
    }
    return AuthProviders.email;
  }

  void _checkAuthStatus() {
    //authDetails is map. keys are isLogin,userId,authProvider,jwtToken
    final authDetails = _authRepository.getLocalAuthDetails();

    if (authDetails['isLogin'] as bool) {
      emit(Authenticated(authModel: AuthModel.fromJson(authDetails)));
    } else {
      emit(const Unauthenticated());
    }
  }

  //to update auth status
  void updateAuthDetails({
    String? firebaseId,
    AuthProviders? authProvider,
    bool? authStatus,
    bool? isNewUser,
  }) {
    //updating authDetails locally
    _authRepository.setLocalAuthDetails(
      jwtToken: '',
      firebaseId: firebaseId,
      authType: authProvider!.name,
      authStatus: authStatus,
      isNewUser: isNewUser,
    );

    //emitting new state in cubit
    emit(
      Authenticated(
        authModel: AuthModel(
          jwtToken: '',
          firebaseId: firebaseId!,
          authProvider: authProvider,
          isNewUser: isNewUser!,
        ),
      ),
    );
  }

  bool get isGuest => state is Unauthenticated;
  bool get isLoggedIn => state is Authenticated;

  void logoutOrDeleteAccount() {
    if (state is Authenticated) {
      _authRepository.signOut((state as Authenticated).authModel.authProvider);
      emit(const Unauthenticated());
    }
  }
}
