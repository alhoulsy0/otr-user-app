import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/screens/cart_screen.dart';
import 'package:sixam_mart/features/cart/screens/global_cart_screen.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

/// Minimalist header matching Bella Olonje reference design.
///
/// Features:
/// - Clean hamburger menu icon (left) that opens drawer
/// - Deliver to address badge (center)
/// - Minimalist Cart icon with badge (right)
class BellaHeaderWidget extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const BellaHeaderWidget({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Delivery Badge & Location Dropdown
          Expanded(
            child: GetBuilder<LocationController>(builder: (locationController) {
              final address = AddressHelper.getUserAddressFromSharedPref()?.address?.trim();
              final displayText = (address != null && address.isNotEmpty)
                  ? address
                  : 'Irbid - Jordan (All Branches)'.tr;

              return InkWell(
                onTap: () => locationController.navigateToLocationScreen('home'),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Deliver to label with pin
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 15,
                            color: Color(0xFF891C1E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Deliver to'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: 11,
                              color: const Color(0xFF757575),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Location Dropdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              displayText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: robotoBold.copyWith(
                                fontSize: 13,
                                color: const Color(0xFF222222),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: Color(0xFF666666),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          // Notification Icon with Badge
          GetBuilder<NotificationController>(builder: (notificationController) {
            return InkWell(
              onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      Images.bellOn,
                      height: 22,
                      width: 22,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  if (notificationController.hasNotification)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(width: 1.5, color: Theme.of(context).cardColor),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),

          const SizedBox(width: 4),

          // Cart Icon with Badge
          GetBuilder<CartController>(builder: (cartController) {
            final int cartCount = cartController.totalCartItemQuantity;

            return InkWell(
              onTap: () {
                final int? storeId = cartController.cartList.isNotEmpty ? cartController.cartList.first.item?.storeId : null;
                if (storeId != null && (cartController.allCartsGroups == null || cartController.allCartsGroups!.length <= 1)) {
                  CartScreen.openAsBottomSheet(context, storeId: storeId);
                } else {
                  Get.to(() => const GlobalCartScreen(fromNav: false));
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      CupertinoIcons.cart,
                      size: 24,
                      color: Color(0xFF000000),
                    ),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '$cartCount',
                            style: robotoBold.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
