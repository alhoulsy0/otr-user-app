import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/helper/date_converter.dart';

void main() {
  group('DateConverter.isAvailable', () {
    test('treats start == end as 24/7 available', () {
      expect(
        DateConverter.isAvailable('00:00:00', '00:00:00', time: DateTime(2026, 11, 26, 14, 30, 0)),
        isTrue,
      );
      expect(
        DateConverter.isAvailable('09:00:00', '09:00:00', time: DateTime(2026, 11, 26, 3, 15, 0)),
        isTrue,
      );
      expect(
        DateConverter.isAvailable('09:00:00', '09:00:00', time: DateTime(2026, 11, 26, 9, 0, 0)),
        isTrue,
      );
    });

    test('handles 00:00 to 23:59 including final minute seconds', () {
      expect(
        DateConverter.isAvailable('00:00', '23:59', time: DateTime(2026, 11, 26, 0, 0, 0)),
        isTrue,
      );
      expect(
        DateConverter.isAvailable('00:00', '23:59', time: DateTime(2026, 11, 26, 23, 59, 30)),
        isTrue,
      );
      expect(
        DateConverter.isAvailable('00:00', '23:59', time: DateTime(2026, 11, 26, 23, 59, 59)),
        isTrue,
      );
      expect(
        DateConverter.isAvailable('00:00:00', '23:59:59', time: DateTime(2026, 11, 26, 23, 59, 30)),
        isTrue,
      );
    });

    test('enforces inclusive daytime boundaries', () {
      expect(
        DateConverter.isAvailable('09:00:00', '17:00:00', time: DateTime(2026, 11, 26, 8, 59, 59)),
        isFalse,
      );
      expect(
        DateConverter.isAvailable('09:00:00', '17:00:00', time: DateTime(2026, 11, 26, 9, 0, 0)),
        isTrue,
      );
      expect(
        DateConverter.isAvailable('09:00:00', '17:00:00', time: DateTime(2026, 11, 26, 17, 0, 0)),
        isTrue,
      );
      expect(
        DateConverter.isAvailable('09:00:00', '17:00:00', time: DateTime(2026, 11, 26, 17, 0, 1)),
        isFalse,
      );
    });

    test('handles overnight spans across midnight inclusively', () {
      expect(
        DateConverter.isAvailable('22:00:00', '02:00:00', time: DateTime(2026, 11, 26, 21, 59, 59)),
        isFalse,
      );
      expect(
        DateConverter.isAvailable('22:00:00', '02:00:00', time: DateTime(2026, 11, 26, 22, 0, 0)),
        isTrue,
      );
      expect(
        DateConverter.isAvailable('22:00:00', '02:00:00', time: DateTime(2026, 11, 26, 0, 0, 0)),
        isTrue,
      );
      expect(
        DateConverter.isAvailable('22:00:00', '02:00:00', time: DateTime(2026, 11, 26, 2, 0, 0)),
        isTrue,
      );
      expect(
        DateConverter.isAvailable('22:00:00', '02:00:00', time: DateTime(2026, 11, 26, 2, 0, 1)),
        isFalse,
      );
    });

    test('handles null and empty start/end safely', () {
      expect(
        DateConverter.isAvailable(null, null, time: DateTime(2026, 11, 26, 12, 0, 0)),
        isTrue,
      );
      expect(
        DateConverter.isAvailable('', '', time: DateTime(2026, 11, 26, 12, 0, 0)),
        isTrue,
      );
      expect(
        DateConverter.isAvailable(null, '17:00:00', time: DateTime(2026, 11, 26, 18, 0, 0)),
        isFalse,
      );
      expect(
        DateConverter.isAvailable('09:00:00', '', time: DateTime(2026, 11, 26, 8, 0, 0)),
        isFalse,
      );
    });

    test('jordanNow uses UTC+3 offset without GetX DI', () {
      final DateTime utcBefore = DateTime.now().toUtc();
      final DateTime jordan = DateConverter.jordanNow();
      final DateTime expectedApprox = utcBefore.add(const Duration(hours: 3));
      expect(jordan.difference(expectedApprox).inSeconds.abs(), lessThanOrEqualTo(2));
      expect(
        DateConverter.isAvailable('00:00:00', '00:00:00'),
        isTrue,
      );
    });
  });
}
