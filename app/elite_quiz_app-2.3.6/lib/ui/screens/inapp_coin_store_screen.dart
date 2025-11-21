import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/commons/widgets/custom_snackbar.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/in_app_purchase/in_app_product.dart';
import 'package:flutterquiz/features/in_app_purchase/in_app_purchase_cubit.dart';
import 'package:flutterquiz/features/in_app_purchase/in_app_purchase_repo.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class CoinStoreScreen extends StatefulWidget {
  const CoinStoreScreen({super.key});

  @override
  State<CoinStoreScreen> createState() => _CoinStoreScreenState();

  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<InAppPurchaseCubit>(create: (_) => InAppPurchaseCubit()),
          BlocProvider<UpdateCoinsCubit>(
            create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],
        child: const CoinStoreScreen(),
      ),
    );
  }
}

class _CoinStoreScreenState extends State<CoinStoreScreen>
    with SingleTickerProviderStateMixin {
  List<String> productIds = [];
  List<InAppProduct> iapProducts = [];

  bool get _isGuest => context.read<AuthCubit>().isGuest;

  String fetchError = '';

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await fetchProducts();
      initPurchase();
    });
  }

  Future<void> fetchProducts() async {
    iapProducts = await InAppPurchaseRepo.fetchInAppProducts()
        .then((value) {
          setState(() {
            fetchError = '';
          });
          return value;
        })
        .catchError((Object e) {
          setState(() {
            fetchError = e.toString();
          });
          return <InAppProduct>[];
        });
    if (context.read<UserDetailsCubit>().removeAds()) {
      iapProducts.removeWhere((e) => e.isRemoveAds);
    }
    productIds = iapProducts.map((e) => e.productId).toSet().toList();
  }

  void initPurchase() {
    context.read<InAppPurchaseCubit>().initializePurchase(productIds);
  }

  Widget _buildProducts(List<ProductDetails> products) {
    final size = context;
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> restorePurchases() async {
      return context.read<InAppPurchaseCubit>().restorePurchases();
    }

    return Stack(
      children: [
        GridView.builder(
          padding: EdgeInsets.symmetric(
            vertical: size.height * UiUtils.vtMarginPct,
            horizontal: size.width * UiUtils.hzMarginPct,
          ),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, idx) {
            final product = products[idx];
            final iap = iapProducts.firstWhere(
              (e) => e.productId == product.id,
            );

            void purchaseProduct() {
              if (context.read<InAppPurchaseCubit>().state
                  is InAppPurchaseProcessInProgress) {
                return;
              }

              if (_isGuest) {
                showLoginDialog(
                  context,
                  onTapYes: () {
                    context
                      ..shouldPop() // close dialog
                      ..shouldPop() // menu screen
                      ..pushNamed(Routes.login);
                  },
                );
                return;
              }

              context.read<InAppPurchaseCubit>().buyConsumableProducts(product);
            }

            return GestureDetector(
              onTap: purchaseProduct,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 15),
                      child: iap.image.endsWith('.svg')
                          ? SvgPicture.network(iap.image, width: 40, height: 26)
                          : Image.network(iap.image, width: 40, height: 26),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        iap.desc,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onTertiary.withValues(alpha: 0.4),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(
                      iap.title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onTertiary,
                        fontWeight: FontWeights.semiBold,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 4,
                      ),
                      child: Text(
                        product.price,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeights.semiBold,
                          color: colorScheme.onTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),

        /// Restore Button
        if (Platform.isIOS && !_isGuest)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
              child: CustomRoundedButton(
                widthPercentage: 1,
                backgroundColor: Theme.of(context).primaryColor,
                buttonTitle: context.tr('restorePurchaseProducts'),
                radius: 8,
                showBorder: false,
                fontWeight: FontWeights.semiBold,
                height: 58,
                titleColor: colorScheme.surface,
                onTap: restorePurchases,
                elevation: 6.5,
                textSize: 18,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (shouldPop, _) {
        if (shouldPop) return;

        if (context.read<InAppPurchaseCubit>().state
            is! InAppPurchaseProcessInProgress) {
          context.shouldPop();
        }
      },
      child: Scaffold(
        appBar: QAppBar(
          title: Text(context.tr(coinStoreKey)!),
          onTapBackButton: () {
            if (context.read<InAppPurchaseCubit>().state
                is! InAppPurchaseProcessInProgress) {
              context.shouldPop();
            }
          },
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: BlocConsumer<InAppPurchaseCubit, InAppPurchaseState>(
                bloc: context.read<InAppPurchaseCubit>(),
                listener: (context, state) async {
                  if (state is InAppPurchaseProcessSuccess) {
                    final iap = iapProducts.firstWhere(
                      (e) => e.productId == state.purchasedProductId,
                    );

                    final success = await context
                        .read<InAppPurchaseCubit>()
                        .verifyAndPurchase();

                    if (success) {
                      // We don't want to show the Remove Ads IAP, after purchasing it.
                      if (iap.isRemoveAds) {
                        context.read<UserDetailsCubit>().updateUserProfile(
                          adsRemovedForUser: '1',
                        );

                        state.products.removeWhere(
                          (e) => e.id == iap.productId,
                        );
                        setState(() {});
                      } else {
                        unawaited(
                          context.read<UserDetailsCubit>().fetchUserDetails(),
                        );
                      }

                      ///
                      context.showSnack(
                        "${iap.title} ${context.tr("boughtSuccess")!}",
                      );
                    }
                  } else if (state is InAppPurchaseProcessFailure) {
                    if (!state.errorMessage.contains('userCanceled')) {
                      final error =
                          context.tr(
                            convertErrorCodeToLanguageKey(state.errorMessage),
                          ) ??
                          '';
                      if (error.isNotEmpty) {
                        context.showSnack(error);
                      }
                    }
                  }
                },
                builder: (context, state) {
                  if (fetchError.isNotEmpty) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: false,
                        errorMessage: convertErrorCodeToLanguageKey(fetchError),
                        onTapRetry: () async {
                          await fetchProducts();
                          initPurchase();
                        },
                        showErrorImage: true,
                      ),
                    );
                  }

                  //initial state of cubit
                  if (state is InAppPurchaseInitial ||
                      state is InAppPurchaseLoading) {
                    return const Center(child: CircularProgressContainer());
                  }

                  //if occurred problem while fetching product details
                  //from appstore or playstore
                  if (state is InAppPurchaseFailure) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: false,
                        errorMessage: state.errorMessage,
                        onTapRetry: initPurchase,
                        showErrorImage: true,
                      ),
                    );
                  }

                  if (state is InAppPurchaseNotAvailable) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: false,
                        errorMessage: inAppPurchaseUnavailableKey,
                        onTapRetry: initPurchase,
                        showErrorImage: true,
                      ),
                    );
                  }

                  //if any error occurred in while making in-app purchase
                  if (state is InAppPurchaseProcessFailure) {
                    return _buildProducts(state.products);
                  }
                  if (state is InAppPurchaseAvailable) {
                    return _buildProducts(state.products);
                  }
                  if (state is InAppPurchaseProcessSuccess) {
                    return _buildProducts(state.products);
                  }
                  if (state is InAppPurchaseProcessInProgress) {
                    final textTheme = Theme.of(context).textTheme;
                    final textColor = Theme.of(context).canvasColor;

                    return Stack(
                      children: [
                        _buildProducts(state.products),
                        Container(
                          width: double.maxFinite,
                          color: Colors.black26,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressContainer(),
                              Text(
                                context.tr('iapProcessingTitle')!,
                                style: textTheme.titleLarge?.copyWith(
                                  color: textColor,
                                ),
                              ),
                              Text(
                                context.tr('iapProcessingMessage')!,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
