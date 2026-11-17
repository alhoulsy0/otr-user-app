import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/bella_bottom_creative_card.dart';
import 'package:sixam_mart/common/widgets/bella_category_section.dart';
import 'package:sixam_mart/common/widgets/bella_header_widget.dart';
import 'package:sixam_mart/common/widgets/bella_popular_section.dart';
import 'package:sixam_mart/common/widgets/bella_product_grid.dart';
import 'package:sixam_mart/common/widgets/bella_search_bar.dart';
import 'package:sixam_mart/common/widgets/typewriter_text.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/home/widgets/views/banner_view.dart';
import 'package:sixam_mart/features/flash_sale/widgets/flash_sale_view_widget.dart';
import 'package:sixam_mart/features/dashboard/widgets/todays_deals_section.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/brands/controllers/brands_controller.dart';
import 'package:sixam_mart/features/brands/widgets/brand_section_widget.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/reels/controllers/reels_controller.dart';
import 'package:sixam_mart/features/reels/widgets/reels_section_widget.dart';
import 'package:sliver_tools/sliver_tools.dart';

class GroceryModuleScreen extends StatefulWidget {
  final Key searchHeaderKey;
  final Key exploreRestaurantKey;
  final ScrollController scrollController;
  final bool isSearchPinned;

  const GroceryModuleScreen({
    super.key,
    required this.searchHeaderKey,
    required this.exploreRestaurantKey,
    required this.scrollController,
    this.isSearchPinned = false,
  });

  @override
  State<GroceryModuleScreen> createState() => _GroceryModuleScreenState();
}

class _GroceryModuleScreenState extends State<GroceryModuleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<OrderController>().getLastOrders(isHome: false);
      Get.find<HomeController>().getTopOffer(notify: false);
      Get.find<ItemController>().getPopularItemList(offset: '1');
      Get.find<ItemController>().getReviewedItemList(offset: '1');
      Get.find<ItemController>().getDiscountedItemList(offset: '1');
      Get.find<BrandsController>().getBrandList();
      Get.find<CartController>().getCartDataOnline();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: [
        // Bella Top Header: Menu (left), Delivery Location (center), Cart badge (right)
        const SliverToBoxAdapter(
          child: BellaHeaderWidget(),
        ),

        // OTR Supermarket Headline & Live Delivery Radar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeDefault,
              8,
              Dimensions.paddingSizeDefault,
              14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GetBuilder<ProfileController>(builder: (profileController) {
                  final String? name = profileController.userInfoModel?.fName;
                  final String greeting = (name != null && name.trim().isNotEmpty)
                      ? '${'hello'.tr}، $name 👋'
                      : 'welcome_to_otr'.tr;
                  return TypewriterText(
                    text: greeting,
                    style: robotoMedium.copyWith(
                      fontSize: 14,
                      color: const Color(0xFF008746),
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF7A1416),
                          Color(0xFF891C1E),
                          Color(0xFFC4292E),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'OTR Supermarket'.tr,
                        style: robotoBold.copyWith(
                          fontSize: 27,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF0ED), Color(0xFFFFE3E0)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF891C1E).withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars_rounded, size: 12, color: Color(0xFF891C1E)),
                          const SizedBox(width: 3),
                          Text(
                            'EXPRESS'.tr,
                            style: robotoBold.copyWith(
                              fontSize: 9,
                              color: const Color(0xFF891C1E),
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Minimalist Pill Search Bar
        const SliverToBoxAdapter(
          child: BellaSearchBar(),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 22),
        ),

        // Interactive Category Tabs & Luxury Showcase (Imported & Exclusive Luxury)
        const SliverToBoxAdapter(
          child: BellaCategorySection(),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 10),
        ),

        // Flash Sale Section (Directly after Luxury section)
        GetBuilder<FlashSaleController>(builder: (controller) {
          final visible = controller.flashSaleModel == null || (controller.flashSaleModel!.activeProducts?.isNotEmpty ?? false);
          return _conditionalSection(visible: visible, slivers: [
            const SliverToBoxAdapter(child: FlashSaleViewWidget()),
            const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeDefault)),
          ]);
        }),

        // Today's Deals Section (Directly after Luxury section & Flash Sales)
        GetBuilder<ItemController>(builder: (controller) {
          final visible = controller.discountedItemList == null || controller.discountedItemList!.isNotEmpty;
          return _conditionalSection(visible: visible, slivers: [
            const SliverToBoxAdapter(child: TodaysDealsSectionWidget()),
            const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeSmall)),
          ]);
        }),

        // Products by Brand Section (aligned with Admin Portal)
        GetBuilder<BrandsController>(builder: (brandsController) {
          final visible = brandsController.brandList != null && brandsController.brandList!.isNotEmpty;
          return _conditionalSection(visible: visible, slivers: [
            SliverToBoxAdapter(
              child: BrandSectionWidget(
                title: "top_brands".tr,
                showLabel: true,
                showItemCount: true,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeDefault)),
          ]);
        }),

        // Popular Items Section (Multi-row grid after Flash Sales & Deals)
        GetBuilder<ItemController>(builder: (itemController) {
          final items = itemController.popularItemList;
          final visible = items == null || items.isNotEmpty;
          return _conditionalSection(visible: visible, slivers: [
            SliverToBoxAdapter(child: BellaPopularSection(items: items)),
            const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeDefault)),
          ]);
        }),

        // Highlights Section (Banner Slider with 'Highlights' title)
        GetBuilder<BannerController>(builder: (controller) {
          final visible = controller.bannerImageList == null || controller.bannerImageList!.isNotEmpty;
          return _conditionalSection(visible: visible, slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault,
                  10,
                  Dimensions.paddingSizeDefault,
                  6,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF891C1E),
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Highlights'.tr,
                      style: robotoBold.copyWith(
                        fontSize: 18,
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: BannerView(isFeatured: false)),
            const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeDefault)),
          ]);
        }),

        // OTR Exclusive Video Reels
        GetBuilder<ReelsController>(builder: (controller) {
          final visible = (controller.reelsList == null && controller.isLoading)
              || (controller.reelsList != null && controller.reelsList!.isNotEmpty);
          return _conditionalSection(visible: visible, slivers: [
            const SliverToBoxAdapter(child: ReelsSectionWidget()),
            const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeDefault)),
          ]);
        }),

        // Promotional Banner (collapses when empty)
        const PromotionalBannerSliver(),

        // 2-Column Staggered Grid of Products (Fresh Finds)
        const SliverToBoxAdapter(
          child: BellaProductGrid(title: 'fresh_finds'),
        ),

        // Minimalist Cool App Footer by Qertex
        const SliverToBoxAdapter(
          child: BellaBottomCreativeCard(),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }
}

Widget _conditionalSection({required bool visible, required List<Widget> slivers}) {
  return visible
      ? MultiSliver(children: slivers)
      : const SliverToBoxAdapter(child: SizedBox.shrink());
}
