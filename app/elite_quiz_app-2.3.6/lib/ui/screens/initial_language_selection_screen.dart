import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class InitialLanguageSelectionScreen extends StatefulWidget {
  const InitialLanguageSelectionScreen({super.key});

  @override
  State<InitialLanguageSelectionScreen> createState() =>
      _InitialLanguageSelectionScreenState();

  static Route<dynamic> route() => CupertinoPageRoute(
    builder: (_) => const InitialLanguageSelectionScreen(),
  );
}

class _InitialLanguageSelectionScreenState
    extends State<InitialLanguageSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLocalizationCubit, AppLocalizationState>(
      builder: (context, state) {
        final currLang = state.language;

        return Scaffold(
          appBar: QAppBar(
            automaticallyImplyLeading: false,
            title: Text(context.tr('selectLanguage')!),
            usePrimaryColor: true,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.height * UiUtils.vtMarginPct,
              horizontal: context.width * UiUtils.hzMarginPct,
            ),
            child: RadioGroup<String>(
              groupValue: currLang.name,
              onChanged: (name) async {
                if (name == null) return;

                if (state.language.name != name) {
                  final language = state.systemLanguages.firstWhere(
                    (lang) => lang.name == name,
                  );
                  await context.read<AppLocalizationCubit>().changeLanguage(
                    name,
                    language.title,
                  );
                  setState(() {});
                }
              },
              child: ListView.separated(
                itemBuilder: (context, i) {
                  final language = state.systemLanguages[i];

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: .7),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: RadioListTile<String>(
                      toggleable: true,
                      activeColor: currLang.name == language.name
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      title: Text(
                        language.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                      value: language.name,
                    ),
                  );
                },
                separatorBuilder: (_, i) =>
                    const SizedBox(height: UiUtils.listTileGap),
                itemCount: state.systemLanguages.length,
              ),
            ),
          ),
          floatingActionButton: _confirmAndContinueButton,
        );
      },
    );
  }

  FloatingActionButton get _confirmAndContinueButton => FloatingActionButton(
    onPressed: () =>
        Navigator.of(context).pushReplacementNamed(Routes.introSlider),
    backgroundColor: Theme.of(context).primaryColor,
    foregroundColor: Theme.of(context).colorScheme.surface,
    child: const Icon(Icons.check),
  );
}
