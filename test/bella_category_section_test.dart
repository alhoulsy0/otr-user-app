import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/common/widgets/bella_category_section.dart';
import 'package:sixam_mart/common/widgets/bella_product_card.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/domain/models/signup_body_model.dart';
import 'package:sixam_mart/features/auth/domain/models/social_log_in_body.dart';
import 'package:sixam_mart/features/auth/domain/services/auth_service_interface.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/domain/models/all_carts_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/cart/domain/models/online_cart_model.dart' hide Variation;
import 'package:sixam_mart/features/cart/domain/repositories/cart_repository_interface.dart';
import 'package:sixam_mart/features/cart/domain/services/cart_service.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/category/domain/services/category_service_interface.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/favourite/domain/services/favourite_service_interface.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/flash_sale/domain/models/flash_sale_model.dart' hide Translations;
import 'package:sixam_mart/features/flash_sale/domain/models/product_flash_sale.dart';
import 'package:sixam_mart/features/flash_sale/domain/services/flash_sale_service_interface.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/basic_medicine_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_review_model.dart';
import 'package:sixam_mart/features/item/domain/repositories/item_repository_interface.dart';
import 'package:sixam_mart/features/item/domain/services/item_service.dart';
import 'package:sixam_mart/features/item/domain/services/item_service_interface.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/language/domain/models/language_model.dart';
import 'package:sixam_mart/features/language/domain/service/language_service_interface.dart';
import 'package:sixam_mart/features/service_module/service_home/domain/models/service_category_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/splash/domain/models/app_download_section_model.dart';
import 'package:sixam_mart/features/splash/domain/services/splash_service_interface.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';

class _FakeCategoryService implements CategoryServiceInterface {
  List<CategoryModel>? categories;
  ItemModel? Function(String? categoryId)? itemResolver;
  int itemFetchCount = 0;

  _FakeCategoryService({this.categories, this.itemResolver});

  @override
  Future<List<CategoryModel>?> getCategoryList(bool allCategory, {DataSourceEnum? source}) async => categories;

  @override
  Future<ItemModel?> getCategoryItemList(String? categoryID, int offset, String type, {int limit = 10}) async {
    itemFetchCount++;
    if (itemResolver != null) {
      return itemResolver!(categoryID);
    }
    return ItemModel(totalSize: 0, items: const []);
  }

  @override
  Future<List<CategoryModel>?> getSubCategoryList(String? parentID) async => const [];

  @override
  Future<StoreModel?> getCategoryStoreList(String? categoryID, int offset, String type) async => null;

  @override
  Future<Response> getSearchData(String? query, String? categoryID, bool isStore, String type) async =>
      const Response(statusCode: 200);

  @override
  Future<bool> saveUserInterests(List<int?> interests) async => true;

  @override
  Future<List<ServiceCategoryModel>?> getCategoriesWithChildes() async => const [];
}

class _FakeFlashSaleService implements FlashSaleServiceInterface {
  @override
  Future<FlashSaleModel?> getFlashSale(DataSourceEnum source) async => null;

  @override
  Future<ProductFlashSale?> getFlashSaleWithId(int id, int offset) async => null;
}

class _BellaTestTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'All Items': 'All Items',
          'brands': 'Brands',
          'Luxury': 'Luxury',
          'Top': 'Top',
          'Gourmet': 'Gourmet',
          'Daily': 'Daily',
          'Imported Luxury': 'Imported Luxury',
          'Exclusive Luxury': 'Exclusive Luxury',
          'European & American Gourmet': 'European & American Gourmet',
          'Snacks & Chocolate': 'Snacks & Chocolate',
          'View All': 'View All',
          'something_went_wrong': 'Something went wrong',
          'retry': 'Retry',
          'add': 'Add',
          'unavailable': 'Unavailable',
          'out_of_stock': 'Out of Stock',
          'not_available_now_break': 'Not Available\nNow',
        },
        'ar_JO': {
          'All Items': 'كل المنتجات',
          'brands': 'العلامات التجارية',
          'Luxury': 'فاخر',
          'Top': 'مميز',
          'Imported Luxury': 'منتجات مستوردة فاخرة ومختارة بعناية فائقة',
          'Exclusive Luxury': 'شوكولاتة مستوردة وحلويات فاخرة مختارة',
          'European & American Gourmet': 'منتجات أوروبية وأمريكية فاخرة ومستوردة خصيصاً لك',
          'Snacks & Chocolate': 'سناكات وشوكولاتة مستوردة ومقرمشات عالمية',
          'View All': 'عرض الكل',
          'something_went_wrong': 'حدث خطأ ما',
          'retry': 'إعادة المحاولة',
          'add': 'أضف',
          'unavailable': 'غير متاح',
          'out_of_stock': 'نفد المخزون',
          'not_available_now_break': 'غير متاح\nالآن',
        },
      };
}

class _FakeSplashService implements SplashServiceInterface {
  @override
  Future<Response> getConfigData({required DataSourceEnum source}) async => const Response(
        statusCode: 200,
        body: <String, dynamic>{
          'business_name': 'OTR',
          'currency_symbol': 'JOD',
          'currency_symbol_direction': 'left',
          'digit_after_decimal_point': 2,
          'toggle_veg_non_veg': false,
          'module_config': <String, dynamic>{
            'module_type': <String>['grocery'],
            'grocery': <String, dynamic>{
              'order_place_to_schedule_interval': false,
              'add_on': true,
              'stock': true,
              'veg_non_veg': false,
              'unit': false,
              'order_attachment': false,
              'show_restaurant_text': false,
              'is_parcel': false,
              'is_taxi': false,
              'is_ride': false,
              'new_variation': false,
            },
          },
        },
      );
  @override
  ConfigModel? prepareConfigData(Response response) => ConfigModel.fromJson(response.body);
  @override
  Future<ModuleModel?> initSharedData() async => null;
  @override
  ModuleModel? getCacheModule() => null;
  @override
  ModuleModel? getModule() => null;
  @override
  Future<void> setModule(ModuleModel? module) async {}
  @override
  Future<ModuleModel?> setCacheModule(ModuleModel? module) async => module;
  @override
  void disableIntro() {}
  @override
  bool? showIntro() => false;
  @override
  void disableLoginSuggestion() {}
  @override
  bool showLoginSuggestion() => false;
  @override
  Future<void> setStoreCategory(int storeCategoryID) async {}
  @override
  Future<List<ModuleModel>?> getModules({Map<String, String>? headers, required DataSourceEnum source}) async => const [];
  @override
  Future<ResponseModel> subscribeEmail(String email) async => ResponseModel(true, '');
  @override
  bool getSavedCookiesData() => false;
  @override
  Future<void> saveCookiesData(bool data) async {}
  @override
  void cookiesStatusChange(String? data) {}
  @override
  bool getAcceptCookiesStatus(String data) => true;
  @override
  bool getSuggestedLocationStatus() => false;
  @override
  Future<void> saveSuggestedLocationStatus(bool data) async {}
  @override
  bool getReferBottomSheetStatus() => false;
  @override
  Future<void> saveReferBottomSheetStatus(bool data) async {}
  @override
  bool getPaymentIncompleteBottomSheetStatus() => false;
  @override
  Future<void> savePaymentIncompleteBottomSheetStatus(bool data) async {}
  @override
  Future<AppDownloadSectionModel?> getAppDownloadSection() async => null;
  @override
  bool handleInitialTopicSubscription() => false;
}

class _FakeItemRepository implements ItemRepositoryInterface {
  @override
  Future get(String? id, {bool isConditionWiseItem = false, bool isCampaign = false, DataSourceEnum? source}) async => null;
  @override
  Future<ItemReviewModel?> getItemReviews({required int itemId, required int limit, required int offset}) async =>
      ItemReviewModel(totalSize: 0, reviews: const []);
  @override
  Future<BasicMedicineModel?> getBasicMedicine(DataSourceEnum source) async => null;
  @override
  Future getList({int? offset, String? type, bool isPopularItem = false, bool isReviewedItem = false, bool isFeaturedCategoryItems = false, bool isRecommendedItems = false, bool isCommonConditions = false, bool isDiscountedItems = false, DataSourceEnum? source, String? search, List<int>? categoryIds, List<String>? filter, int? rating, double? minPrice, double? maxPrice}) async => null;
  @override
  Future add(value) => throw UnimplementedError();
  @override
  Future delete(int? id) => throw UnimplementedError();
  @override
  Future update(Map<String, dynamic> body, int? id) => throw UnimplementedError();
}

class _FakeCartRepository implements CartRepositoryInterface<OnlineCart> {
  @override
  Future<void> addSharedPrefCartList(List<CartModel> cartProductList) async {}
  @override
  Future<List<OnlineCartModel>?> getCartDataOnline({int? storeId}) async => const [];
  @override
  Future<List<AllCartsModel>?> getAllCarts() async => const [];
  @override
  Future<bool> removeStoreCart(int storeId) async => true;
  @override
  Future<dynamic> add(OnlineCart value, {int? storeId}) async => null;
  @override
  Future<bool> delete(int? id, {bool isRemoveAll = false, int? storeId}) async => true;
  @override
  Future get(String? id) async => null;
  @override
  Future getList({int? offset}) async => const <OnlineCartModel>[];
  @override
  Future<dynamic> update(Map<String, dynamic> body, int? id, {double? price, int? quantity, bool isUpdateQty = false, int? storeId}) async => null;
}

class _FakeFavouriteService implements FavouriteServiceInterface {
  @override
  Future<Response> getFavouriteList() async => const Response(statusCode: 200, body: <String, dynamic>{});
  @override
  Future<ResponseModel> addFavouriteList(int? id, bool isStore, {bool isServiceModule = false}) async => ResponseModel(true, '');
  @override
  Future<ResponseModel> removeFavouriteList(int? id, bool isStore, {bool isServiceModule = false}) async => ResponseModel(true, '');
  @override
  List<Item?> wishItemList(Item item) => const [];
  @override
  List<int?> wishItemIdList(Item item) => const [];
  @override
  List<Store?> wishStoreList(dynamic store) => const [];
  @override
  List<int?> wishStoreIdList(dynamic store) => const [];
}

class _FakeLanguageService implements LanguageServiceInterface {
  @override
  bool setLTR(Locale locale) => locale.languageCode != 'ar';
  @override
  void updateHeader(Locale locale, int? moduleId) {}
  @override
  Locale getLocaleFromSharedPref() => const Locale('en', 'US');
  @override
  int setSelectedIndex(List<LanguageModel> languages, Locale locale) => 0;
  @override
  void saveLanguage(Locale locale) {}
  @override
  void saveCacheLanguage(Locale locale) {}
  @override
  Locale getCacheLocaleFromSharedPref() => const Locale('en', 'US');
}

class _FakeAuthService implements AuthServiceInterface {
  @override
  bool isSharedPrefNotificationActive() => false;
  @override
  bool isLoggedIn() => false;
  @override
  bool isGuestLoggedIn() => false;
  @override
  String getSharedPrefGuestId() => '';
  @override
  Future<bool> clearSharedAddress() async => true;
  @override
  Future<bool> clearSharedData({bool removeToken = true}) async => true;
  @override
  Future<bool> clearUserNumberAndPassword() async => true;
  @override
  Future<bool> clearOtpUserNumber() async => true;
  @override
  String getDmTipIndex() => '';
  @override
  String getEarningPint() => '';
  @override
  String getGuestContactNumber() => '';
  @override
  String getOtpUserCountryCode() => '';
  @override
  String getOtpUserNumber() => '';
  @override
  String getUserCountryCode() => '';
  @override
  String getUserNumber() => '';
  @override
  String getUserPassword() => '';
  @override
  String getUserToken() => '';
  @override
  Future<ResponseModel> guestLogin() async => ResponseModel(false, '');
  @override
  Future<ResponseModel> login({required String emailOrPhone, required String password, required String loginType, required String fieldType, bool alreadyInApp = false}) async => ResponseModel(false, '');
  @override
  Future<ResponseModel> loginWithSocialMedia(SocialLogInBody socialLogInModel, {bool isCustomerVerificationOn = false}) async => ResponseModel(false, '');
  @override
  Future<void> loginWithToken(String token) async {}
  @override
  Future<ResponseModel> otpLogin({required String phone, required String otp, required String loginType, required String verified, bool alreadyInApp = false}) async => ResponseModel(false, '');
  @override
  Future<ResponseModel> registration(SignUpBodyModel signUpBody) async => ResponseModel(false, '');
  @override
  Future<String?> saveDeviceToken() async => null;
  @override
  Future<bool> saveDmTipIndex(String index) async => true;
  @override
  Future<bool> saveEarningPoint(String point) async => true;
  @override
  Future<bool> saveGuestContactNumber(String number) async => true;
  @override
  Future<void> saveOtpUserNumber(String number, String countryCode) async {}
  @override
  Future<void> saveUserNumberAndPassword(String number, String password, String countryCode) async {}
  @override
  Future<void> setNotificationActive(bool isActive) async {}
  @override
  Future<ResponseModel> updatePersonalInfo({required String name, required String? phone, required String loginType, required String? email, required String? referCode, bool alreadyInApp = false}) async => ResponseModel(false, '');
  @override
  Future<void> updateToken() async {}
  @override
  Future updateZone() async {}
}

Future<void> _initCardDependencies() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(sharedPreferences);
  Get.put<ThemeController>(ThemeController(sharedPreferences: sharedPreferences));
  Get.put<AuthController>(AuthController(authServiceInterface: _FakeAuthService()));

  final splashController = SplashController(splashServiceInterface: _FakeSplashService());
  await splashController.getConfigData(source: DataSourceEnum.client, canRoute: false);
  await splashController.setModule(ModuleModel(id: 1, moduleName: 'Grocery', moduleType: 'grocery'), notify: false);
  Get.put<SplashController>(splashController);

  final ItemServiceInterface itemService = ItemService(itemRepositoryInterface: _FakeItemRepository());
  Get.put<ItemServiceInterface>(itemService);
  Get.put<ItemController>(ItemController(itemServiceInterface: itemService));

  final cartService = CartService(cartRepositoryInterface: _FakeCartRepository());
  Get.put<CartController>(CartController(cartServiceInterface: cartService));
  Get.put<FavouriteController>(FavouriteController(favouriteServiceInterface: _FakeFavouriteService()));
  Get.put<LocalizationController>(LocalizationController(languageServiceInterface: _FakeLanguageService()));
}

Widget _wrapTestApp(
  Widget child, {
  Locale locale = const Locale('en', 'US'),
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return GetMaterialApp(
    key: ValueKey<String>('${locale}_$textScaler'),
    translations: _BellaTestTranslations(),
    locale: locale,
    builder: (context, widget) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: widget!,
      );
    },
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    Get.reset();
  });

  group('BellaCategorySection dynamic category chips', () {
    testWidgets('renders shimmer placeholder and zero hardcoded categories when categoryList is null', (tester) async {
      Get.reset();
      final catService = _FakeCategoryService(categories: null);
      Get.put<CategoryServiceInterface>(catService);
      Get.put<CategoryController>(CategoryController(categoryServiceInterface: catService));
      Get.put<FlashSaleController>(FlashSaleController(flashSaleServiceInterface: _FakeFlashSaleService()));

      await tester.pumpWidget(_wrapTestApp(const BellaCategorySection()));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(Shimmer), findsWidgets);
      expect(find.text('Coffee &'), findsNothing);
      expect(find.text('Fruit &'), findsNothing);
      expect(find.text('Bakery'), findsNothing);
      expect(find.text('Dairy &'), findsNothing);
      expect(find.text('Roastery'), findsNothing);
      expect(find.text('Beverages'), findsNothing);
    });

    testWidgets('renders chips strictly from CategoryController.categoryList without hardcoded fallbacks', (tester) async {
      Get.reset();
      final catService = _FakeCategoryService(
        categories: [
          CategoryModel(id: 999, name: 'Organic Honey', slug: 'organic-honey'),
          CategoryModel(id: 144, name: 'Imported Luxury', slug: 'imported-luxury'),
          CategoryModel(id: 56, name: 'Snacks & Chocolate', slug: 'snacks-chocolate'),
        ],
      );
      Get.put<CategoryServiceInterface>(catService);
      final catController = Get.put<CategoryController>(CategoryController(categoryServiceInterface: catService));
      await catController.getCategoryList(true);
      Get.put<FlashSaleController>(FlashSaleController(flashSaleServiceInterface: _FakeFlashSaleService()));

      await tester.pumpWidget(_wrapTestApp(const BellaCategorySection()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('All Items'), findsOneWidget);
      expect(find.text('Imported Luxury'), findsOneWidget);
      expect(find.text('Organic Honey'), findsOneWidget);
      expect(find.text('Brands'), findsOneWidget);
      expect(find.text('Luxury'), findsOneWidget);

      // Hardcoded categories omitted from backend list must not be rendered
      expect(find.text('Coffee &'), findsNothing);
      expect(find.text('Fruit &'), findsNothing);
      expect(find.text('Bakery'), findsNothing);
      expect(find.text('Dairy &'), findsNothing);
      expect(find.text('Roastery'), findsNothing);
      expect(find.text('Beverages'), findsNothing);
    });

    testWidgets('renders long EN and AR category headers with loaded items on 320px narrow viewport without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final List<Item> sampleItems = [
        Item(
          id: 501,
          name: 'Ferrero Rocher Golden Gift Box 24 Pieces',
          price: 4.5,
          discount: 0,
          discountType: 'amount',
          stock: 12,
          status: 1,
          availableTimeStarts: '00:00:00',
          availableTimeEnds: '23:59:59',
          choiceOptions: const [],
          variations: const [],
          foodVariations: const [],
        ),
      ];

      for (final locale in [const Locale('en', 'US'), const Locale('ar', 'JO')]) {
        Get.reset();
        await _initCardDependencies();

        final bool isAr = locale.languageCode == 'ar';
        final catService = _FakeCategoryService(
          categories: [
            CategoryModel(
              id: 144,
              name: isAr
                  ? 'مستوردة فاخرة أوروبية وأمريكية مختارة'
                  : 'Supercalifragilistic Gourmet Chocolate Selection',
              slug: 'imported-luxury',
            ),
            CategoryModel(
              id: 56,
              name: isAr
                  ? 'شوكولاتة وسناكات مستوردة عالمية'
                  : 'International Confectionery Snacks Deluxe',
              slug: 'snacks-chocolate',
            ),
          ],
          itemResolver: (_) => ItemModel(totalSize: sampleItems.length, items: sampleItems),
        );
        Get.put<CategoryServiceInterface>(catService);
        final catController = Get.put<CategoryController>(CategoryController(categoryServiceInterface: catService));
        await catController.getCategoryList(true);
        Get.put<FlashSaleController>(FlashSaleController(flashSaleServiceInterface: _FakeFlashSaleService()));

        await tester.pumpWidget(_wrapTestApp(const BellaCategorySection(), locale: locale));
        Get.updateLocale(locale);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(BellaProductCard), findsWidgets);
        expect(find.text(isAr ? 'عرض الكل' : 'View All'), findsNWidgets(2));
      }
    });

    testWidgets('handles empty categoryList safely without hardcoded fallbacks or exceptions', (tester) async {
      Get.reset();
      final catService = _FakeCategoryService(categories: const []);
      Get.put<CategoryServiceInterface>(catService);
      final catController = Get.put<CategoryController>(CategoryController(categoryServiceInterface: catService));
      await catController.getCategoryList(true);
      Get.put<FlashSaleController>(FlashSaleController(flashSaleServiceInterface: _FakeFlashSaleService()));

      await tester.pumpWidget(_wrapTestApp(const BellaCategorySection()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('All Items'), findsOneWidget);
      expect(find.text('Brands'), findsOneWidget);
      expect(find.text('Imported Luxury'), findsNothing);
    });

    testWidgets('renders retry card when section loading fails and retries on tap', (tester) async {
      Get.reset();
      bool shouldFail = true;
      final catService = _FakeCategoryService(
        categories: [
          CategoryModel(id: 144, name: 'Imported Luxury', slug: 'imported-luxury'),
          CategoryModel(id: 56, name: 'Snacks & Chocolate', slug: 'snacks-chocolate'),
        ],
        itemResolver: (_) => shouldFail ? null : ItemModel(totalSize: 0, items: const []),
      );
      Get.put<CategoryServiceInterface>(catService);
      final catController = Get.put<CategoryController>(CategoryController(categoryServiceInterface: catService));
      await catController.getCategoryList(true);
      Get.put<FlashSaleController>(FlashSaleController(flashSaleServiceInterface: _FakeFlashSaleService()));

      await tester.pumpWidget(_wrapTestApp(const BellaCategorySection()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Retry'), findsNWidgets(2));
      final int fetchesBeforeTap = catService.itemFetchCount;

      shouldFail = false;
      await tester.tap(find.text('Retry').first);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(catService.itemFetchCount, greaterThan(fetchesBeforeTap));
    });

    testWidgets('renders discounted 2-line items at 1.5x and 2.0x TextScaler in EN and AR without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final List<Item> discountedTwoLineItems = [
        Item(
          id: 601,
          name: 'Lindt Lindor Assorted Swiss Chocolate Truffles Gift Box 200g',
          price: 5.50,
          discount: 20,
          discountType: 'percent',
          stock: 8,
          status: 1,
          availableTimeStarts: '00:00:00',
          availableTimeEnds: '23:59:59',
          choiceOptions: const [],
          variations: const [],
          foodVariations: const [],
        ),
        Item(
          id: 602,
          name: 'Ferrero Rocher Fine Hazelnut Chocolates Collection Unavailable Item',
          price: 7.25,
          discount: 1.25,
          discountType: 'amount',
          stock: 0,
          status: 1,
          scheduleOrder: false,
          availableTimeStarts: '00:00:00',
          availableTimeEnds: '23:59:59',
          choiceOptions: const [],
          variations: const [],
          foodVariations: const [],
        ),
      ];

      for (final scale in [1.5, 2.0]) {
        for (final locale in [const Locale('en', 'US'), const Locale('ar', 'JO')]) {
          Get.reset();
          await _initCardDependencies();

          final bool isAr = locale.languageCode == 'ar';
          final catService = _FakeCategoryService(
            categories: [
              CategoryModel(
                id: 144,
                name: isAr ? 'منتجات مستوردة فاخرة' : 'Imported Luxury',
                slug: 'imported-luxury',
              ),
              CategoryModel(
                id: 56,
                name: isAr ? 'سناكات وشوكولاتة' : 'Snacks & Chocolate',
                slug: 'snacks-chocolate',
              ),
            ],
            itemResolver: (_) => ItemModel(
              totalSize: discountedTwoLineItems.length,
              items: discountedTwoLineItems,
            ),
          );
          Get.put<CategoryServiceInterface>(catService);
          final catController = Get.put<CategoryController>(
            CategoryController(categoryServiceInterface: catService),
          );
          await catController.getCategoryList(true);
          Get.put<FlashSaleController>(
            FlashSaleController(flashSaleServiceInterface: _FakeFlashSaleService()),
          );

          await tester.pumpWidget(
            _wrapTestApp(
              const BellaCategorySection(),
              locale: locale,
              textScaler: TextScaler.linear(scale),
            ),
          );
          Get.updateLocale(locale);
          await tester.pumpAndSettle();

          expect(
            tester.takeException(),
            isNull,
            reason: 'Expected zero overflow/exceptions at textScale=$scale locale=$locale',
          );
          expect(find.byType(BellaProductCard), findsWidgets);
        }
      }
    });

    testWidgets('reloads imported and exclusive items when LocalizationController switches EN to AR', (tester) async {
      Get.reset();
      await _initCardDependencies();

      String activeLang = 'en';
      final catService = _FakeCategoryService(
        categories: [
          CategoryModel(id: 144, name: 'Imported Luxury', slug: 'imported-luxury'),
          CategoryModel(id: 56, name: 'Snacks & Chocolate', slug: 'snacks-chocolate'),
        ],
        itemResolver: (categoryId) {
          final bool isImported = categoryId == '144';
          if (activeLang == 'ar') {
            return ItemModel(
              totalSize: 1,
              items: [
                Item(
                  id: isImported ? 701 : 702,
                  name: isImported ? 'شوكولاتة ليندت السويسرية' : 'سناك مستورد فاخر',
                  price: 4.5,
                  discount: 0,
                  discountType: 'amount',
                  stock: 10,
                  status: 1,
                  availableTimeStarts: '00:00:00',
                  availableTimeEnds: '23:59:59',
                  choiceOptions: const [],
                  variations: const [],
                  foodVariations: const [],
                ),
              ],
            );
          }
          return ItemModel(
            totalSize: 1,
            items: [
              Item(
                id: isImported ? 701 : 702,
                name: isImported ? 'Lindt Swiss Gold' : 'Gourmet Pretzel Pack',
                price: 4.5,
                discount: 0,
                discountType: 'amount',
                stock: 10,
                status: 1,
                availableTimeStarts: '00:00:00',
                availableTimeEnds: '23:59:59',
                choiceOptions: const [],
                variations: const [],
                foodVariations: const [],
              ),
            ],
          );
        },
      );
      Get.put<CategoryServiceInterface>(catService);
      final catController = Get.put<CategoryController>(
        CategoryController(categoryServiceInterface: catService),
      );
      await catController.getCategoryList(true);
      Get.put<FlashSaleController>(
        FlashSaleController(flashSaleServiceInterface: _FakeFlashSaleService()),
      );

      await tester.pumpWidget(_wrapTestApp(const BellaCategorySection()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Lindt Swiss Gold'), findsOneWidget);
      expect(find.text('Gourmet Pretzel Pack'), findsOneWidget);
      expect(find.text('شوكولاتة ليندت السويسرية'), findsNothing);
      final int fetchesBeforeSwitch = catService.itemFetchCount;

      activeLang = 'ar';
      catService.categories = [
        CategoryModel(id: 144, name: 'منتجات مستوردة فاخرة', slug: 'imported-luxury'),
        CategoryModel(id: 56, name: 'سناكات وشوكولاتة', slug: 'snacks-chocolate'),
      ];
      await catController.getCategoryList(true);
      Get.find<LocalizationController>().setLanguage(const Locale('ar', 'JO'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(catService.itemFetchCount, greaterThanOrEqualTo(fetchesBeforeSwitch + 2));
      expect(find.text('شوكولاتة ليندت السويسرية'), findsOneWidget);
      expect(find.text('سناك مستورد فاخر'), findsOneWidget);
      expect(find.text('Lindt Swiss Gold'), findsNothing);
      expect(find.text('Gourmet Pretzel Pack'), findsNothing);
    });
  });
}
