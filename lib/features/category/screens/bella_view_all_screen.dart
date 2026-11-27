import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/common/widgets/bouncy_tap.dart';
import 'package:sixam_mart/common/widgets/bella_product_card.dart';
import 'package:sixam_mart/common/widgets/smart_quick_cart_dock.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/category/domain/services/category_service_interface.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/item/domain/services/item_service_interface.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

/// Full-Width Responsive Category Browse & Filtered View-All Screen.
/// Clean layout with NO sidebars, reclaiming 100% responsive screen width.
/// Features:
/// - Glassy top horizontal category capsule selector with 2-word truncation.
/// - Autonomous category item loading & pagination per selected capsule.
/// - 2-Column Product Grid spanning the full screen width with soft shadows.
/// - Playful cartoon illustration for empty states.
/// - Glassmorphic SmartQuickCartDock.
class BellaViewAllScreen extends StatefulWidget {
  final String title;
  final List<Item> items;
  final String? initialSearch;
  final int? selectedCategoryId;

  const BellaViewAllScreen({
    super.key,
    required this.title,
    this.items = const [],
    this.initialSearch,
    this.selectedCategoryId,
  });

  @override
  State<BellaViewAllScreen> createState() => _BellaViewAllScreenState();
}

class _BellaViewAllScreenState extends State<BellaViewAllScreen> {
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();

  bool _isSearching = false;
  String _currentQuery = '';
  int _activeCategoryId = 0; // 0 = "All Items" or category ID
  String _activeSort = 'default';

  List<Item> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    final String initialSearchText = (widget.initialSearch ?? '').trim();
    _currentQuery = initialSearchText.toLowerCase();
    _searchController = TextEditingController(text: initialSearchText);
    _activeCategoryId = widget.selectedCategoryId ?? 0;
    _scrollController.addListener(_onScroll);

    _isLoading = true;
    _fetchCategoryProducts(_activeCategoryId, 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catController = Get.find<CategoryController>();
      if (catController.categoryList == null || catController.categoryList!.isEmpty) {
        catController.getCategoryList(false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && !_isLoading && _hasMore) {
        _loadMore();
      }
    }
  }

  void _onSelectCategory(int categoryId) {
    if (_activeCategoryId == categoryId && !_isLoading && !_hasError) return;
    HapticFeedback.lightImpact();

    setState(() {
      _activeCategoryId = categoryId;
      _isLoading = true;
      _hasError = false;
      _currentPage = 1;
      _hasMore = true;
      _items = [];
    });

    _fetchCategoryProducts(categoryId, 1);
  }

  Future<ItemModel?> _fetchPage(int categoryId, int page) async {
    if (categoryId == 0) {
      return await Get.find<ItemServiceInterface>().getPopularItemList(
        type: 'all',
        source: DataSourceEnum.client,
        offset: page,
      );
    }
    return await Get.find<CategoryServiceInterface>().getCategoryItemList(
      categoryId.toString(),
      page,
      'all',
      limit: 20,
    );
  }

  Future<void> _fetchCategoryProducts(int categoryId, int page) async {
    final int targetId = categoryId;

    try {
      final ItemModel? model = await _fetchPage(targetId, page);
      final List<Item> fetched = model?.items ?? [];

      if (mounted && _activeCategoryId == targetId) {
        setState(() {
          _items = fetched;
          _isLoading = false;
          _hasError = model == null;
          _hasMore = fetched.isNotEmpty && (model?.totalSize ?? 0) > _items.length;
        });
      }
    } catch (_) {
      if (mounted && _activeCategoryId == targetId) {
        setState(() {
          _items = [];
          _isLoading = false;
          _hasMore = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    final int nextPage = _currentPage + 1;
    final int currentCatId = _activeCategoryId;

    try {
      final ItemModel? model = await _fetchPage(currentCatId, nextPage);

      if (mounted && _activeCategoryId == currentCatId) {
        final List<Item>? incoming = model?.items;
        if (model != null && incoming != null && incoming.isNotEmpty) {
          final Set<int> existingIds = _items.map((e) => e.id).whereType<int>().toSet();
          final List<Item> uniqueIncoming = incoming
              .where((e) => e.id == null || !existingIds.contains(e.id))
              .toList();
          setState(() {
            _currentPage = nextPage;
            _items.addAll(uniqueIncoming);
            _hasMore = uniqueIncoming.isNotEmpty && (model.totalSize ?? 0) > _items.length;
          });
        } else {
          setState(() {
            _hasMore = false;
          });
        }
      }
    } catch (_) {
      // Ignore load more failure; user can scroll again to retry
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  String _truncateToTwoWords(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length <= 2) return text.trim();
    return '${words[0]} ${words[1]}';
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('خضار') || lower.contains('فواكه') || lower.contains('fruit') || lower.contains('veg') || lower.contains('market')) {
      return Icons.eco_rounded;
    }
    if (lower.contains('ألبان') || lower.contains('أجبان') || lower.contains('dairy') || lower.contains('milk') || lower.contains('cheese')) {
      return Icons.egg_rounded;
    }
    if (lower.contains('لحوم') || lower.contains('أسماك') || lower.contains('meat') || lower.contains('fish') || lower.contains('chicken')) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains('مخبوزات') || lower.contains('bakery') || lower.contains('bread')) {
      return Icons.bakery_dining_rounded;
    }
    if (lower.contains('مشروبات') || lower.contains('عصائر') || lower.contains('drink') || lower.contains('juice') || lower.contains('water')) {
      return Icons.local_drink_rounded;
    }
    if (lower.contains('سناك') || lower.contains('شيبس') || lower.contains('snack') || lower.contains('chip')) {
      return Icons.cookie_rounded;
    }
    if (lower.contains('حلويات') || lower.contains('شوكولاتة') || lower.contains('sweet') || lower.contains('candy') || lower.contains('chocolate')) {
      return Icons.cake_rounded;
    }
    if (lower.contains('أرز') || lower.contains('مكرونة') || lower.contains('rice') || lower.contains('pasta')) {
      return Icons.rice_bowl_rounded;
    }
    if (lower.contains('زيوت') || lower.contains('بهارات') || lower.contains('oil') || lower.contains('spice')) {
      return Icons.soup_kitchen_rounded;
    }
    if (lower.contains('معلبات') || lower.contains('canned')) {
      return Icons.inventory_2_rounded;
    }
    if (lower.contains('فطور') || lower.contains('مربيات') || lower.contains('breakfast')) {
      return Icons.breakfast_dining_rounded;
    }
    if (lower.contains('مجمدات') || lower.contains('frozen') || lower.contains('ice')) {
      return Icons.ac_unit_rounded;
    }
    if (lower.contains('منظفات') || lower.contains('clean')) {
      return Icons.cleaning_services_rounded;
    }
    if (lower.contains('عناية') || lower.contains('care') || lower.contains('beauty')) {
      return Icons.spa_rounded;
    }
    if (lower.contains('مستورد') || lower.contains('فاخر') || lower.contains('luxury') || lower.contains('import')) {
      return Icons.public_rounded;
    }
    if (lower.contains('🇯🇴') || lower.contains('jordan') || lower.contains('local') || lower.contains('بلدي')) {
      return Icons.flag_rounded;
    }
    return Icons.category_rounded;
  }

  List<Item> _getFilteredDisplayItems() {
    List<Item> result = List<Item>.from(_items);

    // Apply Search Query
    if (_currentQuery.isNotEmpty) {
      result = result.where((item) {
        final name = item.name?.toLowerCase() ?? '';
        final desc = item.description?.toLowerCase() ?? '';
        return name.contains(_currentQuery) || desc.contains(_currentQuery);
      }).toList();
    }

    // Apply Sorting
    if (_activeSort == 'low_high' || _activeSort == 'high_low') {
      double effectivePrice(Item item) {
        final double startingPrice = Get.isRegistered<ItemController>()
            ? (Get.find<ItemController>().getStartingPrice(item) ?? item.price ?? 0)
            : (item.price ?? 0);
        return PriceConverter.convertWithDiscount(
              startingPrice,
              item.discount ?? 0,
              item.discountType,
            ) ??
            startingPrice;
      }
      if (_activeSort == 'low_high') {
        result.sort((a, b) => effectivePrice(a).compareTo(effectivePrice(b)));
      } else {
        result.sort((a, b) => effectivePrice(b).compareTo(effectivePrice(a)));
      }
    }

    return result;
  }

  void _showSortModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Sort Products'.tr,
                    style: robotoBold.copyWith(fontSize: 18, color: const Color(0xFF1C1C1E)),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.sort_rounded, color: Color(0xFF891C1E)),
                  title: Text('Default Sorting'.tr),
                  trailing: _activeSort == 'default' ? const Icon(Icons.check_circle_rounded, color: Color(0xFF00A859)) : null,
                  onTap: () {
                    setState(() => _activeSort = 'default');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_upward_rounded, color: Color(0xFF891C1E)),
                  title: Text('Price: Low to High'.tr),
                  trailing: _activeSort == 'low_high' ? const Icon(Icons.check_circle_rounded, color: Color(0xFF00A859)) : null,
                  onTap: () {
                    setState(() => _activeSort = 'low_high');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_downward_rounded, color: Color(0xFF891C1E)),
                  title: Text('Price: High to Low'.tr),
                  trailing: _activeSort == 'high_low' ? const Icon(Icons.check_circle_rounded, color: Color(0xFF00A859)) : null,
                  onTap: () {
                    setState(() => _activeSort = 'high_low');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLtr = Get.find<LocalizationController>().isLtr;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          centerTitle: false,
          leadingWidth: 60,
          titleSpacing: 12,
          leading: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 14),
              child: BouncyTap(
                onTap: () => Navigator.pop(context),
                shrinkScale: 0.90,
                child: Container(
                  height: 38,
                  width: 38,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLtr ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: const Color(0xFF1C1C1E),
                  ),
                ),
              ),
            ),
          ),
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (val) => setState(() => _currentQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search items...'.tr,
                    border: InputBorder.none,
                    hintStyle: robotoRegular.copyWith(color: Colors.grey.shade400, fontSize: 14),
                  ),
                )
              : Text(
                  _truncateToTwoWords(widget.title.tr),
                  style: robotoBold.copyWith(
                    color: const Color(0xFF1C1C1E),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
          actions: [
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close_rounded : CupertinoIcons.search,
                color: const Color(0xFF1C1C1E),
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _currentQuery = '';
                  }
                });
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GetBuilder<CategoryController>(builder: (categoryController) {
              final List<Item> displayItems = _getFilteredDisplayItems();

              return CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 1. Sleek Glassy Top Category Capsule Filter Strip (Full Width)
                  SliverToBoxAdapter(
                    child: _buildTopFilterCapsules(categoryController),
                  ),

                  // 2. Sort, Filter & Count Strip
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        children: [
                          BouncyTap(
                            onTap: _showSortModal,
                            shrinkScale: 0.94,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.sort_rounded, size: 14, color: Color(0xFF891C1E)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Sort'.tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1C1C1E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _isLoading ? '...' : '${displayItems.length} ${'items'.tr}',
                              style: robotoMedium.copyWith(
                                fontSize: 11.5,
                                color: const Color(0xFF4B5563),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Shimmer Loading State
                  if (_isLoading)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 100),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Shimmer(
                            duration: const Duration(seconds: 1),
                            color: Colors.white,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          childCount: 6,
                        ),
                      ),
                    )
                  // 4. 2-Column Product Grid (Spanning 100% Screen Width)
                  else if (displayItems.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 100),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = displayItems[index];
                            return BellaProductCard(
                              item: item,
                            );
                          },
                          childCount: displayItems.length,
                        ),
                      ),
                    )
                  // 5. Playful Empty State
                  else
                    SliverToBoxAdapter(
                      child: _buildPlayfulEmptyState(),
                    ),

                  // 6. Pagination Bottom Spinner
                  if (_isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF891C1E),
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),

            // Glassmorphic Floating Cart Dock at Bottom
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SmartQuickCartDock(bottomMargin: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Top Horizontal Category Capsule Filter Bar
  Widget _buildTopFilterCapsules(CategoryController categoryController) {
    final List<_FilterCapsule> categories = [
      _FilterCapsule(id: 0, name: 'All Items'.tr, icon: Icons.storefront_rounded),
    ];

    if (categoryController.categoryList != null && categoryController.categoryList!.isNotEmpty) {
      for (final cat in categoryController.categoryList!) {
        if (cat.id != null) {
          categories.add(_FilterCapsule(
            id: cat.id!,
            name: cat.name ?? '',
            icon: _getCategoryIcon(cat.name ?? ''),
          ));
        }
      }
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 42,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final bool isSelected = _activeCategoryId == cat.id;
            final String punchyTitle = _truncateToTwoWords(cat.name);

            return BouncyTap(
              onTap: () => _onSelectCategory(cat.id),
              shrinkScale: 0.94,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF891C1E) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF891C1E) : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF891C1E).withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.icon,
                      size: 16,
                      color: isSelected ? Colors.white : const Color(0xFF4B5563),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      punchyTitle.tr,
                      style: robotoBold.copyWith(
                        fontSize: 12,
                        color: isSelected ? Colors.white : const Color(0xFF1F2937),
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Playful Cartoonic 3D Empty State
  Widget _buildPlayfulEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFF891C1E).withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                Images.emptyCart,
                width: 72,
                height: 72,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  CupertinoIcons.cube_box_fill,
                  size: 54,
                  color: Color(0xFF891C1E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _hasError ? 'something_went_wrong'.tr : 'No Products Found'.tr,
            style: robotoBold.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _hasError ? 'connection_to_api_server_failed'.tr : 'no_items_in_category_found'.tr,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(
              fontSize: 13,
              color: const Color(0xFF8E8E93),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          BouncyTap(
            onTap: () {
              if (_hasError) {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
                _fetchCategoryProducts(_activeCategoryId, 1);
              } else {
                _searchController.clear();
                _currentQuery = '';
                _onSelectCategory(0);
              }
            },
            shrinkScale: 0.94,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF891C1E),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF891C1E).withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _hasError ? 'retry'.tr : 'Explore All Products'.tr,
                style: robotoBold.copyWith(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterCapsule {
  final int id;
  final String name;
  final IconData icon;

  const _FilterCapsule({
    required this.id,
    required this.name,
    required this.icon,
  });
}
