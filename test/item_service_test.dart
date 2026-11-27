import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/item/domain/models/basic_medicine_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_review_model.dart';
import 'package:sixam_mart/features/item/domain/repositories/item_repository_interface.dart';
import 'package:sixam_mart/features/item/domain/services/item_service.dart';

class _FakeItemRepository implements ItemRepositoryInterface {
  @override
  Future add(value) => throw UnimplementedError();

  @override
  Future delete(int? id) => throw UnimplementedError();

  @override
  Future get(String? id, {bool isConditionWiseItem = false, bool isCampaign = false, DataSourceEnum? source}) =>
      throw UnimplementedError();

  @override
  Future<BasicMedicineModel?> getBasicMedicine(DataSourceEnum source) => throw UnimplementedError();

  @override
  Future<ItemReviewModel?> getItemReviews({required int itemId, required int limit, required int offset}) =>
      throw UnimplementedError();

  @override
  Future getList({
    int? offset,
    String? type,
    bool isPopularItem = false,
    bool isReviewedItem = false,
    bool isFeaturedCategoryItems = false,
    bool isRecommendedItems = false,
    bool isCommonConditions = false,
    bool isDiscountedItems = false,
    DataSourceEnum? source,
    String? search,
    List<int>? categoryIds,
    List<String>? filter,
    int? rating,
    double? minPrice,
    double? maxPrice,
  }) =>
      throw UnimplementedError();

  @override
  Future update(Map<String, dynamic> body, int? id) => throw UnimplementedError();
}

void main() {
  late ItemService itemService;

  setUp(() {
    itemService = ItemService(itemRepositoryInterface: _FakeItemRepository());
  });

  group('ItemService.getStartingPrice', () {
    test('returns item.price for simple item without choiceOptions', () {
      final Item item = Item(id: 1, name: 'Lindt', price: 4.5, choiceOptions: const [], variations: const []);
      expect(itemService.getStartingPrice(item), 4.5);
    });

    test('returns minimum variation price for multi-variation item', () {
      final Item item = Item(
        id: 2,
        name: 'Coffee Pack',
        price: 10.0,
        choiceOptions: [ChoiceOptions(name: 'size', title: 'Size', options: const ['Small', 'Large'])],
        variations: [
          Variation(type: 'Small', price: 3.25, stock: 5),
          Variation(type: 'Large', price: 6.75, stock: 5),
        ],
      );
      expect(itemService.getStartingPrice(item), 3.25);
    });

    test('returns minimum price when variations are unsorted', () {
      final Item item = Item(
        id: 3,
        name: 'Unsorted Pack',
        price: 12.0,
        choiceOptions: [ChoiceOptions(name: 'size', title: 'Size', options: const ['L', 'S', 'M'])],
        variations: [
          Variation(type: 'L', price: 9.0, stock: 2),
          Variation(type: 'S', price: 2.5, stock: 4),
          Variation(type: 'M', price: 5.0, stock: 3),
        ],
      );
      expect(itemService.getStartingPrice(item), 2.5);
    });

    test('does not throw RangeError when choiceOptions is non-empty and variations is null or empty', () {
      final Item itemWithNullVars = Item(
        id: 4,
        name: 'Null Vars',
        price: 7.0,
        choiceOptions: [ChoiceOptions(name: 'size', title: 'Size', options: const ['S'])],
        variations: null,
      );
      expect(itemService.getStartingPrice(itemWithNullVars), 7.0);

      final Item itemWithEmptyVars = Item(
        id: 5,
        name: 'Empty Vars',
        price: 8.25,
        choiceOptions: [ChoiceOptions(name: 'size', title: 'Size', options: const ['S'])],
        variations: const [],
      );
      expect(itemService.getStartingPrice(itemWithEmptyVars), 8.25);
    });

    test('skips null variation prices and falls back to item.price if all are null', () {
      final Item mixedPrices = Item(
        id: 6,
        name: 'Mixed',
        price: 15.0,
        choiceOptions: [ChoiceOptions(name: 'size', title: 'Size', options: const ['A', 'B'])],
        variations: [
          Variation(type: 'A', price: null, stock: 1),
          Variation(type: 'B', price: 4.0, stock: 1),
        ],
      );
      expect(itemService.getStartingPrice(mixedPrices), 4.0);

      final Item allNullPrices = Item(
        id: 7,
        name: 'All Null',
        price: 15.0,
        choiceOptions: [ChoiceOptions(name: 'size', title: 'Size', options: const ['A'])],
        variations: [Variation(type: 'A', price: null, stock: 1)],
      );
      expect(itemService.getStartingPrice(allNullPrices), 15.0);
    });

    test('falls back to item.price when foodVariations is non-empty', () {
      final Item foodItem = Item(
        id: 8,
        name: 'Food Item',
        price: 5.5,
        choiceOptions: [ChoiceOptions(name: 'size', title: 'Size', options: const ['S'])],
        variations: [Variation(type: 'S', price: 2.0, stock: 5)],
        foodVariations: [
          FoodVariation(
            name: 'Extras',
            multiSelect: false,
            min: 0,
            max: 1,
            required: false,
            variationValues: [VariationValue(level: 'Cheese', optionPrice: 1.0)],
          ),
        ],
      );
      expect(itemService.getStartingPrice(foodItem), 5.5);
    });
  });
}
