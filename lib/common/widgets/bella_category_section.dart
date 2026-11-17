import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/bouncy_tap.dart';
import 'package:sixam_mart/common/widgets/bella_product_card.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/category/screens/bella_view_all_screen.dart';
import 'package:sixam_mart/features/category/screens/category_item_screen.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/exclusive_products_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Multiple vertical category sections with horizontal product carousels
/// and perfectly circular duotone category capsules (2-word max limit).
class BellaCategorySection extends StatefulWidget {
  const BellaCategorySection({super.key});

  @override
  State<BellaCategorySection> createState() => _BellaCategorySectionState();
}

class _BellaCategorySectionState extends State<BellaCategorySection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catController = Get.find<CategoryController>();
      catController.getCategoryList(true);
      Get.find<FlashSaleController>().getFlashSale(false, false);
      Get.find<ItemController>().getPopularItemList(offset: '1');
      Get.find<ItemController>().getDiscountedItemList(offset: '1');
      Get.find<ItemController>().getReviewedItemList(offset: '1');
    });
  }

  void _openViewAll({
    required String title,
    required List<Item> items,
    int? categoryId,
  }) {
    Get.to(
      () => BellaViewAllScreen(
        title: _truncateToTwoWords(title),
        items: items,
        selectedCategoryId: categoryId,
      ),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 250),
    );
  }

  String _truncateToTwoWords(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length <= 2) return text.trim();
    return '${words[0]} ${words[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      return GetBuilder<CategoryController>(builder: (categoryController) {
        return GetBuilder<FlashSaleController>(builder: (flashSaleController) {
          // Datasets
          final List<Item> importedItems = ExclusiveProductsHelper.getImportedLuxuryProducts();
          final List<Item> exclusiveItems = ExclusiveProductsHelper.getExclusiveEliteProducts();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Horizontal Category Circular Capsules Row
              _buildCategoryCircularCapsulesRow(categoryController),

              const SizedBox(height: 14),

              // 1. Section: Imported Luxury Goods (Category 80: Coffee & Tea)
              _buildVerticalCategoryRow(
                title: 'Imported Luxury'.tr,
                subtitle: 'European & American Gourmet'.tr,
                badgeEmoji: '☕',
                items: importedItems,
                onViewAll: () => _openViewAll(
                  title: 'Imported Luxury'.tr,
                  items: importedItems,
                  categoryId: 80,
                ),
              ),

              const SizedBox(height: 14),

              // 2. Section: OTR Exclusive Luxury (Category 56: Snacks & Chocolate)
              _buildVerticalCategoryRow(
                title: 'Exclusive Luxury'.tr,
                subtitle: 'Dubai Knafeh & Swiss Masterpieces'.tr,
                badgeEmoji: '🍫',
                items: exclusiveItems,
                onViewAll: () => _openViewAll(
                  title: 'Exclusive Luxury'.tr,
                  items: exclusiveItems,
                  categoryId: 56,
                ),
              ),

              const SizedBox(height: 14),
            ],
          );
        });
      });
    });
  }

  List<Item> _getDealsItems(FlashSaleController flashSaleController, ItemController itemController) {
    final activeProds = flashSaleController.flashSaleModel?.activeProducts;
    if (activeProds != null && activeProds.isNotEmpty) {
      final items = activeProds.where((p) => p.item != null).map((p) => p.item!).toList();
      if (items.isNotEmpty) return items;
    }
    if (itemController.discountedItemList?.isNotEmpty == true) {
      return itemController.discountedItemList!;
    }
    return ExclusiveProductsHelper.getImportedLuxuryProducts();
  }

  // Top Category Pills - Perfectly Circular Capsules with Duotone Minimalist Styling
  Widget _buildCategoryCircularCapsulesRow(CategoryController categoryController) {
    final List<_CatChip> categories = [];

    // Base ordered chips definition
    final List<_CatChip> baseOrderedChips = [
      const _CatChip(
        id: 0,
        name: 'All Items',
        icon: Icons.storefront_rounded,
        bgColor: Color(0xFF1E2022),
        iconColor: Colors.white,
      ),
      const _CatChip(
        id: 80,
        name: 'Coffee & Tea',
        icon: Icons.coffee_rounded,
        tag: 'Gourmet',
        tagColor: Color(0xFFFF9800),
        bgColor: Color(0xFFFFF3E0),
        iconColor: Color(0xFFE65100),
      ),
      const _CatChip(
        id: 56,
        name: 'Snacks & Chocolate',
        icon: Icons.cookie_rounded,
        tag: 'Top',
        tagColor: Color(0xFF891C1E),
        bgColor: Color(0xFFFFEBEE),
        iconColor: Color(0xFF891C1E),
      ),
      const _CatChip(
        id: 1,
        name: 'Fruit & Veg',
        icon: Icons.eco_rounded,
        tag: 'Daily',
        tagColor: Color(0xFF00A859),
        bgColor: Color(0xFFE8F5E9),
        iconColor: Color(0xFF2E7D32),
      ),
      const _CatChip(
        id: 6,
        name: 'Bakery',
        icon: Icons.bakery_dining_rounded,
        bgColor: Color(0xFFFBE9E7),
        iconColor: Color(0xFFD84315),
      ),
      const _CatChip(
        id: 21,
        name: 'Dairy & Eggs',
        icon: Icons.egg_rounded,
        bgColor: Color(0xFFE3F2FD),
        iconColor: Color(0xFF1565C0),
      ),
      const _CatChip(
        id: 18,
        name: 'Roastery',
        icon: Icons.spa_rounded,
        bgColor: Color(0xFFEDE7F6),
        iconColor: Color(0xFF512DA8),
      ),
      const _CatChip(
        id: 65,
        name: 'Beverages',
        icon: Icons.local_drink_rounded,
        bgColor: Color(0xFFE0F7FA),
        iconColor: Color(0xFF00838F),
      ),
      _CatChip(
        id: -1,
        name: 'brands'.tr,
        icon: Icons.local_offer_rounded,
        tag: 'Top',
        tagColor: const Color(0xFFFF9800),
        bgColor: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFE65100),
        onTapOverride: () => Get.toNamed(RouteHelper.getBrandsScreen()),
      ),
    ];

    final categoryList = categoryController.categoryList;
    final Set<int> addedIds = {};

    // 1. Add base ordered chips (use backend name if available)
    for (final base in baseOrderedChips) {
      if (base.id > 0 && categoryList != null) {
        final match = categoryList.firstWhereOrNull((c) => c.id == base.id);
        if (match != null) {
          categories.add(_CatChip(
            id: base.id,
            name: match.name ?? base.name,
            icon: base.icon,
            tag: base.tag,
            tagColor: base.tagColor,
            bgColor: base.bgColor,
            iconColor: base.iconColor,
          ));
          addedIds.add(base.id);
          continue;
        }
      }
      categories.add(base);
      if (base.id > 0) addedIds.add(base.id);
    }

    // 2. Append any additional categories from backend admin
    if (categoryList != null && categoryList.isNotEmpty) {
      final List<Color> bgColors = [
        const Color(0xFFE0F2F1),
        const Color(0xFFFCE4EC),
        const Color(0xFFFFF8E1),
        const Color(0xFFEDE7F6),
      ];
      final List<Color> iconColors = [
        const Color(0xFF00796B),
        const Color(0xFFC2185B),
        const Color(0xFFF57F17),
        const Color(0xFF512DA8),
      ];

      for (int i = 0; i < categoryList.length; i++) {
        final cat = categoryList[i];
        final id = cat.id ?? 0;
        if (addedIds.contains(id)) continue;

        IconData icon = Icons.category_rounded;
        if (id == 13) icon = Icons.cleaning_services_rounded;
        if (id == 14) icon = Icons.spa_rounded;

        final colorIndex = i % bgColors.length;
        categories.add(_CatChip(
          id: id,
          name: cat.name ?? '',
          icon: icon,
          bgColor: bgColors[colorIndex],
          iconColor: iconColors[colorIndex],
        ));
        addedIds.add(id);
      }
    }

    return SizedBox(
      height: 96,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final String punchyTitle = _truncateToTwoWords(cat.name);

          return BouncyTap(
            onTap: () {
              if (cat.onTapOverride != null) {
                cat.onTapOverride!();
              } else if (cat.id == 0) {
                Get.toNamed(RouteHelper.getCategoryRoute());
              } else {
                Get.to(() => CategoryItemScreen(
                  categoryID: cat.id.toString(),
                  categoryName: cat.name,
                ));
              }
            },
            shrinkScale: 0.92,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Tag Badge
                SizedBox(
                  height: 14,
                  child: cat.tag != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: cat.tagColor ?? const Color(0xFF891C1E),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cat.tag!.tr,
                            style: robotoBold.copyWith(
                              fontSize: 8.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 3),

                // Perfectly Circular Capsule Icon / Image
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: cat.bgColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: cat.iconColor.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Center(
                      child: Icon(
                        cat.icon ?? Icons.category_rounded,
                        size: 24,
                        color: cat.iconColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),

                // Punchy 2-Word Category Title
                SizedBox(
                  width: 68,
                  child: Text(
                    punchyTitle.tr,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF1F2937),
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Single Vertical Category Row with Header and Horizontal Carousel
  Widget _buildVerticalCategoryRow({
    required String title,
    String? subtitle,
    required String badgeEmoji,
    required List<Item> items,
    required VoidCallback onViewAll,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    final String punchyTitle = _truncateToTwoWords(title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        badgeEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        punchyTitle.tr,
                        style: robotoBold.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1C1C1E),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: robotoRegular.copyWith(
                        fontSize: 11.5,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ],
              ),

              // View All Button (Direct Filter Trigger)
              BouncyTap(
                onTap: onViewAll,
                shrinkScale: 0.90,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF891C1E).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'View All'.tr,
                        style: robotoBold.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF891C1E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: Color(0xFF891C1E),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Horizontal Carousel of Bella Olonje Cards
        SizedBox(
          height: 274,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length > 15 ? 15 : items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = items[index];
              return BellaProductCard(
                item: item,
                width: 165,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CatChip {
  final int id;
  final String name;
  final IconData? icon;
  final String? tag;
  final Color? tagColor;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback? onTapOverride;

  const _CatChip({
    required this.id,
    required this.name,
    this.icon,
    this.tag,
    this.tagColor,
    required this.bgColor,
    required this.iconColor,
    this.onTapOverride,
  });
}
