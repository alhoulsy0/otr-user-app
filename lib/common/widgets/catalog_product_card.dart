import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/bouncy_tap.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/styles.dart';

/// Clean luxury supermarket catalog card with restored compact proportions.
/// Features:
/// - Crisp soft-shadow white card with no heavy bounding borders.
/// - Tightened internal padding and optimized image-to-text ratio.
/// - Emerald scalloped discount badge.
/// - Prominent red-accented ADD button with tactile spring physics.
/// - Clean typography with strict 2-line title and struck-through old price.
class CatalogProductCard extends StatelessWidget {
  final Item item;
  final bool inStore;
  final bool isCampaign;
  final VoidCallback? onBeforeTap;
  final double? width;

  const CatalogProductCard({
    super.key,
    required this.item,
    this.inStore = false,
    this.isCampaign = false,
    this.onBeforeTap,
    this.width,
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

  void _handleDirectAdd(BuildContext context) {
    HapticFeedback.lightImpact();
    final bool hasVariations = (item.variations != null && item.variations!.isNotEmpty)
        || (item.foodVariations != null && item.foodVariations!.isNotEmpty);

    if (hasVariations) {
      _handleTap(context);
    } else {
      Get.find<ItemController>().itemDirectlyAddToCart(
        item,
        context,
        inStore: inStore,
        isCampaign: isCampaign,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = (item.discount != null && item.discount! > 0);
    final double price = item.price ?? 0;
    final double discount = item.discount ?? 0;
    final String discountType = item.discountType ?? 'amount';
    final double discountedPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;

    final String discountText = discountType == 'percent' || discountType == 'percentage'
        ? '${discount.toInt()}% ${'off'.tr}'
        : '${'save'.tr} ${PriceConverter.convertPrice(discount)}';

    final bool hasVariations = (item.variations != null && item.variations!.isNotEmpty)
        || (item.foodVariations != null && item.foodVariations!.isNotEmpty);

    final String volumeText = (item.unitType != null && item.unitType!.isNotEmpty)
        ? item.unitType!
        : (item.description != null && item.description!.toLowerCase().contains('250ml'))
            ? '250ml'
            : (item.description != null && item.description!.toLowerCase().contains('500g'))
                ? '500g'
                : '1 pc'.tr;

    return BouncyTap(
      onTap: () => _handleTap(context),
      shrinkScale: 0.97,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E2022).withValues(alpha: 0.06),
              blurRadius: 14,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top Image Container ──────────────────────────────────────────
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: CustomImage(
                      image: item.imageFullUrl ?? '',
                      fit: BoxFit.contain,
                      height: 104,
                      width: 104,
                    ),
                  ),
                ),

                // Scalloped Green Discount Badge (top-left)
                if (hasDiscount)
                  PositionedDirectional(
                    top: 6,
                    start: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A859),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00A859).withValues(alpha: 0.35),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        discountText,
                        style: robotoBold.copyWith(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),

                // Chilled or Exclusive Badge (top-right)
                if (item.organic == 1 || (item.name?.toLowerCase().contains('drink') ?? false) || (item.name?.toLowerCase().contains('chilled') ?? false))
                  PositionedDirectional(
                    top: 6,
                    end: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.ac_unit, size: 9, color: Colors.white),
                          const SizedBox(width: 2.5),
                          Text(
                            'Chilled'.tr,
                            style: robotoBold.copyWith(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (item.categoryId == 80 || (item.price != null && item.price! >= 5.0))
                  PositionedDirectional(
                    top: 6,
                    end: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF891C1E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Luxury'.tr,
                        style: robotoBold.copyWith(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                // Signature ADD Button (bottom-right of image)
                PositionedDirectional(
                  bottom: 5,
                  end: 6,
                  child: BouncyTap(
                    onTap: () => _handleDirectAdd(context),
                    shrinkScale: 0.88,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF891C1E), width: 1.3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ADD'.tr,
                            style: robotoBold.copyWith(
                              color: const Color(0xFF891C1E),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                          if (hasVariations)
                            Text(
                              'options'.tr,
                              style: robotoRegular.copyWith(
                                color: const Color(0xFF8E8E93),
                                fontSize: 7.5,
                                height: 1.0,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Product Details Section (Tightened Padding) ──────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title (2 lines max, tight line height)
                  Text(
                    item.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Volume / Subtitle
                  Text(
                    volumeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: 10.5,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        PriceConverter.convertPrice(discountedPrice),
                        style: robotoBold.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1C1C1E),
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 4),
                        Text(
                          PriceConverter.convertPrice(price),
                          style: robotoRegular.copyWith(
                            fontSize: 10.5,
                            color: const Color(0xFF9E9E9E),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
