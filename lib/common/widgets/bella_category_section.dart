import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/bouncy_tap.dart';
import 'package:sixam_mart/common/widgets/bella_product_card.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/category/domain/services/category_service_interface.dart';
import 'package:sixam_mart/features/category/screens/bella_view_all_screen.dart';
import 'package:sixam_mart/features/category/screens/category_item_screen.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
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
  List<Item> _importedItems = [];
  List<Item> _exclusiveItems = [];
  bool _isLoadingImported = true;
  bool _isLoadingExclusive = true;
  bool _importedError = false;
  bool _exclusiveError = false;
  String? _loadedLocaleCode;
  int _importedGeneration = 0;
  int _exclusiveGeneration = 0;
  LocalizationController? _localizationController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<LocalizationController>()) {
      _localizationController = Get.find<LocalizationController>();
      _localizationController!.addListener(_onLocalizationChanged);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final catController = Get.find<CategoryController>();
      if (catController.categoryList == null || catController.categoryList!.isEmpty) {
        catController.getCategoryList(true);
      }
      Get.find<FlashSaleController>().getFlashSale(false, false);
      _loadedLocaleCode = _currentLocaleCode();
      _loadLuxurySections();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndReloadForLocaleChange();
  }

  @override
  void dispose() {
    _localizationController?.removeListener(_onLocalizationChanged);
    super.dispose();
  }

  String _currentLocaleCode() {
    if (Get.isRegistered<LocalizationController>()) {
      return Get.find<LocalizationController>().locale.languageCode;
    }
    return Get.locale?.languageCode ?? Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
  }

  void _onLocalizationChanged() {
    if (!mounted) return;
    _checkAndReloadForLocaleChange();
  }

  void _checkAndReloadForLocaleChange() {
    final String currentLocale = _currentLocaleCode();
    if (_loadedLocaleCode != null && _loadedLocaleCode != currentLocale) {
      _loadedLocaleCode = currentLocale;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_currentLocaleCode() == currentLocale) {
          _loadLuxurySections();
        }
      });
    }
  }

  CategoryModel? _resolveImportedLuxuryCategory(CategoryController c) {
    final list = c.categoryList;
    if (list == null) return null;
    return list.firstWhereOrNull((cat) => cat.id == AppConstants.importedLuxuryCategoryId) ??
        list.firstWhereOrNull((cat) => cat.slug == AppConstants.importedLuxuryCategorySlug);
  }

  CategoryModel? _resolveExclusiveCategory(CategoryController c) {
    final list = c.categoryList;
    if (list == null) return null;
    return list.firstWhereOrNull((cat) => cat.id == AppConstants.snacksChocolateCategoryId) ??
        list.firstWhereOrNull((cat) => cat.slug == 'snacks-chocolate');
  }

  Future<void> _loadLuxurySections() async {
    await Future.wait([
      _loadImportedItems(),
      _loadExclusiveItems(),
    ]);
  }

  Future<void> _loadImportedItems() async {
    final int generation = ++_importedGeneration;
    if (mounted) {
      setState(() {
        _isLoadingImported = true;
        _importedError = false;
      });
    }
    try {
      final catController = Get.find<CategoryController>();
      final int catId = _resolveImportedLuxuryCategory(catController)?.id ?? AppConstants.importedLuxuryCategoryId;
      final ItemModel? model = await Get.find<CategoryServiceInterface>().getCategoryItemList(
        catId.toString(),
        1,
        'all',
        limit: 15,
      );
      if (!mounted || generation != _importedGeneration) return;
      setState(() {
        _importedItems = model?.items ?? [];
        _isLoadingImported = false;
        _importedError = model == null;
      });
    } catch (_) {
      if (!mounted || generation != _importedGeneration) return;
      setState(() {
        _importedItems = [];
        _isLoadingImported = false;
        _importedError = true;
      });
    }
  }

  Future<void> _loadExclusiveItems() async {
    final int generation = ++_exclusiveGeneration;
    if (mounted) {
      setState(() {
        _isLoadingExclusive = true;
        _exclusiveError = false;
      });
    }
    try {
      final catController = Get.find<CategoryController>();
      final int catId = _resolveExclusiveCategory(catController)?.id ?? AppConstants.snacksChocolateCategoryId;
      final ItemModel? model = await Get.find<CategoryServiceInterface>().getCategoryItemList(
        catId.toString(),
        1,
        'all',
        limit: 15,
      );
      if (!mounted || generation != _exclusiveGeneration) return;
      setState(() {
        _exclusiveItems = model?.items ?? [];
        _isLoadingExclusive = false;
        _exclusiveError = model == null;
      });
    } catch (_) {
      if (!mounted || generation != _exclusiveGeneration) return;
      setState(() {
        _exclusiveItems = [];
        _isLoadingExclusive = false;
        _exclusiveError = true;
      });
    }
  }

  void _openViewAll({
    required String title,
    int? categoryId,
  }) {
    Get.to(
      () => BellaViewAllScreen(
        title: _truncateToTwoWords(title),
        items: const [],
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
    return GetBuilder<CategoryController>(builder: (categoryController) {
      final CategoryModel? importedCat = _resolveImportedLuxuryCategory(categoryController);
      final int importedCatId = importedCat?.id ?? AppConstants.importedLuxuryCategoryId;
      final String importedTitle = (importedCat?.name != null && importedCat!.name!.trim().isNotEmpty)
          ? importedCat.name!
          : 'Imported Luxury'.tr;

      final CategoryModel? exclusiveCat = _resolveExclusiveCategory(categoryController);
      final int exclusiveCatId = exclusiveCat?.id ?? AppConstants.snacksChocolateCategoryId;
      final String exclusiveTitle = (exclusiveCat?.name != null && exclusiveCat!.name!.trim().isNotEmpty)
          ? exclusiveCat.name!
          : 'Exclusive Luxury'.tr;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Horizontal Category Circular Capsules Row
          _buildCategoryCircularCapsulesRow(context, categoryController),

          const SizedBox(height: 14),

          // 2. Section: Imported Luxury Goods (Dynamic Category 144)
          _buildDynamicCategorySection(
            context: context,
            title: importedTitle,
            subtitle: 'European & American Gourmet'.tr,
            badgeEmoji: '🌍',
            items: _importedItems,
            isLoading: _isLoadingImported,
            hasError: _importedError,
            onRetry: _loadImportedItems,
            onViewAll: () => _openViewAll(
              title: importedTitle,
              categoryId: importedCatId,
            ),
          ),

          const SizedBox(height: 14),

          // 3. Section: Snacks & Chocolate / Exclusive Luxury (Dynamic Category 56)
          _buildDynamicCategorySection(
            context: context,
            title: exclusiveTitle,
            subtitle: 'Snacks & Chocolate'.tr,
            badgeEmoji: '🍫',
            items: _exclusiveItems,
            isLoading: _isLoadingExclusive,
            hasError: _exclusiveError,
            onRetry: _loadExclusiveItems,
            onViewAll: () => _openViewAll(
              title: exclusiveTitle,
              categoryId: exclusiveCatId,
            ),
          ),

          const SizedBox(height: 14),
        ],
      );
    });
  }

  Widget _buildDynamicCategorySection({
    required BuildContext context,
    required String title,
    String? subtitle,
    required String badgeEmoji,
    required List<Item> items,
    required bool isLoading,
    required bool hasError,
    required VoidCallback onRetry,
    required VoidCallback onViewAll,
  }) {
    if (isLoading) {
      return _buildCategoryCarouselShimmer(context);
    }
    if (hasError && items.isEmpty) {
      return _buildCategoryRetryCard(title: title, onRetry: onRetry);
    }
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildVerticalCategoryRow(
      context: context,
      title: title,
      subtitle: subtitle,
      badgeEmoji: badgeEmoji,
      items: items,
      onViewAll: onViewAll,
    );
  }

  Widget _buildCategoryCarouselShimmer(BuildContext context) {
    final double textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final double carouselHeight = math.max(274.0, 134.0 + (140.0 * textScale));
    return SizedBox(
      height: carouselHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return Shimmer(
            duration: const Duration(seconds: 2),
            color: Colors.white,
            child: Container(
              width: 165,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryRetryCard({
    required String title,
    required VoidCallback onRetry,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$title • ${'something_went_wrong'.tr}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(
                  fontSize: 12.5,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'retry'.tr,
                style: robotoBold.copyWith(
                  fontSize: 12.5,
                  color: const Color(0xFF891C1E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCapsulesShimmer(BuildContext context) {
    final double textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final double badgeHeight = math.max(14.0, (10.0 * textScale) + 4.0);
    final double capsuleRowHeight = math.max(96.0, badgeHeight + 3.0 + 56.0 + 5.0 + (11.0 * 1.25 * textScale) + 4.0);
    return SizedBox(
      height: capsuleRowHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 17),
              Shimmer(
                duration: const Duration(seconds: 2),
                color: Colors.white,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Shimmer(
                duration: const Duration(seconds: 2),
                color: Colors.white,
                child: Container(
                  width: 52,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  _CategoryChipStyle _styleForCategory(CategoryModel cat, int paletteIndex) {
    final String key = '${cat.slug ?? ''} ${cat.name ?? ''}'.toLowerCase();

    const List<Color> cyclicBgColors = [
      Color(0xFFE0F2F1),
      Color(0xFFFCE4EC),
      Color(0xFFFFF8E1),
      Color(0xFFEDE7F6),
    ];
    const List<Color> cyclicIconColors = [
      Color(0xFF00796B),
      Color(0xFFC2185B),
      Color(0xFFF57F17),
      Color(0xFF512DA8),
    ];
    final int idx = paletteIndex % cyclicBgColors.length;
    final Color defaultBg = cyclicBgColors[idx];
    final Color defaultIconColor = cyclicIconColors[idx];

    if (key.contains('import') || key.contains('luxury') || key.contains('مستورد') || key.contains('فاخر')) {
      return const _CategoryChipStyle(
        icon: Icons.public_rounded,
        tag: 'Luxury',
        tagColor: Color(0xFF891C1E),
        bgColor: Color(0xFFFFEBEE),
        iconColor: Color(0xFF891C1E),
      );
    }
    if (key.contains('snack') || key.contains('choc') || key.contains('سناك') || key.contains('شوكولات') || key.contains('شيبس')) {
      return const _CategoryChipStyle(
        icon: Icons.cookie_rounded,
        tag: 'Top',
        tagColor: Color(0xFF891C1E),
        bgColor: Color(0xFFFFEBEE),
        iconColor: Color(0xFF891C1E),
      );
    }
    if (key.contains('coffee') || key.contains('tea') || key.contains('قهوة') || key.contains('شاي')) {
      return const _CategoryChipStyle(
        icon: Icons.coffee_rounded,
        tag: 'Gourmet',
        tagColor: Color(0xFFFF9800),
        bgColor: Color(0xFFFFF3E0),
        iconColor: Color(0xFFE65100),
      );
    }
    if (key.contains('fruit') || key.contains('veg') || key.contains('فواكه') || key.contains('خضار') || key.contains('خضروات')) {
      return const _CategoryChipStyle(
        icon: Icons.eco_rounded,
        tag: 'Daily',
        tagColor: Color(0xFF00A859),
        bgColor: Color(0xFFE8F5E9),
        iconColor: Color(0xFF2E7D32),
      );
    }
    if (key.contains('bakery') || key.contains('bread') || key.contains('مخبوزات') || key.contains('خبز')) {
      return const _CategoryChipStyle(
        icon: Icons.bakery_dining_rounded,
        bgColor: Color(0xFFFBE9E7),
        iconColor: Color(0xFFD84315),
      );
    }
    if (key.contains('dairy') || key.contains('egg') || key.contains('milk') || key.contains('ألبان') || key.contains('بيض') || key.contains('حليب')) {
      return const _CategoryChipStyle(
        icon: Icons.egg_rounded,
        bgColor: Color(0xFFE3F2FD),
        iconColor: Color(0xFF1565C0),
      );
    }
    if (key.contains('roastery') || key.contains('محمصة') || key.contains('مكسرات')) {
      return const _CategoryChipStyle(
        icon: Icons.spa_rounded,
        bgColor: Color(0xFFEDE7F6),
        iconColor: Color(0xFF512DA8),
      );
    }
    if (key.contains('beverage') || key.contains('drink') || key.contains('juice') || key.contains('مشروبات') || key.contains('عصائر')) {
      return const _CategoryChipStyle(
        icon: Icons.local_drink_rounded,
        bgColor: Color(0xFFE0F7FA),
        iconColor: Color(0xFF00838F),
      );
    }
    if (key.contains('clean') || key.contains('منظفات')) {
      return _CategoryChipStyle(
        icon: Icons.cleaning_services_rounded,
        bgColor: defaultBg,
        iconColor: defaultIconColor,
      );
    }
    if (key.contains('care') || key.contains('beauty') || key.contains('عناية')) {
      return _CategoryChipStyle(
        icon: Icons.spa_rounded,
        bgColor: defaultBg,
        iconColor: defaultIconColor,
      );
    }
    if (key.contains('meat') || key.contains('poultry') || key.contains('seafood') || key.contains('لحوم') || key.contains('دواجن') || key.contains('أسماك')) {
      return _CategoryChipStyle(
        icon: Icons.restaurant_rounded,
        bgColor: defaultBg,
        iconColor: defaultIconColor,
      );
    }
    if (key.contains('frozen') || key.contains('ice') || key.contains('مجمدات')) {
      return _CategoryChipStyle(
        icon: Icons.ac_unit_rounded,
        bgColor: defaultBg,
        iconColor: defaultIconColor,
      );
    }
    if (key.contains('canned') || key.contains('jarred') || key.contains('معلبات')) {
      return _CategoryChipStyle(
        icon: Icons.inventory_2_rounded,
        bgColor: defaultBg,
        iconColor: defaultIconColor,
      );
    }
    if (key.contains('breakfast') || key.contains('فطور') || key.contains('إفطار')) {
      return _CategoryChipStyle(
        icon: Icons.breakfast_dining_rounded,
        bgColor: defaultBg,
        iconColor: defaultIconColor,
      );
    }
    if (key.contains('cooking') || key.contains('spice') || key.contains('طبخ') || key.contains('بهارات')) {
      return _CategoryChipStyle(
        icon: Icons.soup_kitchen_rounded,
        bgColor: defaultBg,
        iconColor: defaultIconColor,
      );
    }

    return _CategoryChipStyle(
      icon: Icons.category_rounded,
      bgColor: defaultBg,
      iconColor: defaultIconColor,
    );
  }

  // Top Category Pills - Perfectly Circular Capsules with Duotone Minimalist Styling
  Widget _buildCategoryCircularCapsulesRow(BuildContext context, CategoryController categoryController) {
    final List<CategoryModel>? categoryList = categoryController.categoryList;
    if (categoryList == null) {
      return _buildCategoryCapsulesShimmer(context);
    }
    final double textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final double badgeHeight = math.max(14.0, (10.0 * textScale) + 4.0);
    final double capsuleRowHeight = math.max(96.0, badgeHeight + 3.0 + 56.0 + 5.0 + (11.0 * 1.25 * textScale) + 4.0);

    final List<_CatChip> categories = [
      _CatChip(
        id: 0,
        name: 'All Items'.tr,
        icon: Icons.storefront_rounded,
        bgColor: const Color(0xFF1E2022),
        iconColor: Colors.white,
      ),
    ];

    final List<CategoryModel> orderedBackend = [];
    final Set<int> addedIds = {};

    void addIfValid(CategoryModel? cat) {
      final int? id = cat?.id;
      if (cat == null || id == null || id <= 0 || addedIds.contains(id)) return;
      orderedBackend.add(cat);
      addedIds.add(id);
    }

    addIfValid(_resolveImportedLuxuryCategory(categoryController));
    addIfValid(_resolveExclusiveCategory(categoryController));
    for (final cat in categoryList) {
      addIfValid(cat);
    }

    for (int i = 0; i < orderedBackend.length; i++) {
      final CategoryModel cat = orderedBackend[i];
      final _CategoryChipStyle style = _styleForCategory(cat, i);
      categories.add(_CatChip(
        id: cat.id!,
        name: cat.name ?? '',
        icon: style.icon,
        tag: style.tag,
        tagColor: style.tagColor,
        bgColor: style.bgColor,
        iconColor: style.iconColor,
      ));
    }

    categories.add(
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
    );

    return SizedBox(
      height: capsuleRowHeight,
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
                  height: badgeHeight,
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
                    punchyTitle,
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
    required BuildContext context,
    required String title,
    String? subtitle,
    required String badgeEmoji,
    required List<Item> items,
    required VoidCallback onViewAll,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    final String punchyTitle = _truncateToTwoWords(title);
    final double textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final double carouselHeight = math.max(274.0, 134.0 + (140.0 * textScale));

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          badgeEmoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            punchyTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1C1C1E),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                          fontSize: 11.5,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

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
          height: carouselHeight,
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

class _CategoryChipStyle {
  final IconData icon;
  final String? tag;
  final Color? tagColor;
  final Color bgColor;
  final Color iconColor;

  const _CategoryChipStyle({
    required this.icon,
    this.tag,
    this.tagColor,
    required this.bgColor,
    required this.iconColor,
  });
}
