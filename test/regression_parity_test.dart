import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/common/widgets/food_item_card.dart';
import 'package:sixam_mart/common/widgets/item_new_bottom_sheet.dart';
import 'package:sixam_mart/common/widgets/item_widget.dart';
import 'package:sixam_mart/common/widgets/not_available_widget.dart';
import 'package:sixam_mart/common/widgets/web_item_widget.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/domain/models/signup_body_model.dart';
import 'package:sixam_mart/features/auth/domain/models/social_log_in_body.dart';
import 'package:sixam_mart/features/auth/domain/services/auth_service_interface.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/domain/models/all_carts_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/cart/domain/models/online_cart_model.dart' hide Variation;
import 'package:sixam_mart/features/cart/domain/services/cart_service.dart';
import 'package:sixam_mart/features/cart/domain/repositories/cart_repository_interface.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/category/domain/services/category_service_interface.dart';
import 'package:sixam_mart/features/category/screens/bella_view_all_screen.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/favourite/domain/services/favourite_service_interface.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/basic_medicine_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_review_model.dart';
import 'package:sixam_mart/features/item/domain/repositories/item_repository_interface.dart';
import 'package:sixam_mart/features/item/domain/services/item_service.dart';
import 'package:sixam_mart/features/item/domain/services/item_service_interface.dart';
import 'package:sixam_mart/features/item/screens/item_details_new_screen.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/language/domain/models/language_model.dart';
import 'package:sixam_mart/features/language/domain/service/language_service_interface.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/service_module/service_home/domain/models/service_category_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/splash/domain/models/app_download_section_model.dart';
import 'package:sixam_mart/features/splash/domain/services/splash_service_interface.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/cart_suggested_item_model.dart';
import 'package:sixam_mart/features/store/domain/models/recommended_product_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_banner_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_category_item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/store/domain/services/store_service_interface.dart';

class _FakeSplashService implements SplashServiceInterface {
  bool stockEnabled;
  _FakeSplashService({this.stockEnabled = true});

  @override
  Future<Response> getConfigData({required DataSourceEnum source}) async {
    return Response(
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
            'stock': stockEnabled,
            'veg_non_veg': false,
            'unit': false,
            'order_attachment': false,
            'show_restaurant_text': false,
            'is_parcel': false,
            'is_taxi': false,
            'is_ride': false,
            'new_variation': false,
          },
          'food': <String, dynamic>{
            'order_place_to_schedule_interval': false,
            'add_on': true,
            'stock': false,
            'veg_non_veg': false,
            'unit': false,
            'order_attachment': false,
            'show_restaurant_text': true,
            'is_parcel': false,
            'is_taxi': false,
            'is_ride': false,
            'new_variation': true,
          },
        },
      },
    );
  }

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
  Item? detailItem;
  _FakeItemRepository({this.detailItem});

  @override
  Future get(String? id, {bool isConditionWiseItem = false, bool isCampaign = false, DataSourceEnum? source}) async => detailItem;

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
  final List<OnlineCart> capturedAdds = [];
  @override
  Future<void> addSharedPrefCartList(List<CartModel> cartProductList) async {}
  @override
  Future<List<OnlineCartModel>?> getCartDataOnline({int? storeId}) async => const [];
  @override
  Future<List<AllCartsModel>?> getAllCarts() async => const [];
  @override
  Future<bool> removeStoreCart(int storeId) async => true;
  @override
  Future<dynamic> add(OnlineCart value, {int? storeId}) async {
    capturedAdds.add(value);
    return null;
  }
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
  bool setLTR(Locale locale) => true;
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

class _FakeCategoryService implements CategoryServiceInterface {
  List<CategoryModel> categories;
  List<Item> categoryItems;
  _FakeCategoryService({this.categories = const [], this.categoryItems = const []});

  @override
  Future<List<CategoryModel>?> getCategoryList(bool allCategory, {DataSourceEnum? source}) async => categories;
  @override
  Future<ItemModel?> getCategoryItemList(String? categoryID, int offset, String type, {int limit = 10}) async =>
      ItemModel(totalSize: categoryItems.length, items: categoryItems);
  @override
  Future<List<CategoryModel>?> getSubCategoryList(String? parentID) async => const [];
  @override
  Future<StoreModel?> getCategoryStoreList(String? categoryID, int offset, String type) async => null;
  @override
  Future<Response> getSearchData(String? query, String? categoryID, bool isStore, String type) async => const Response(statusCode: 200);
  @override
  Future<bool> saveUserInterests(List<int?> interests) async => true;
  @override
  Future<List<ServiceCategoryModel>?> getCategoriesWithChildes() async => const [];
}

class _FakeStoreService implements StoreServiceInterface {
  @override
  Future<Store?> getStoreDetails(String storeID, bool fromCart, String slug, String languageCode, ModuleModel? module, int? cacheModuleId, int? moduleId) async => null;
  @override
  Future<ItemModel?> getStoreItemList({int? storeID, required int offset, int? categoryID, String? type, List<String>? filter, int? rating, double? lowerValue, double? upperValue}) async =>
      ItemModel(totalSize: 0, items: const []);
  @override
  Future<StoreModel?> getStoreList(int offset, String filterBy, String storeType, {required DataSourceEnum source, String name = ''}) async => null;
  @override
  Future<List<Store>?> getPopularStoreList(String type, {required DataSourceEnum source}) async => const [];
  @override
  Future<List<Store>?> getLatestStoreList(String type, {required DataSourceEnum source}) async => const [];
  @override
  Future<List<Store>?> getTopOfferStoreList({required DataSourceEnum source, String? filterBy, String? sortBy}) async => const [];
  @override
  Future<List<Store>?> getFeaturedStoreList({required DataSourceEnum source, bool fromHome = false}) async => const [];
  @override
  Future<List<Store>?> getVisitAgainStoreList({required DataSourceEnum source}) async => const [];
  @override
  Future<ItemModel?> getStoreSearchItemList(String searchText, String? storeID, int offset, String type, int? categoryID) async => null;
  @override
  Future<RecommendedItemModel?> getStoreRecommendedItemList(int? storeId) async => null;
  @override
  Future<CartSuggestItemModel?> getCartStoreSuggestedItemList(int? storeId, String languageCode, ModuleModel? module, int? cacheModuleId, int? moduleId) async => null;
  @override
  Future<List<StoreBannerModel>?> getStoreBannerList(int? storeId) async => const [];
  @override
  Future<List<Store>?> getRecommendedStoreList({required DataSourceEnum source}) async => const [];
  @override
  Future<StoreModel?> getQuickDeliveryStores({int offset = 1, int limit = 10, int? moduleId, String name = ''}) async => null;
  @override
  Future<StoreModel?> getNearbyStores({int offset = 1, int limit = 10, int? moduleId, String name = ''}) async => null;
  @override
  Future<StoreModel?> getVerifiedStores({int offset = 1, int limit = 10, String? type}) async => null;
  @override
  Future<StoreCategoryItemModel?> getStoreCategoryItems(int storeId) async => null;
  @override
  List<Modules> moduleList() => const [];
  @override
  String filterRestaurantLinkUrl(String slug, Store store) => slug;
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

Future<_FakeCartRepository> _initTestGetX({
  bool stockEnabled = true,
  Item? detailItem,
  List<Item> categoryItems = const [],
  String? userAddressJson,
}) async {
  Get.reset();
  final Map<String, Object> prefs = <String, Object>{};
  if (userAddressJson != null) {
    prefs[AppConstants.userAddress] = userAddressJson;
  }
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(sharedPreferences);
  Get.put<ThemeController>(ThemeController(sharedPreferences: sharedPreferences));
  Get.put<AuthController>(AuthController(authServiceInterface: _FakeAuthService()));

  final splashController = SplashController(
    splashServiceInterface: _FakeSplashService(stockEnabled: stockEnabled),
  );
  await splashController.getConfigData(source: DataSourceEnum.client, canRoute: false);
  await splashController.setModule(ModuleModel(id: 1, moduleName: 'Grocery', moduleType: 'grocery'), notify: false);
  Get.put<SplashController>(splashController);

  final itemRepo = _FakeItemRepository(detailItem: detailItem);
  final ItemServiceInterface itemService = ItemService(itemRepositoryInterface: itemRepo);
  Get.put<ItemServiceInterface>(itemService);
  Get.put<ItemController>(ItemController(itemServiceInterface: itemService));

  final cartRepo = _FakeCartRepository();
  final cartService = CartService(cartRepositoryInterface: cartRepo);
  Get.put<CartController>(CartController(cartServiceInterface: cartService));

  Get.put<FavouriteController>(FavouriteController(favouriteServiceInterface: _FakeFavouriteService()));
  Get.put<LocalizationController>(LocalizationController(languageServiceInterface: _FakeLanguageService()));
  final CategoryServiceInterface catService = _FakeCategoryService(
    categories: [CategoryModel(id: 144, name: 'Imported Luxury')],
    categoryItems: categoryItems,
  );
  Get.put<CategoryServiceInterface>(catService);
  Get.put<CategoryController>(CategoryController(categoryServiceInterface: catService));
  Get.put<StoreController>(StoreController(storeServiceInterface: _FakeStoreService()));
  return cartRepo;
}

Widget _wrapTestApp(Widget child) {
  return GetMaterialApp(
    translations: _TestTranslations(),
    locale: const Locale('en', 'US'),
    home: Scaffold(body: child),
  );
}

class _TestTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'add_to_cart': 'Add to Cart',
          'out_of_stock': 'Out of Stock',
          'not_available_now': 'Not Available Now',
          'not_available_now_break': 'Not Available\nNow',
          'unavailable': 'Unavailable',
          'available_will_be': 'Available will be',
          'total': 'Total',
          'total_amount': 'Total Amount',
          'in_stock': 'In Stock',
          'add': 'Add',
        },
      };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    Get.reset();
  });

  group('ItemNewBottomSheet regressions', () {
    testWidgets('handles null variation.stock without crashing and preserves item.stock', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final Item item = Item(
        id: 101,
        name: 'Swiss Truffles',
        price: 5.0,
        discount: 0,
        discountType: 'amount',
        stock: 5,
        status: 1,
        moduleType: 'grocery',
        availableTimeStarts: '00:00:00',
        availableTimeEnds: '23:59:59',
        choiceOptions: [ChoiceOptions(name: 'size', title: 'Size', options: const ['500g'])],
        variations: [Variation(type: '500g', price: 4.5, stock: null)],
        foodVariations: const [],
        addOns: const [],
      );
      await _initTestGetX(stockEnabled: true, detailItem: item);

      await tester.pumpWidget(_wrapTestApp(ItemNewBottomSheet(itemId: item.id!, item: item)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.text('Out of Stock'), findsNothing);
    });

    testWidgets('handles null discount on amount discountType without crashing', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final Item item = Item(
        id: 102,
        name: 'Belgian Pralines',
        price: 7.5,
        discount: null,
        discountType: 'amount',
        stock: 10,
        status: 1,
        moduleType: 'grocery',
        availableTimeStarts: '00:00:00',
        availableTimeEnds: '23:59:59',
        choiceOptions: const [],
        variations: const [],
        foodVariations: const [],
        addOns: const [],
      );
      await _initTestGetX(stockEnabled: true, detailItem: item);

      await tester.pumpWidget(_wrapTestApp(ItemNewBottomSheet(itemId: item.id!, item: item)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('JOD 7.50'), findsWidgets);
    });

    testWidgets('renders discounted variation price range on 360px viewport without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final Item item = Item(
        id: 103,
        name: 'Assorted Luxury Pack',
        price: 10.0,
        discount: 20.0,
        discountType: 'percentage',
        stock: 5,
        status: 1,
        moduleType: 'grocery',
        availableTimeStarts: '00:00:00',
        availableTimeEnds: '23:59:59',
        choiceOptions: [ChoiceOptions(name: 'size', title: 'Size', options: const ['Small', 'Large'])],
        variations: [
          Variation(type: 'Small', price: 3.0, stock: 5),
          Variation(type: 'Large', price: 8.0, stock: 5),
        ],
        foodVariations: const [],
        addOns: const [],
      );
      await _initTestGetX(stockEnabled: true, detailItem: item);

      await tester.pumpWidget(_wrapTestApp(ItemNewBottomSheet(itemId: item.id!, item: item)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('-20%'), findsOneWidget);
    });

    testWidgets('keeps unit OnlineCart.price consistent with line total for amount discount at quantity > 1', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final Item item = Item(
        id: 104,
        name: 'Luxury Assorted Chocolates',
        price: 10.0,
        discount: 2.0,
        discountType: 'amount',
        stock: 20,
        status: 1,
        moduleId: 1,
        storeId: 1,
        moduleType: 'grocery',
        availableTimeStarts: '00:00:00',
        availableTimeEnds: '23:59:59',
        choiceOptions: const [],
        variations: const [],
        foodVariations: const [],
        addOns: const [],
      );
      final cartRepo = await _initTestGetX(
        stockEnabled: true,
        detailItem: item,
        userAddressJson: '{"id":1,"address":"Amman","latitude":"31.95","longitude":"35.91","zone_id":1,"zone_ids":[1]}',
      );

      await tester.pumpWidget(_wrapTestApp(ItemNewBottomSheet(itemId: item.id!, item: item)));
      await tester.pumpAndSettle();

      // Increase quantity to 3: line price = 30.00, discounted line total = 24.00, unit price = 8.00
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(Get.find<ItemController>().quantity, 3);
      expect(
        find.byWidgetPredicate((w) => w is AnimatedFlipCounter && (w.value - 24.0).abs() < 0.01),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((w) => w is AnimatedFlipCounter && (w.value - 30.0).abs() < 0.01),
        findsOneWidget,
      );

      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      expect(cartRepo.capturedAdds.length, 1);
      expect(cartRepo.capturedAdds.last.quantity, 3);
      expect(double.parse(cartRepo.capturedAdds.last.price!), closeTo(8.0, 0.001));

      // Increase quantity to 6 (qty * unitDiscount = 12.0 > unit price 10.0): unit price must still be 8.0 (never -2.0)
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
      }
      expect(Get.find<ItemController>().quantity, 6);
      expect(
        find.byWidgetPredicate((w) => w is AnimatedFlipCounter && (w.value - 48.0).abs() < 0.01),
        findsOneWidget,
      );

      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      expect(cartRepo.capturedAdds.length, 2);
      expect(cartRepo.capturedAdds.last.quantity, 6);
      expect(double.parse(cartRepo.capturedAdds.last.price!), closeTo(8.0, 0.001));
    });

    testWidgets('clamps discounted price and cart cost to >= 0.0 when unitDiscount exceeds price', (tester) async {
      expect(PriceConverter.convertWithDiscount(5.0, 8.0, 'amount'), 0.0);
      expect(PriceConverter.convertWithDiscount(5.0, 150.0, 'percent'), 0.0);
      expect(PriceConverter.convertWithDiscount(null, 2.0, 'amount'), isNull);

      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final Item item = Item(
        id: 105,
        name: 'Over-discounted Chocolate',
        price: 5.0,
        discount: 8.0,
        discountType: 'amount',
        stock: 10,
        status: 1,
        moduleId: 1,
        storeId: 1,
        moduleType: 'grocery',
        availableTimeStarts: '00:00:00',
        availableTimeEnds: '23:59:59',
        choiceOptions: const [],
        variations: const [],
        foodVariations: const [],
        addOns: const [],
      );
      final cartRepo = await _initTestGetX(
        stockEnabled: true,
        detailItem: item,
        userAddressJson: '{"id":1,"address":"Amman","latitude":"31.95","longitude":"35.91","zone_id":1,"zone_ids":[1]}',
      );

      await tester.pumpWidget(_wrapTestApp(ItemNewBottomSheet(itemId: item.id!, item: item)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(Get.find<ItemController>().quantity, 2);
      expect(
        find.byWidgetPredicate((w) => w is AnimatedFlipCounter && w.value == 0.0),
        findsOneWidget,
      );

      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      expect(cartRepo.capturedAdds.length, 1);
      expect(cartRepo.capturedAdds.last.quantity, 2);
      expect(double.parse(cartRepo.capturedAdds.last.price!), 0.0);
    });
  });

  group('ItemDetailsNewScreen regressions', () {
    testWidgets('aligns startingPrice with choiceOptions empty check, handles null discount, formats percentage badge, and gates status==0', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final Item item = Item(
        id: 201,
        name: 'Luxury Box',
        price: 10.0,
        discount: 10.0,
        discountType: 'percentage',
        stock: 5,
        status: 0,
        scheduleOrder: true,
        isPrescriptionRequired: false,
        moduleType: 'grocery',
        availableTimeStarts: '00:00:00',
        availableTimeEnds: '23:59:59',
        choiceOptions: const [],
        variations: [Variation(type: 'Default', price: 3.0, stock: null)],
        foodVariations: const [],
        addOns: const [],
      );
      await _initTestGetX(stockEnabled: true, detailItem: item);

      await tester.pumpWidget(_wrapTestApp(ItemDetailsNewScreen(itemId: item.id!, inStorePage: false)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('JOD 9.00'), findsOneWidget);
      expect(find.text('JOD 2.70'), findsNothing);
      expect(find.text('-10%'), findsOneWidget);
      expect(find.text('Not Available Now'), findsOneWidget);
      expect(find.text('Add to Cart'), findsNothing);
    });

    testWidgets('handles null discount and null variation.stock without crashing', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final Item nullDiscountItem = Item(
        id: 202,
        name: 'No Discount Item',
        price: 8.0,
        discount: null,
        discountType: 'amount',
        stock: 5,
        status: 1,
        isPrescriptionRequired: false,
        moduleType: 'grocery',
        availableTimeStarts: '00:00:00',
        availableTimeEnds: '23:59:59',
        choiceOptions: [ChoiceOptions(name: 'size', title: 'Size', options: const ['Standard'])],
        variations: [Variation(type: 'Standard', price: 8.0, stock: null)],
        foodVariations: const [],
        addOns: const [],
      );
      await _initTestGetX(stockEnabled: true, detailItem: nullDiscountItem);

      await tester.pumpWidget(_wrapTestApp(ItemDetailsNewScreen(itemId: nullDiscountItem.id!, inStorePage: false)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Add to Cart'), findsOneWidget);
    });
  });

  group('ItemWidget, WebItemWidget, FoodItemCard availability parity', () {
    testWidgets('marks status==0 and stock<=0 items unavailable and hides CartCountView', (tester) async {
      await _initTestGetX(stockEnabled: true);

      final Item inactiveItem = Item(
        id: 301,
        name: 'Inactive Chocolate',
        price: 4.0,
        discount: null,
        discountType: 'amount',
        stock: 10,
        status: 0,
        scheduleOrder: true,
        availableTimeStarts: '00:00:00',
        availableTimeEnds: '23:59:59',
        choiceOptions: const [],
        variations: const [],
        foodVariations: const [],
      );
      final Item oosItem = Item(
        id: 302,
        name: 'OOS Chocolate',
        price: 4.0,
        discount: 0,
        discountType: 'amount',
        stock: 0,
        status: 1,
        scheduleOrder: true,
        availableTimeStarts: '00:00:00',
        availableTimeEnds: '23:59:59',
        choiceOptions: const [],
        variations: const [],
        foodVariations: const [],
      );

      for (final item in [inactiveItem, oosItem]) {
        await tester.pumpWidget(_wrapTestApp(SizedBox(
          height: 120,
          width: 360,
          child: ItemWidget(item: item, isStore: false, store: null, index: 0, length: 1),
        )));
        await tester.pump();
        expect(find.byType(NotAvailableWidget), findsOneWidget);
        expect(find.byType(CartCountView), findsNothing);

        await tester.pumpWidget(_wrapTestApp(SizedBox(
          height: 260,
          width: 240,
          child: WebItemWidget(item: item, isStore: false, store: null, index: 0, length: 1),
        )));
        await tester.pump();
        expect(find.byType(NotAvailableWidget), findsOneWidget);
        expect(find.byType(CartCountView), findsNothing);

        await tester.pumpWidget(_wrapTestApp(SingleChildScrollView(
          child: FoodItemCard(data: item, width: 160, index: 0),
        )));
        await tester.pump();
        expect(find.byType(NotAvailableWidget), findsOneWidget);
        expect(find.byType(CartCountView), findsNothing);
      }
    });
  });

  group('BellaViewAllScreen & StoreCardItem regressions', () {
    testWidgets('normalizes mixed-case initialSearch in BellaViewAllScreen', (tester) async {
      final List<Item> items = [
        Item(
          id: 401,
          name: 'Lindt Excellence 70%',
          price: 3.5,
          discount: 0,
          status: 1,
          stock: 10,
          availableTimeStarts: '00:00:00',
          availableTimeEnds: '23:59:59',
        ),
        Item(
          id: 402,
          name: 'Milka Alpine Milk',
          price: 2.5,
          discount: 0,
          status: 1,
          stock: 10,
          availableTimeStarts: '00:00:00',
          availableTimeEnds: '23:59:59',
        ),
      ];
      await _initTestGetX(stockEnabled: true, categoryItems: items);

      await tester.pumpWidget(_wrapTestApp(
        const BellaViewAllScreen(
          title: 'Imported Luxury',
          initialSearch: '  LiNdT  ',
          selectedCategoryId: 144,
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Lindt Excellence 70%'), findsOneWidget);
      expect(find.text('Milka Alpine Milk'), findsNothing);
    });

    testWidgets('sorts low_high by effective discounted price', (tester) async {
      final List<Item> items = [
        Item(
          id: 403,
          name: 'Regular Eight',
          price: 8.0,
          discount: 0,
          status: 1,
          stock: 10,
          availableTimeStarts: '00:00:00',
          availableTimeEnds: '23:59:59',
        ),
        Item(
          id: 404,
          name: 'Discounted Five',
          price: 10.0,
          discount: 50.0,
          discountType: 'percentage',
          status: 1,
          stock: 10,
          availableTimeStarts: '00:00:00',
          availableTimeEnds: '23:59:59',
        ),
      ];
      await _initTestGetX(stockEnabled: true, categoryItems: items);

      await tester.pumpWidget(_wrapTestApp(
        const BellaViewAllScreen(
          title: 'Imported Luxury',
          selectedCategoryId: 144,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Price: Low to High'));
      await tester.pumpAndSettle();

      final double regularX = tester.getTopLeft(find.text('Regular Eight')).dx;
      final double discountedX = tester.getTopLeft(find.text('Discounted Five')).dx;
      expect(discountedX, lessThan(regularX));
    });

    test('StoreCardItem.toItem forwards status', () {
      final StoreCardItem cardItem = StoreCardItem.fromJson(<String, dynamic>{
        'id': 501,
        'name': 'Store Card Item',
        'price': 4.5,
        'discount': 0,
        'status': 0,
        'stock': 3,
      });
      final Item mapped = cardItem.toItem();
      expect(mapped.status, 0);
      expect(mapped.stock, 3);
    });
  });
}
