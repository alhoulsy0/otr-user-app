import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/bella_product_card.dart';
import 'package:sixam_mart/features/category/screens/bella_view_all_screen.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// 2-Column Grid of Clean Luxury Supermarket Catalog Cards matching reference screenshots.
class BellaProductGrid extends StatelessWidget {
  final String title;
  final List<Item>? items;
  final int? categoryId;

  const BellaProductGrid({
    super.key,
    required this.title,
    this.items,
    this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      final productList = items ?? itemController.reviewedItemList ?? itemController.popularItemList;

      if (productList == null || productList.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.tr,
                      style: robotoBold.copyWith(
                        fontSize: 18,
                        color: const Color(0xFF1C1C1E),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Up to 70% off • Irbid 18-min Delivery'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Get.to(() => BellaViewAllScreen(
                      title: title.tr,
                      items: productList,
                      selectedCategoryId: categoryId,
                    ));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          'View All'.tr,
                          style: robotoBold.copyWith(
                            fontSize: 13,
                            color: const Color(0xFFE53935),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFFE53935)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: 8,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.62,
            ),
            itemCount: productList.take(20).length,
            itemBuilder: (context, index) {
              return BellaProductCard(
                item: productList[index],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      );
    });
  }
}
