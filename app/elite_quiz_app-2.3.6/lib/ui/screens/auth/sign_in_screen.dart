import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/auth/auth_remote_data_source.dart';
import 'package:flutterquiz/features/auth/auth_repository.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/auth/cubits/sign_in_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/app_logo.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/email_textfield.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/pswd_textfield.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/terms_and_condition.dart';
import 'package:flutterquiz/ui/screens/profile/create_or_edit_profile_screen.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();

  static Route<dynamic> route() {
    return CupertinoPageRoute(builder: (_) => const SignInScreen());
  }
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyDialog = GlobalKey<FormState>();

  bool isLoading = false;

  final emailController = TextEditingController();
  final forgotPswdController = TextEditingController();
  final pswdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInCubit>(
      create: (_) => SignInCubit(AuthRepository()),
      child: Builder(
        builder: (context) =>
            Scaffold(body: SingleChildScrollView(child: showForm(context))),
      ),
    );
  }

  Widget showForm(BuildContext context) {
    final size = context;
    final c = context.read<SystemConfigCubit>();

    return BlocListener<SignInCubit, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess &&
            state.authProvider != AuthProviders.email) {
          context.read<AuthCubit>().updateAuthDetails(
            authProvider: state.authProvider,
            firebaseId: state.user.uid,
            authStatus: true,
            isNewUser: state.isNewUser,
          );
          if (state.isNewUser) {
            context.read<UserDetailsCubit>().fetchUserDetails();
            context.pushReplacementNamed(
              Routes.selectProfile,
              arguments: const CreateOrEditProfileScreenArgs(isNewUser: true),
            );
          } else {
            context.read<UserDetailsCubit>().fetchUserDetails();
            context.pushNamedAndRemoveUntil(
              Routes.home,
              predicate: (_) => false,
            );
          }
        } else if (state is SignInFailure &&
            state.authProvider != AuthProviders.email) {
          context.showSnack(
            context.tr(convertErrorCodeToLanguageKey(state.errorMessage))!,
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: size.height * UiUtils.vtMarginPct,
            horizontal: size.width * UiUtils.hzMarginPct + 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: size.height * .09),
              const AppLogo(),
              SizedBox(height: size.height * .08),
              if (c.areAllLoginMethodsDisabled)
                ..._buildNoLoginMethods()
              else ...[
                if (c.isEmailLoginMethodEnabled) ...[
                  ..._buildEmailLoginMethod(context, size.height),
                ],

                ///
                if (c.isPhoneLoginMethodEnabled ||
                    c.isAppleLoginMethodEnabled ||
                    c.isGmailLoginMethodEnabled)
                  ..._buildSocialMediaLoginMethods(context, size.height),
              ],
              SizedBox(height: size.height * 0.05),
              const TermsAndCondition(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSocialMediaLoginMethods(
    BuildContext context,
    double height,
  ) {
    final c = context.read<SystemConfigCubit>();

    return [
      if (Platform.isIOS && !c.isAppleLoginMethodEnabled) ...[
        const SizedBox(height: 10),
        Text(
          context.tr('forIOSMustEnableAppleLogin')!,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
      ],
      if (c.isEmailLoginMethodEnabled) ...[
        orLabel(),
        SizedBox(height: height * 0.03),
        loginWith(),
        showSocialMedia(context),
      ] else ...[
        BlocBuilder<SignInCubit, SignInState>(
          builder: (context, state) {
            return Column(
              children: state is SignInProgress
                  ? [const Center(child: CircularProgressContainer())]
                  : [
                      /// Apple Login
                      if (Platform.isIOS && c.isAppleLoginMethodEnabled) ...[
                        _buildLoginButton(
                          title: context.tr('signInApple')!,
                          icon: Assets.appleIcon,
                          onTap: () => context.read<SignInCubit>().signInUser(
                            AuthProviders.apple,
                            appLanguage: context
                                .read<AppLocalizationCubit>()
                                .activeLanguage
                                .name,
                          ),
                        ),
                      ],

                      /// Gmail Login
                      if (c.isGmailLoginMethodEnabled) ...[
                        if (Platform.isIOS && c.isAppleLoginMethodEnabled) ...[
                          const SizedBox(height: 10),
                        ],
                        _buildLoginButton(
                          title: context.tr('signInGoogle')!,
                          icon: Assets.googleIcon,
                          onTap: () => context.read<SignInCubit>().signInUser(
                            AuthProviders.gmail,
                            appLanguage: context
                                .read<AppLocalizationCubit>()
                                .activeLanguage
                                .name,
                          ),
                        ),
                      ],

                      /// Phone Login
                      if (c.isPhoneLoginMethodEnabled) ...[
                        if (c.isAppleLoginMethodEnabled ||
                            c.isGmailLoginMethodEnabled) ...[
                          const SizedBox(height: 10),
                        ],
                        _buildLoginButton(
                          title: context.tr('signInPhone')!,
                          icon: Assets.phoneIcon,
                          onTap: () => context.pushNamed(Routes.otpScreen),
                        ),
                      ],
                    ],
            );
          },
        ),
      ],
    ];
  }

  Widget _buildLoginButton({
    required String title,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            QImage(imageUrl: icon),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNoLoginMethods() {
    return [
      const SizedBox(height: 20),
      Text(
        context.tr('noLoginMethodsWarning')!,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).colorScheme.onTertiary,
          fontWeight: FontWeights.regular,
        ),
      ),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> _buildEmailLoginMethod(BuildContext context, double height) {
    return [
      EmailTextField(controller: emailController),
      SizedBox(height: height * .02),
      PswdTextField(controller: pswdController),
      SizedBox(height: height * .01),
      forgetPwd(),
      SizedBox(height: height * 0.02),
      showSignIn(context),
      SizedBox(height: height * 0.02),
      showGoSignup(),
    ];
  }

  Widget showSignIn(BuildContext context) {
    return SizedBox(
      width: context.width,
      height: context.height * 0.055,
      child: BlocConsumer<SignInCubit, SignInState>(
        bloc: context.read<SignInCubit>(),
        listener: (context, state) async {
          //Exceuting only if authProvider is email
          if (state is SignInSuccess &&
              state.authProvider == AuthProviders.email) {
            //to update authdetails after successfull sign in
            context.read<AuthCubit>().updateAuthDetails(
              authProvider: state.authProvider,
              firebaseId: state.user.uid,
              authStatus: true,
              isNewUser: state.isNewUser,
            );
            if (state.isNewUser) {
              await context.read<UserDetailsCubit>().fetchUserDetails();
              //navigate to select profile screen

              await context.pushReplacementNamed(
                Routes.selectProfile,
                arguments: const CreateOrEditProfileScreenArgs(isNewUser: true),
              );
            } else {
              //get user detials of signed in user
              await context.read<UserDetailsCubit>().fetchUserDetails();
              await context.pushNamedAndRemoveUntil(
                Routes.home,
                predicate: (_) => false,
              );
            }
          } else if (state is SignInFailure &&
              state.authProvider == AuthProviders.email) {
            context.showSnack(
              context.tr(convertErrorCodeToLanguageKey(state.errorMessage))!,
            );
          }
        },
        builder: (context, state) {
          return CupertinoButton(
            padding: const EdgeInsets.all(5),
            color: Theme.of(context).primaryColor,
            onPressed: state is SignInProgress
                ? () {}
                : () async {
                    if (_formKey.currentState!.validate()) {
                      {
                        context.read<SignInCubit>().signInUser(
                          AuthProviders.email,
                          email: emailController.text.trim(),
                          password: pswdController.text.trim(),
                          appLanguage: context
                              .read<AppLocalizationCubit>()
                              .activeLanguage
                              .name,
                        );
                      }
                    }
                  },
            child:
                state is SignInProgress &&
                    state.authProvider == AuthProviders.email
                ? const Center(
                    child: CircularProgressContainer(whiteLoader: true),
                  )
                : Text(
                    context.tr('loginLbl')!,
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                        height: 1.2,
                        fontSize: 20,
                        fontWeight: FontWeights.regular,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Padding forgetPwd() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Align(
        alignment: Alignment.bottomRight,
        child: InkWell(
          splashColor: Colors.white,
          child: Text(
            context.tr('forgotPwdLbl')!,
            style: TextStyle(
              fontWeight: FontWeights.regular,
              fontSize: 14,
              height: 1.21,
              color: Theme.of(
                context,
              ).colorScheme.onTertiary.withValues(alpha: 0.4),
            ),
          ),
          onTap: () async {
            await showModalBottomSheet<void>(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: UiUtils.bottomSheetTopRadius,
              ),
              context: context,
              builder: (context) => Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: UiUtils.bottomSheetTopRadius,
                  ),
                  constraints: BoxConstraints(maxHeight: context.height * 0.41),
                  child: Form(
                    key: _formKeyDialog,
                    child: Column(
                      children: [
                        SizedBox(height: context.height * 0.03),
                        Text(
                          context.tr('resetPwdLbl')!,
                          style: TextStyle(
                            fontSize: 22,
                            color: Theme.of(context).colorScheme.onTertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 20,
                            end: 20,
                            top: 20,
                          ),
                          child: Text(
                            context.tr('resetEnterEmailLbl')!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onTertiary,
                              fontWeight: FontWeights.semiBold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: context.width * .08,
                            end: context.width * .08,
                            top: 20,
                          ),
                          child: EmailTextField(
                            controller: forgotPswdController,
                          ),
                        ),
                        const SizedBox(height: 30),
                        CustomRoundedButton(
                          widthPercentage: 0.55,
                          backgroundColor: Theme.of(context).primaryColor,
                          buttonTitle: context.tr('submitBtn'),
                          radius: 10,
                          showBorder: false,
                          height: 50,
                          onTap: () {
                            final form = _formKeyDialog.currentState;
                            if (form!.validate()) {
                              form.save();
                              context.showSnack(
                                context.tr('pwdResetLinkLbl')!,
                              );
                              AuthRemoteDataSource().resetPassword(
                                forgotPswdController.text.trim(),
                              );
                              Future.delayed(const Duration(seconds: 1), () {
                                context.pop('Cancel');
                              });

                              forgotPswdController.text = '';
                              form.reset();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget orLabel() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        context.tr('orLbl')!,
        style: TextStyle(
          fontWeight: FontWeights.regular,
          color: Theme.of(
            context,
          ).colorScheme.onTertiary.withValues(alpha: 0.4),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget loginWith() {
    return Text(
      context.tr('loginSocialMediaLbl')!,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeights.regular,
        color: Theme.of(context).colorScheme.onTertiary,
        fontSize: 14,
      ),
    );
  }

  Widget showSocialMedia(BuildContext context) {
    return BlocBuilder<SignInCubit, SignInState>(
      builder: (context, state) {
        final c = context.read<SystemConfigCubit>();

        return Container(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                (state is SignInProgress &&
                    state.authProvider != AuthProviders.email)
                ? [const Center(child: CircularProgressContainer())]
                : [
                    ///
                    if (Platform.isIOS && c.isAppleLoginMethodEnabled) ...[
                      _buildAppleLoginIconButton(context),
                    ],

                    ///
                    if (c.isGmailLoginMethodEnabled) ...[
                      if (Platform.isIOS && c.isAppleLoginMethodEnabled)
                        const SizedBox(width: 25),
                      _buildGmailLoginIconButton(context),
                    ],

                    ///
                    if (c.isPhoneLoginMethodEnabled) ...[
                      if (c.isAppleLoginMethodEnabled ||
                          c.isGmailLoginMethodEnabled)
                        const SizedBox(width: 25),
                      _buildPhoneLoginIconButton(context),
                    ],
                  ],
          ),
        );
      },
    );
  }

  Widget _buildAppleLoginIconButton(BuildContext context) {
    return InkWell(
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        child: SvgPicture.asset(Assets.appleIcon, height: 38, width: 38),
      ),
      onTap: () => context.read<SignInCubit>().signInUser(
        AuthProviders.apple,
        appLanguage: context.read<AppLocalizationCubit>().activeLanguage.name,
      ),
    );
  }

  Widget _buildGmailLoginIconButton(BuildContext context) {
    return InkWell(
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        child: SvgPicture.asset(Assets.googleIcon, height: 38, width: 38),
      ),
      onTap: () => context.read<SignInCubit>().signInUser(
        AuthProviders.gmail,
        appLanguage: context.read<AppLocalizationCubit>().activeLanguage.name,
      ),
    );
  }

  Widget _buildPhoneLoginIconButton(BuildContext context) {
    return InkWell(
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        child: SvgPicture.asset(Assets.phoneIcon, height: 38, width: 38),
      ),
      onTap: () => context.pushNamed(Routes.otpScreen),
    );
  }

  Widget showGoSignup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.tr('noAccountLbl')!,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeights.regular,
            color: Theme.of(
              context,
            ).colorScheme.onTertiary.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(width: 4),
        CupertinoButton(
          onPressed: () {
            _formKey.currentState!.reset();
            context.pushNamed(Routes.signUp);
          },
          padding: EdgeInsets.zero,
          child: Text(
            context.tr('signUpLbl')!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeights.regular,
              decoration: TextDecoration.underline,
              decorationColor: Theme.of(context).primaryColor,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
