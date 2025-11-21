import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';

/// A dialog that prompts users to purchase more coins when they don't have enough
/// coins to access certain features.
///
/// This dialog is shown in various scenarios:
/// * When trying to enter a contest
/// * When attempting to unlock premium categories
/// * When trying to review answers
/// * When creating a battle room
/// * Any other feature that requires coins
///
/// The dialog provides two options:
/// * Close - Dismisses the dialog
/// * Buy Coins - Navigates to the coin store
///
/// Usage:
/// ```dart
/// await showNotEnoughCoinsDialog(context);
/// ```
Future<void> showNotEnoughCoinsDialog(BuildContext context) async {
  final isCoinStoreEnabled = context
      .read<SystemConfigCubit>()
      .isCoinStoreEnabled;

  return context.showDialog(
    title: context.tr(notEnoughCoinsKey),
    message: context.tr('notEnoughCoinsDialogMessage'),
    image: Assets.coinsDialogIcon,
    cancelButtonText: context.tr('notNow'),
    confirmButtonText: isCoinStoreEnabled ? context.tr('buyCoins') : null,
    onConfirm: isCoinStoreEnabled
        ? () => globalCtx.pushNamed(Routes.coinStore)
        : null,
  );
}
