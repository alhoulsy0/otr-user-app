import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

void main() {
  group('AppConstants category IDs & Item.status serialization', () {
    test('category constants match backend M1 IDs', () {
      expect(AppConstants.importedLuxuryCategoryId, 144);
      expect(AppConstants.importedLuxuryCategorySlug, 'imported-luxury');
      expect(AppConstants.snacksChocolateCategoryId, 56);
    });

    test('Item.fromJson parses int and string status and serializes it', () {
      final Item activeItem = Item.fromJson(<String, dynamic>{
        'id': 101,
        'name': 'Swiss Chocolate',
        'price': 3.5,
        'discount': 0,
        'status': 1,
      });
      expect(activeItem.status, 1);
      expect(activeItem.toJson()['status'], 1);

      final Item inactiveItem = Item.fromJson(<String, dynamic>{
        'id': 102,
        'name': 'Disabled Item',
        'price': 2.0,
        'discount': 0,
        'status': '0',
      });
      expect(inactiveItem.status, 0);
      expect(inactiveItem.toJson()['status'], 0);
    });
  });
}
