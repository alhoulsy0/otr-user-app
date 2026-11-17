import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/screens/cart_screen.dart';
import 'package:sixam_mart/features/cart/screens/global_cart_screen.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';



// void showCartSnackBar() {
//   ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
//     dismissDirection: DismissDirection.horizontal,
//     margin: EdgeInsets.only(
//       right: ResponsiveHelper.isDesktop(Get.context) ? Get.context!.width*0.7 : Dimensions.paddingSizeSmall,
//       top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall,
//     ),
//     duration: const Duration(seconds: 3),
//     backgroundColor: Colors.green,
//     behavior: SnackBarBehavior.floating,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
//     content: Text('item_added_to_cart'.tr, style: robotoMedium.copyWith(color: Colors.white)),
//     action: SnackBarAction(label: 'view_cart'.tr, onPressed: () => Get.toNamed(RouteHelper.getCartRoute()), textColor: Colors.white),
//   ));
//
//   Future.delayed(const Duration(seconds: 3), () {
//     ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
//   });
// }


void showCartSnackBar() {
  if (Get.isSnackbarOpen) {
    Get.closeAllSnackbars();
  }

  Get.showSnackbar(GetSnackBar(
    snackPosition: SnackPosition.TOP,
    backgroundColor: const Color(0xFF00A859),
    borderRadius: 16,
    margin: EdgeInsets.fromLTRB(
      Dimensions.paddingSizeDefault,
      12,
      ResponsiveHelper.isDesktop(Get.context) ? Get.context!.width * 0.7 : Dimensions.paddingSizeDefault,
      12,
    ),
    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 14),
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 350),
    forwardAnimationCurve: Curves.easeOutCirc,
    reverseAnimationCurve: Curves.easeInCirc,
    isDismissible: true,
    dismissDirection: DismissDirection.up,
    boxShadows: <BoxShadow>[
      BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 16, offset: const Offset(0, 6)),
    ],
    messageText: Row(children: <Widget>[
      const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 22),
      const SizedBox(width: Dimensions.paddingSizeSmall),
      Expanded(
        child: Text(
          'item_added_to_cart'.tr,
          style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
        ),
      ),
    ]),
    mainButton: IconButton(
      onPressed: () {
        Get.closeAllSnackbars();
        final cartController = Get.find<CartController>();
        int? storeId;
        if (cartController.cartList.isNotEmpty) {
          storeId = cartController.cartList.first.item?.storeId;
        } else if (cartController.allCartsGroups != null && cartController.allCartsGroups!.isNotEmpty) {
          storeId = cartController.allCartsGroups!.first.store?.id;
        }
        if (storeId != null && (cartController.allCartsGroups == null || cartController.allCartsGroups!.length <= 1)) {
          CartScreen.openAsBottomSheet(Get.context!, storeId: storeId);
        } else {
          Get.to(() => const GlobalCartScreen(fromNav: false));
        }
      },
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    ),
  ));
}
