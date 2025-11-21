import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/ui/widgets/custom_rounded_button.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

Future<void> showLanguageSelectorSheet(
  BuildContext context, {
  required VoidCallback onChange,
}) async {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: UiUtils.bottomSheetTopRadius,
    ),
    builder: (_) => _LanguageSelectorWidget(onChange),
  );
}

class _LanguageSelectorWidget extends StatelessWidget {
  const _LanguageSelectorWidget(this.onChange);

  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final size = context;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      padding: EdgeInsets.only(top: size.height * .02),
      child: BlocBuilder<AppLocalizationCubit, AppLocalizationState>(
        builder: (context, state) {
          final textStyle = TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorScheme.onTertiary,
          );

          final currLang = state.language;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * UiUtils.hzMarginPct,
            ),
            child: Column(
              children: [
                /// Title
                Text(context.tr('language')!, style: textStyle),
                const Divider(),

                /// Supported Languages
                Container(
                  margin: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minHeight: size.height * .2,
                    maxHeight: size.height * .4,
                  ),
                  child: RadioGroup<String>(
                    groupValue: currLang.name,
                    onChanged: (name) async {
                      if (name == null) return;

                      if (state.language.name != name) {
                        final supportedLanguage = state.systemLanguages
                            .firstWhere((lang) => lang.name == name);
                        await context
                            .read<AppLocalizationCubit>()
                            .changeLanguage(
                              name,
                              supportedLanguage.title,
                            );
                        onChange();
                      }
                    },
                    child: ListView.separated(
                      itemBuilder: (_, i) {
                        final supportedLanguage = state.systemLanguages[i];
                        final selected =
                            currLang.name == supportedLanguage.name;

                        return Container(
                          decoration: BoxDecoration(
                            color: selected
                                ? Theme.of(context).primaryColor
                                : colorScheme.onTertiary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: RadioListTile<String>(
                            toggleable: true,
                            activeColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            value: supportedLanguage.name,
                            title: Text(
                              supportedLanguage.title,
                              style: textStyle.copyWith(
                                color: selected
                                    ? Colors.white
                                    : colorScheme.onTertiary,
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, i) => const SizedBox(height: 12),
                      itemCount: state.systemLanguages.length,
                    ),
                  ),
                ),

                ///
                const Spacer(),
                CustomRoundedButton(
                  onTap: Navigator.of(context).pop,
                  widthPercentage: 1,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonTitle: context.tr('save'),
                  radius: 8,
                  showBorder: false,
                  height: 45,
                ),

                const Expanded(child: SizedBox(height: 20)),
              ],
            ),
          );
        },
      ),
    );
  }
}
