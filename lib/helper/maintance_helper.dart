import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class MaintenanceHelper{
  static bool isMaintenanceEnable() {
    try {
      final config = Get.isRegistered<SplashController>() ? Get.find<SplashController>().configModel : null;
      if (config == null) return false;
      bool isMaintenanceMode = config.maintenanceMode ?? false;
      String platform = GetPlatform.isWeb ? 'user_web_app' : 'user_mobile_app';

      bool isInMaintenance = isMaintenanceMode && config.maintenanceModeData != null
          && (config.maintenanceModeData!.maintenanceSystemSetup?.contains(platform) ?? false);

      return isInMaintenance;
    } catch (_) {
      return false;
    }
  }
}