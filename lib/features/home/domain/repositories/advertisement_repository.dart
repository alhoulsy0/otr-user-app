import 'dart:convert';

import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/api/cache_envelope_helper.dart';
import 'package:sixam_mart/api/local_client.dart';
import 'package:sixam_mart/common/enums/data_source_enum.dart';
import 'package:sixam_mart/features/home/domain/models/advertisement_model.dart';
import 'package:sixam_mart/features/home/domain/repositories/advertisement_repository_interface.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';

class AdvertisementRepository implements AdvertisementRepositoryInterface {
  final ApiClient apiClient;
  AdvertisementRepository({required this.apiClient});

  @override
  Future<List<AdvertisementModel>?> getList({int? offset, DataSourceEnum source = DataSourceEnum.client}) async {
    List<AdvertisementModel>? advertisementList;
    final Map<String, String> headers = apiClient.getHeader();
    final String cacheId = buildCacheKey(
      AppConstants.advertisementListUri,
      zoneId: headers[AppConstants.zoneId],
      languageCode: headers[AppConstants.localizationKey],
      moduleId: Get.find<SplashController>().module?.id ?? 0,
    );

    switch(source) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.advertisementListUri);
        if(response.statusCode == 200) {
          advertisementList = [];
          response.body.forEach((data) {
            advertisementList?.add(AdvertisementModel.fromJson(data));
          });
          await LocalClient.organize(source, cacheId, jsonEncode(response.body), headers);
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(source, cacheId, null, null);
        if(cacheResponseData != null) {
          advertisementList = [];
          jsonDecode(cacheResponseData).forEach((data) {
            advertisementList?.add(AdvertisementModel.fromJson(data));
          });
        }
    }
    return advertisementList;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}