import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/bouncy_tap.dart';
import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Signature Bella Olonje floating-circle product card matching the reference design.
///
/// Features:
/// - Floating circular food dish with ambient soft shadow (zero text overlap)
/// - Discount percentage badge (e.g. -20%)
/// - Interactive Favorite heart icon (top-end)
/// - Bold 2-line title & prominent price
/// - Quick Add "+" button
class BellaProductCard extends StatelessWidget {
  final Item item;
  final double? width;
  final bool inStore;
  final bool isCampaign;
  final VoidCallback? onBeforeTap;

  const BellaProductCard({
    super.key,
    required this.item,
    this.width,
    this.inStore = false,
    this.isCampaign = false,
    this.onBeforeTap,
  });

  void _handleTap(BuildContext context) {
    onBeforeTap?.call();
    Get.find<ItemController>().navigateToItemPage(
      item,
      context,
      inStore: inStore,
      isCampaign: isCampaign,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (width != null) {
      return _buildCard(context, width!);
    }
    return LayoutBuilder(
      builder: (context, constraints) => _buildCard(context, constraints.maxWidth),
    );
  }

  Widget _buildCard(BuildContext context, double cardWidth) {
    // Proportional image size (56% to 60% of card width)
    final double imageSize = (cardWidth * 0.58).clamp(84.0, 116.0);
    // Calculated offset guarantees the circular dish never overlaps the title text
    final double cardTopPadding = (imageSize * 0.62) + 14.0;
    const Color priceColor = Color(0xFFFA4A0C);

    final double? startingPrice = Get.isRegistered<ItemController>()
        ? (Get.find<ItemController>().getStartingPrice(item) ?? item.price)
        : item.price;

    final bool stockEnabled = Get.isRegistered<SplashController>()
        ? (Get.find<SplashController>().configModel?.moduleConfig?.module?.stock ?? false)
        : false;
    final bool isStatusInactive = item.status == 0;
    final bool isOutOfStock = stockEnabled && item.stock != null && item.stock! <= 0;
    final bool isTimeAvailable = DateConverter.isAvailable(item.availableTimeStarts, item.availableTimeEnds);
    final bool isAvailable = !isStatusInactive && !isOutOfStock && isTimeAvailable;

    // Calculate discount text if applicable
    String? discountStr;
    if (item.discount != null && item.discount! > 0) {
      if (item.discountType == 'percent' || item.discountType == 'percentage') {
        discountStr = '-${item.discount!.toInt()}%';
      } else if (startingPrice != null && startingPrice > 0) {
        final pct = ((item.discount! / startingPrice) * 100).round();
        discountStr = '-$pct%';
      } else {
        discountStr = 'SAVE';
      }
    }

    return SizedBox(
      width: cardWidth,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // White Card Body with generous 30px rounded corners & soft shadow
          BouncyTap(
            onTap: () => _handleTap(context),
            shrinkScale: 0.96,
            child: Container(
              width: cardWidth,
              margin: EdgeInsets.only(top: imageSize * 0.38),
              padding: EdgeInsets.fromLTRB(
                10,
                cardTopPadding,
                10,
                12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF393939).withValues(alpha: 0.08),
                    blurRadius: 22,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Product Title: Bold, centered, 2-line max
                  Text(
                    item.name ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1A1A),
                      height: 1.22,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Price: Bold centered in signature accent
                  Text(
                    PriceConverter.convertPrice(
                      startingPrice ?? 0,
                      discount: item.discount,
                      discountType: item.discountType,
                    ),
                    textAlign: TextAlign.center,
                    style: robotoBold.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: priceColor,
                      letterSpacing: -0.3,
                    ),
                  ),

                  if (item.discount != null && item.discount! > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      PriceConverter.convertPrice(startingPrice ?? 0),
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        decoration: TextDecoration.lineThrough,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Quick Add / Cart Count Controller (or disabled pill if unavailable/OOS)
                  if (!isAvailable && (isStatusInactive || isOutOfStock || !(item.scheduleOrder ?? false)))
                    Container(
                      constraints: const BoxConstraints(minHeight: 30),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isOutOfStock ? 'out_of_stock'.tr : 'unavailable'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoBold.copyWith(
                          color: Colors.grey.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    CartCountView(
                      item: item,
                      onBeforeAdd: onBeforeTap,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 30),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A859),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00A859).withValues(alpha: 0.30),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'add'.tr,
                              style: robotoBold.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Floating Circular Food Dish Image (Overlapping Top Edge)
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => _handleTap(context),
              child: Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomImage(
                        image: item.imageFullUrl ?? '',
                        fit: BoxFit.cover,
                        width: imageSize,
                        height: imageSize,
                      ),
                      if (!isAvailable)
                        Container(
                          color: Colors.black.withValues(alpha: 0.55),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            isOutOfStock ? 'out_of_stock'.tr : 'not_available_now_break'.tr,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Discount Badge Tag (Top-Start)
          if (discountStr != null)
            PositionedDirectional(
              top: imageSize * 0.42,
              start: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE53935).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  discountStr,
                  style: robotoBold.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

          // Favorite Heart Icon (Top-End)
          PositionedDirectional(
            top: imageSize * 0.42,
            end: 8,
            child: GetBuilder<FavouriteController>(
              builder: (favController) {
                final bool isFav = favController.wishItemIdList.contains(item.id);
                return BouncyTap(
                  onTap: () {
                    if (AuthHelper.isLoggedIn()) {
                      isFav
                          ? favController.removeFromFavouriteList(item.id, false)
                          : favController.addToFavouriteList(item, null, false);
                    } else {
                      showCustomSnackBar('you_are_not_logged_in'.tr);
                    }
                  },
                  shrinkScale: 0.85,
                  child: Container(
                    height: 28,
                    width: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 15,
                      color: isFav ? const Color(0xFFE53935) : const Color(0xFF9E9E9E),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
