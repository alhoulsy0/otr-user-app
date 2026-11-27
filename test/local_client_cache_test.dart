import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart/api/cache_envelope_helper.dart';

void main() {
  group('buildCacheKey', () {
    test('isolates keys by zoneId, languageCode, moduleId, and sorted query params', () {
      final String k1 = buildCacheKey(
        '/api/v1/items/popular',
        zoneId: '[1]',
        languageCode: 'en',
        moduleId: 1,
        params: {'offset': 1, 'type': 'all'},
      );
      final String kDiffZone = buildCacheKey(
        '/api/v1/items/popular',
        zoneId: '[2]',
        languageCode: 'en',
        moduleId: 1,
        params: {'offset': 1, 'type': 'all'},
      );
      final String kDiffLang = buildCacheKey(
        '/api/v1/items/popular',
        zoneId: '[1]',
        languageCode: 'ar',
        moduleId: 1,
        params: {'offset': 1, 'type': 'all'},
      );
      final String kDiffModule = buildCacheKey(
        '/api/v1/items/popular',
        zoneId: '[1]',
        languageCode: 'en',
        moduleId: 2,
        params: {'offset': 1, 'type': 'all'},
      );
      final String kDiffQuery = buildCacheKey(
        '/api/v1/items/popular',
        zoneId: '[1]',
        languageCode: 'en',
        moduleId: 1,
        params: {'offset': 2, 'type': 'all'},
      );
      final String kReorderedParams = buildCacheKey(
        '/api/v1/items/popular',
        zoneId: '[1]',
        languageCode: 'en',
        moduleId: 1,
        params: {'type': 'all', 'offset': 1},
      );

      expect(k1, isNot(equals(kDiffZone)));
      expect(k1, isNot(equals(kDiffLang)));
      expect(k1, isNot(equals(kDiffModule)));
      expect(k1, isNot(equals(kDiffQuery)));
      expect(k1, equals(kReorderedParams));
    });
  });

  group('encodeCacheEnvelope & decodeCacheEnvelope', () {
    final DateTime baseTime = DateTime(2026, 11, 26, 12, 0, 0);

    test('decodes valid fresh envelope matching context', () {
      final String raw = encodeCacheEnvelope(
        '{"items":[1,2]}',
        zoneId: '[1]',
        languageCode: 'en',
        moduleId: '1',
        now: baseTime,
      );
      final String? decoded = decodeCacheEnvelope(
        raw,
        expectedZoneId: '[1]',
        expectedLanguageCode: 'en',
        expectedModuleId: '1',
        now: baseTime.add(const Duration(minutes: 4)),
      );
      expect(decoded, '{"items":[1,2]}');
    });

    test('rejects expired TTL envelope', () {
      final String raw = encodeCacheEnvelope(
        '{"items":[1]}',
        zoneId: '[1]',
        languageCode: 'en',
        moduleId: '1',
        now: baseTime,
      );
      final String? decoded = decodeCacheEnvelope(
        raw,
        expectedZoneId: '[1]',
        expectedLanguageCode: 'en',
        expectedModuleId: '1',
        now: baseTime.add(const Duration(minutes: 5, seconds: 1)),
      );
      expect(decoded, isNull);
    });

    test('rejects mismatched zoneId, lang, or moduleId', () {
      final String raw = encodeCacheEnvelope(
        '{"items":[1]}',
        zoneId: '[1]',
        languageCode: 'en',
        moduleId: '1',
        now: baseTime,
      );
      expect(
        decodeCacheEnvelope(
          raw,
          expectedZoneId: '[2]',
          expectedLanguageCode: 'en',
          expectedModuleId: '1',
          now: baseTime,
        ),
        isNull,
      );
      expect(
        decodeCacheEnvelope(
          raw,
          expectedZoneId: '[1]',
          expectedLanguageCode: 'ar',
          expectedModuleId: '1',
          now: baseTime,
        ),
        isNull,
      );
      expect(
        decodeCacheEnvelope(
          raw,
          expectedZoneId: '[1]',
          expectedLanguageCode: 'en',
          expectedModuleId: '2',
          now: baseTime,
        ),
        isNull,
      );
    });

    test('allows module mismatch when validateModule is false', () {
      final String raw = encodeCacheEnvelope(
        '{"config":true}',
        zoneId: '[1]',
        languageCode: 'en',
        moduleId: '',
        now: baseTime,
      );
      final String? decoded = decodeCacheEnvelope(
        raw,
        expectedZoneId: '[1]',
        expectedLanguageCode: 'en',
        expectedModuleId: '1',
        validateModule: false,
        now: baseTime.add(const Duration(minutes: 1)),
      );
      expect(decoded, '{"config":true}');
    });

    test('rejects legacy non-envelope JSON strings', () {
      const String legacyJson = '{"total_size":10,"items":[]}';
      final String? decoded = decodeCacheEnvelope(
        legacyJson,
        expectedZoneId: '[1]',
        expectedLanguageCode: 'en',
        expectedModuleId: '1',
        now: baseTime,
      );
      expect(decoded, isNull);
    });
  });
}
