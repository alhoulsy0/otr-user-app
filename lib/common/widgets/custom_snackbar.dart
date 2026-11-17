import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Modern floating snackbar (replaces the old Fluttertoast). Same signature as
/// before so every existing call site keeps working — `getXSnackBar` is accepted
/// for compatibility but no longer changes behaviour.
void showCustomSnackBar(String? message, {bool isError = true, bool getXSnackBar = false, int? showDuration, double? bottomMargin, String? actionLabel, VoidCallback? onAction}) {
  if (message == null || message.isEmpty) return;

  // Replace any visible/queued snackbar so messages don't stack up.
  if (Get.isSnackbarOpen) {
    Get.closeAllSnackbars();
  }

  final Color background = isError ? const Color(0xFFD32F2F) : const Color(0xFF00A859);

  Get.showSnackbar(GetSnackBar(
    snackPosition: SnackPosition.TOP,
    backgroundColor: background,
    borderRadius: 16,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    padding: const EdgeInsets.symmetric(
      horizontal: Dimensions.paddingSizeDefault, vertical: 14,
    ),
    duration: Duration(seconds: showDuration ?? 2),
    animationDuration: const Duration(milliseconds: 350),
    forwardAnimationCurve: Curves.easeOutCirc,
    reverseAnimationCurve: Curves.easeInCirc,
    isDismissible: true,
    dismissDirection: DismissDirection.up,
    boxShadows: <BoxShadow>[
      BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 16, offset: const Offset(0, 6)),
    ],
    mainButton: (actionLabel != null && onAction != null) ? TextButton(
      onPressed: () {
        Get.closeAllSnackbars();
        onAction();
      },
      child: Text(actionLabel, style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault)),
    ) : null,
    messageText: Row(children: <Widget>[
      Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded, color: Colors.white, size: 22),
      const SizedBox(width: Dimensions.paddingSizeSmall),
      Expanded(
        child: Text(
          message,
          style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
        ),
      ),
    ]),
  ));
}
