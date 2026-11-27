import 'dart:convert';

const int cacheEnvelopeVersion = 1;
const Duration defaultCacheTtl = Duration(minutes: 5);

/// Builds a deterministic cache key isolated by zone, language, module, and
/// query/filter parameters.
String buildCacheKey(
  String baseUri, {
  String? zoneId,
  String? languageCode,
  dynamic moduleId,
  Map<String, dynamic>? params,
}) {
  final String z = (zoneId ?? '').trim();
  final String l = (languageCode ?? '').trim();
  final String m = moduleId?.toString().trim() ?? '';

  final List<String> segments = <String>[
    baseUri,
    'z=${Uri.encodeComponent(z)}',
    'l=${Uri.encodeComponent(l)}',
    'm=${Uri.encodeComponent(m)}',
  ];

  if (params != null && params.isNotEmpty) {
    final List<String> keys = params.keys.toList()..sort();
    for (final String key in keys) {
      final dynamic value = params[key];
      if (value == null) continue;
      final String encodedVal = Uri.encodeComponent(value.toString());
      segments.add('${Uri.encodeComponent(key)}=$encodedVal');
    }
  }

  return segments.join('|');
}

/// Wraps a raw API JSON response string in a versioned metadata envelope.
String encodeCacheEnvelope(
  String body, {
  String? zoneId,
  String? languageCode,
  String? moduleId,
  DateTime? now,
}) {
  final int ts = (now ?? DateTime.now()).millisecondsSinceEpoch;
  return jsonEncode(<String, dynamic>{
    '__cache_v': cacheEnvelopeVersion,
    'ts': ts,
    'zoneId': zoneId ?? '',
    'lang': languageCode ?? '',
    'moduleId': moduleId ?? '',
    'body': body,
  });
}

/// Validates and unwraps a cached envelope string.
///
/// Returns `null` if [raw] is empty, malformed, a legacy un-enveloped string,
/// expired beyond [ttl], or mismatched on zone/language/module context.
String? decodeCacheEnvelope(
  String? raw, {
  String? expectedZoneId,
  String? expectedLanguageCode,
  String? expectedModuleId,
  bool validateModule = true,
  bool validateZone = true,
  Duration ttl = defaultCacheTtl,
  DateTime? now,
}) {
  if (raw == null || raw.trim().isEmpty) return null;

  dynamic decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (_) {
    return null;
  }

  if (decoded is! Map) return null;
  if (decoded['__cache_v'] != cacheEnvelopeVersion) return null;

  final dynamic ts = decoded['ts'];
  if (ts is! int) return null;

  final int currentMs = (now ?? DateTime.now()).millisecondsSinceEpoch;
  final int ageMs = currentMs - ts;
  if (ageMs < 0 || ageMs > ttl.inMilliseconds) return null;

  if (validateZone) {
    final String cachedZone = decoded['zoneId']?.toString() ?? '';
    final String targetZone = expectedZoneId ?? '';
    if (cachedZone != targetZone) return null;
  }

  final String cachedLang = decoded['lang']?.toString() ?? '';
  final String targetLang = expectedLanguageCode ?? '';
  if (cachedLang != targetLang) return null;

  if (validateModule) {
    final String cachedModule = decoded['moduleId']?.toString() ?? '';
    final String targetModule = expectedModuleId ?? '';
    if (cachedModule != targetModule) return null;
  }

  final dynamic body = decoded['body'];
  if (body is! String || body.isEmpty) return null;

  return body;
}
