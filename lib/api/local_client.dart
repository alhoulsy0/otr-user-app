import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/api/cache_envelope_helper.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/helper/db_helper.dart';
import 'package:sixam_mart/local/cache_response.dart';
import 'package:sixam_mart/util/app_constants.dart';

class LocalClient {
  static Map<String, String> _resolveContextHeader(Map<String, String>? header) {
    if (header != null) return header;
    if (Get.isRegistered<ApiClient>()) {
      try {
        return Get.find<ApiClient>().getHeader();
      } catch (_) {}
    }
    return const <String, String>{};
  }

  static Future<String?> organize(
    DataSourceEnum source,
    String cacheId,
    String? responseBody,
    Map<String, String>? header, {
    bool validateModule = true,
    bool validateZone = true,
    Duration ttl = defaultCacheTtl,
  }) async {
    final SharedPreferences sharedPreferences = Get.find();
    final Map<String, String> contextHeader = _resolveContextHeader(header);
    final String zoneId = contextHeader[AppConstants.zoneId] ?? '';
    final String languageCode = contextHeader[AppConstants.localizationKey] ?? '';
    final String moduleId = contextHeader[AppConstants.moduleId] ?? '';

    switch (source) {
      case DataSourceEnum.client:
        if (responseBody == null || responseBody.isEmpty) {
          return null;
        }
        try {
          final String wrapped = encodeCacheEnvelope(
            responseBody,
            zoneId: zoneId,
            languageCode: languageCode,
            moduleId: moduleId,
          );
          if (GetPlatform.isWeb) {
            await sharedPreferences.setString(cacheId, wrapped);
          } else {
            await DbHelper.insertOrUpdate(
              id: cacheId,
              data: CacheResponseCompanion(
                endPoint: drift.Value(cacheId),
                header: drift.Value(jsonEncode(contextHeader)),
                response: drift.Value(wrapped),
              ),
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('=====error occur in repo api cache write: $e');
          }
        }
        return null;

      case DataSourceEnum.local:
        try {
          if (GetPlatform.isWeb) {
            final String? raw = sharedPreferences.getString(cacheId);
            final String? decoded = decodeCacheEnvelope(
              raw,
              expectedZoneId: zoneId,
              expectedLanguageCode: languageCode,
              expectedModuleId: moduleId,
              validateModule: validateModule,
              validateZone: validateZone,
              ttl: ttl,
            );
            if (decoded == null && raw != null) {
              await sharedPreferences.remove(cacheId);
            }
            return decoded;
          } else {
            final CacheResponseData? cacheResponseData = await database.getCacheResponseById(cacheId);
            if (cacheResponseData == null) return null;
            final String? decoded = decodeCacheEnvelope(
              cacheResponseData.response,
              expectedZoneId: zoneId,
              expectedLanguageCode: languageCode,
              expectedModuleId: moduleId,
              validateModule: validateModule,
              validateZone: validateZone,
              ttl: ttl,
            );
            if (decoded == null) {
              await database.deleteCacheResponse(cacheResponseData.id);
            }
            return decoded;
          }
        } catch (e) {
          if (kDebugMode) {
            print('=====error occur in repo local cache read: $e');
          }
        }
        return null;
    }
  }
}
