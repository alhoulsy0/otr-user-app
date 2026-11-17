import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/bella_product_card.dart';
import 'package:sixam_mart/common/widgets/smart_quick_cart_dock.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class CategoryItemScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  const CategoryItemScreen({super.key, required this.categoryID, required this.categoryName});

  @override
  CategoryItemScreenState createState() => CategoryItemScreenState();
}

class CategoryItemScreenState extends State<CategoryItemScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final CategoryController controller = Get.find<CategoryController>();
    controller.getSubCategoryList(widget.categoryID);
    controller.getCategoryItemList(widget.categoryID, 1, controller.type, false);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch(CategoryController controller) {
    if (controller.isSearching) {
      _searchTextController.clear();
      _searchFocusNode.unfocus();
    }
    controller.toggleSearch();
    if (controller.isSearching) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocusNode.requestFocus());
    }
  }

  void _submitSearch(CategoryController controller, String query) {
    controller.searchData(query, _resolveCategoryId(controller), controller.type);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 100) return;
    final CategoryController controller = Get.find<CategoryController>();
    if (controller.isLoading) return;

    if (controller.categoryItemList == null) return;
    final int pageSize = ((controller.pageSize ?? 0) / 10).ceil();
    if (controller.offset >= pageSize) return;
    controller.showBottomLoader();
    controller.getCategoryItemList(
      _resolveCategoryId(controller),
      controller.offset + 1, controller.type, false,
    );
  }

  String? _resolveCategoryId(CategoryController controller) {
    if (controller.subCategoryIndex == 0 || controller.subCategoryList == null) {
      return widget.categoryID;
    }
    return controller.subCategoryList![controller.subCategoryIndex].id.toString();
  }

  @override
  Widget build(BuildContext context) {
    final Color tinted = Color.alphaBlend(
      Theme.of(context).disabledColor.withAlpha(30),
      Theme.of(context).cardColor,
    );

    return GetBuilder<CategoryController>(builder: (catController) {
      final List<Item> items = catController.isSearching
          ? List<Item>.from(catController.searchItemList ?? const <Item>[])
          : List<Item>.from(catController.categoryItemList ?? const <Item>[]);
      final List<Store> stores = catController.isSearching
          ? List<Store>.from(catController.searchStoreList ?? const <Store>[])
          : List<Store>.from(catController.categoryStoreList ?? const <Store>[]);

      final bool itemsReady = catController.isSearching
          ? catController.searchItemList != null
          : catController.categoryItemList != null;
      final bool storesReady = catController.isSearching
          ? catController.searchStoreList != null
          : catController.categoryStoreList != null;

      return PopScope(
        canPop: !catController.isSearching,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop && catController.isSearching) {
            _toggleSearch(catController);
          }
        },
        child: Scaffold(
          backgroundColor: tinted,
          appBar: CustomAppBar(
            title: widget.categoryName,
            backButton: true,
            showCart: true,
            type: catController.type,
            isSearchActive: catController.isSearching,
            onSearchTap: () => _toggleSearch(catController),
            onBackPressed: () {
              if (catController.isSearching) {
                _toggleSearch(catController);
              } else {
                Get.back();
              }
            },
            onVegFilterTap: (String type) {
              if (catController.isSearching) {
                catController.searchData(
                  _searchTextController.text, _resolveCategoryId(catController), type,
                );
              } else if (catController.isStore) {
                catController.getCategoryStoreList(_resolveCategoryId(catController), 1, type, true);
              } else {
                catController.getCategoryItemList(_resolveCategoryId(catController), 1, type, true);
              }
            },
          ),
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          bottomNavigationBar: const SafeArea(child: SmartQuickCartDock(bottomMargin: 8)),
          body: SafeArea(
            bottom: false,
            child: ResponsiveHelper.isDesktop(context)
                ? Center(child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: SingleChildScrollView(child: FooterView(child: _buildContent(
                      context: context,
                      controller: catController,
                      items: items, stores: stores,
                      itemsReady: itemsReady, storesReady: storesReady,
                      tinted: tinted,
                      asSlivers: false,
                    ))),
                  ))
                : _buildContent(
                    context: context,
                    controller: catController,
                    items: items, stores: stores,
                    itemsReady: itemsReady, storesReady: storesReady,
                    tinted: tinted,
                    asSlivers: true,
                  ),
          ),
        ),
      );
    });
  }

  Widget _buildContent({
    required BuildContext context,
    required CategoryController controller,
    required List<Item> items,
    required List<Store> stores,
    required bool itemsReady,
    required bool storesReady,
    required Color tinted,
    required bool asSlivers,
  }) {
    final Widget searchBar = _CategorySearchBar(
      controller: _searchTextController,
      focusNode: _searchFocusNode,
      onSubmitted: (String query) => _submitSearch(controller, query),
      onClear: () => _toggleSearch(controller),
    );

    // Only show the sub-category strip when there is at least one sub-category
    // to choose from — otherwise it would render an empty fixed-height band.
    final bool showSubCategoryBar = !controller.isSearching
        && controller.subCategoryList != null
        && controller.subCategoryList!.isNotEmpty;
    final Widget subCategoryBar = showSubCategoryBar
        ? _SubCategoryStrip(controller: controller, parentCategoryID: widget.categoryID)
        : const SizedBox.shrink();

    final Widget body = _buildItemsBody(context: context, controller: controller, items: items, itemsReady: itemsReady);

    final Widget paginationLoader = controller.isLoading ? const Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    ) : const SizedBox.shrink();

    if (!asSlivers) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        if (controller.isSearching) searchBar else ...[
          if (showSubCategoryBar) subCategoryBar,
        ],
        body,
        paginationLoader,
      ]);
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        if (controller.isSearching)
          SliverToBoxAdapter(child: searchBar)
        else ...[
          if (showSubCategoryBar)
            SliverToBoxAdapter(child: subCategoryBar),
        ],
        SliverToBoxAdapter(child: body),
        SliverToBoxAdapter(child: paginationLoader),
      ],
    );
  }

  Widget _buildItemsBody({
    required BuildContext context,
    required CategoryController controller,
    required List<Item> items,
    required bool itemsReady,
  }) {
    if (!itemsReady) {
      return const _LoadingPlaceholder();
    }
    if (items.isEmpty) {
      return _EmptyView(message: 'no_category_item_found'.tr);
    }
    final int count = items.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        8,
        Dimensions.paddingSizeDefault,
        80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Found $count results'.tr,
                style: robotoBold.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 22,
              crossAxisSpacing: 16,
              childAspectRatio: 0.63,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return LayoutBuilder(
                builder: (ctx, constraints) {
                  return BellaProductCard(
                    item: items[index],
                    width: constraints.maxWidth,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SubCategoryStrip extends StatelessWidget {
  final CategoryController controller;
  final String? parentCategoryID;

  const _SubCategoryStrip({required this.controller, required this.parentCategoryID});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.subCategoryList!.length,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final bool isSelected = index == controller.subCategoryIndex;
          final Color primary = Theme.of(context).primaryColor;
          return Padding(
            padding: EdgeInsets.only(right: index == controller.subCategoryList!.length - 1 ? 0 : Dimensions.paddingSizeSmall),
            child: InkWell(
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
              onTap: () => controller.setSubCategoryIndex(index, parentCategoryID),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primary : Theme.of(context).disabledColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                ),
                child: Center(child: Text(
                  controller.subCategoryList![index].name ?? '',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                )),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategorySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _CategorySearchBar({required this.controller, required this.focusNode, required this.onSubmitted, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).disabledColor.withValues(alpha: 0.18);
    final Color hintColor = Theme.of(context).disabledColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge + Dimensions.radiusDefault),
          border: Border.all(color: borderColor),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'search'.tr,
            hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: hintColor),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeDefault,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeSmall),
              child: Icon(Icons.search, size: 20, color: hintColor),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: GestureDetector(
              onTap: onClear,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                child: Icon(Icons.close, size: 20, color: hintColor),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ),
    );
  }
}



class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 1),
      interval: const Duration(milliseconds: 500),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          children: List<Widget>.generate(
            6,
            (int index) => Padding(
              padding: EdgeInsets.only(bottom: index == 5 ? 0 : Dimensions.paddingSizeLarge),
              child: const _ItemShimmerRow(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Grey placeholder box used as the base for the shimmer sweep.
class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const _ShimmerBox({this.width, required this.height, this.radius = Dimensions.radiusSmall});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Mimics a full-width category item row (image + text lines).
class _ItemShimmerRow extends StatelessWidget {
  const _ItemShimmerRow();

  @override
  Widget build(BuildContext context) {
    return const Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      _ShimmerBox(width: 90, height: 90, radius: Dimensions.radiusDefault),
      SizedBox(width: Dimensions.paddingSizeDefault),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          _ShimmerBox(width: 160, height: 14),
          SizedBox(height: Dimensions.paddingSizeSmall),
          _ShimmerBox(width: 110, height: 12),
          SizedBox(height: Dimensions.paddingSizeSmall),
          _ShimmerBox(width: 70, height: 12),
          SizedBox(height: Dimensions.paddingSizeSmall),
          _ShimmerBox(width: 90, height: 14),
        ]),
      ),
    ]);
  }
}


class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}
