import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/bouncy_tap.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/screens/cart_screen.dart';
import 'package:sixam_mart/features/cart/screens/global_cart_screen.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/styles.dart';

/// Smart Quick-Cart Floating Dock
/// Modern floating dock that appears when the user has items in their unified basket.
/// Gives instant visibility into basket total, item count, and quick 1-tap checkout.
class SmartQuickCartDock extends StatelessWidget {
  final double bottomMargin;

  const SmartQuickCartDock({
    super.key,
    this.bottomMargin = 74,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      final String route = Get.currentRoute.toLowerCase();
      final bool inCartOrCheckout = route.contains('cart') ||
          route.contains('checkout') ||
          route.contains('order_success') ||
          route.contains('payment');

      final bool hasItems = cartController.cartList.isNotEmpty || cartController.allCartsItemCount > 0;
      if (!hasItems ||
          cartController.isCartPageOpen ||
          inCartOrCheckout ||
          (Get.isBottomSheetOpen ?? false) ||
          (Get.isDialogOpen ?? false)) {
        return const SizedBox.shrink();
      }

      final int totalItems = cartController.totalCartItemQuantity > 0
          ? cartController.totalCartItemQuantity
          : cartController.cartList.fold<int>(
              0,
              (sum, item) => sum + (item.quantity ?? 1),
            );
      double subTotal = cartController.subTotal;
      if (subTotal == 0 && cartController.cartList.isNotEmpty) {
        for (var item in cartController.cartList) {
          subTotal += ((item.discountedPrice ?? item.price ?? 0) * (item.quantity ?? 1));
        }
      }

      return AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        offset: Offset.zero,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomMargin),
          child: BouncyTap(
            onTap: () {
              HapticFeedback.lightImpact();
              int? storeId;
              if (cartController.cartList.isNotEmpty) {
                storeId = cartController.cartList.first.item?.storeId;
              } else if (cartController.allCartsGroups != null && cartController.allCartsGroups!.isNotEmpty) {
                storeId = cartController.allCartsGroups!.first.store?.id;
              }
              if (storeId != null && (cartController.allCartsGroups == null || cartController.allCartsGroups!.length <= 1)) {
                CartScreen.openAsBottomSheet(context, storeId: storeId);
              } else {
                Get.to(() => const GlobalCartScreen(fromNav: false));
              }
            },
            shrinkScale: 0.96,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00A859).withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00A859).withValues(alpha: 0.90),
                          const Color(0xFF008746).withValues(alpha: 0.94),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.32),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                    // Cart Icon with count badge
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.bag_fill,
                            color: Colors.white,
                            size: 20,
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Center(
                                child: Text(
                                  '$totalItems',
                                  style: robotoBold.copyWith(
                                    color: const Color(0xFF008746),
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Basket Value & Delivery Note
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                PriceConverter.convertPrice(subTotal),
                                style: robotoBold.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$totalItems ${totalItems == 1 ? 'item'.tr : 'items'.tr}',
                                  style: robotoMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFB8F3D2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '3 Branches Unified Basket'.tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(
                                    color: const Color(0xFFE2FBEB),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Action Arrow Button (No text to prevent overlap)
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: Color(0xFF008746),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
});
  }
}
