import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/ui/widgets/custom_rounded_button.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

void showThemeSelectorSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: UiUtils.bottomSheetTopRadius,
    ),
    builder: (_) => const _ThemeSelectorWidget(),
  );
}

class _ThemeSelectorWidget extends StatelessWidget {
  const _ThemeSelectorWidget();

  @override
  Widget build(BuildContext context) {
    final size = context;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      padding: EdgeInsets.only(top: size.height * .02),
      child: BlocBuilder<ThemeCubit, Brightness>(
        bloc: context.read<ThemeCubit>(),
        builder: (context, state) {
          Brightness? currTheme = state;
          final colorScheme = Theme.of(context).colorScheme;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * UiUtils.hzMarginPct,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  child: Text(
                    context.tr('theme')!,
                    style: TextStyle(
                      fontWeight: FontWeights.bold,
                      fontSize: 18,
                      color: colorScheme.onTertiary,
                    ),
                  ),
                ),
                Divider(
                  color: colorScheme.onTertiary.withValues(alpha: 0.2),
                  thickness: 1,
                ),
                SizedBox(height: size.height * 0.02),
                RadioGroup<Brightness>(
                  groupValue: currTheme,
                  onChanged: (v) {
                    currTheme = v;
                    context.read<ThemeCubit>().changeTheme(currTheme!);
                  },
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: currTheme == Brightness.light
                              ? Theme.of(context).primaryColor
                              : colorScheme.onTertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: RadioListTile<Brightness>(
                          toggleable: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor: colorScheme.onTertiary.withValues(
                            alpha: 0.2,
                          ),
                          value: Brightness.light,
                          activeColor: Colors.white,
                          title: Text(
                            context.tr('lightTheme')!,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: currTheme == Brightness.light
                                  ? Colors.white
                                  : colorScheme.onTertiary,
                            ),
                          ),
                          secondary: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: currTheme == Brightness.light
                                    ? Colors.white
                                    : colorScheme.onTertiary.withValues(
                                        alpha: 0.2,
                                      ),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: SvgPicture.asset(
                              Assets.day,
                              width: 76,
                              height: 28,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Container(
                        decoration: BoxDecoration(
                          color: currTheme == Brightness.dark
                              ? Theme.of(context).primaryColor
                              : colorScheme.onTertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: RadioListTile<Brightness>(
                          toggleable: true,
                          value: Brightness.dark,
                          activeColor: Colors.white,
                          title: Text(
                            context.tr('darkTheme')!,
                            style: TextStyle(
                              fontWeight: FontWeights.medium,
                              fontSize: 18,
                              color: currTheme == Brightness.dark
                                  ? Colors.white
                                  : colorScheme.onTertiary,
                            ),
                          ),
                          secondary: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: currTheme == Brightness.dark
                                    ? Colors.white
                                    : colorScheme.onTertiary.withValues(
                                        alpha: 0.2,
                                      ),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: SvgPicture.asset(
                              Assets.night,
                              width: 76,
                              height: 28,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),

                ///

                ///
                const SizedBox(height: 32),
                CustomRoundedButton(
                  onTap: Navigator.of(context).pop,
                  widthPercentage: 1,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonTitle: context.tr('save'),
                  radius: 8,
                  showBorder: false,
                  height: 45,
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
