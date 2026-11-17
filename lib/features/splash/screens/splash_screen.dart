import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/no_internet_screen.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/splash_route_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  final String? deeplinkUrl;
  const SplashScreen({super.key, required this.body, required this.deeplinkUrl});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;
  AnimationController? _animController;
  Animation<double>? _scaleAnimation;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(CurvedAnimation(parent: _animController!, curve: Curves.easeInOut));

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);

      if(!firstTime && mounted) {
        try {
          if (ScaffoldMessenger.maybeOf(context) != null) {
            isConnected ? ScaffoldMessenger.of(context).hideCurrentSnackBar() : const SizedBox();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: isConnected ? Colors.green : Colors.red,
              duration: Duration(seconds: isConnected ? 3 : 6000),
              content: Text(isConnected ? 'connected'.tr : 'no_connection'.tr, textAlign: TextAlign.center),
            ));
          }
        } catch (_) {}
        if(isConnected) {
          if(Get.find<SplashController>().deeplinkRoute == null && !Get.find<SplashController>().splashRouted) {
            Get.find<SplashController>().getConfigData(notificationBody: widget.body, fromSplash: true);
          }
        }
      }

      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    if((AuthHelper.getGuestId().isNotEmpty || AuthHelper.isLoggedIn()) && Get.find<SplashController>().cacheModule != null) {
      Get.find<CartController>().getAllCarts();
    }

    _route();

    // Absolute safety timer: guarantees the app navigates out of splash screen under all conditions
    _fallbackTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _forceFallback();
      }
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _animController?.dispose();
    _onConnectivityChanged?.cancel();
    super.dispose();
  }

  void _route() async {
    try {
      await Get.find<SplashController>().getConfigData(handleMaintenanceMode: false, notificationBody: widget.body, fromSplash: true).timeout(const Duration(seconds: 2));
    } catch (_) {}
    Timer(const Duration(milliseconds: 600), () {
      _navigateOut();
    });
  }

  void _navigateOut() {
    if (!mounted) return;
    final splash = Get.find<SplashController>();
    if (splash.splashRouted) return;
    splash.markSplashRouted();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        route(body: widget.body);
      } catch (e) {
        debugPrint('Splash route error: $e');
        _forceFallback();
      }
    });
  }

  void _forceFallback() {
    if (!mounted) return;
    final splash = Get.find<SplashController>();
    splash.markSplashRouted();
    try {
      if (AddressHelper.getUserAddressFromSharedPref() != null) {
        Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: true));
      } else if (splash.showIntro() != false) {
        Get.offAllNamed(RouteHelper.getOnBoardingRoute());
      } else {
        Get.offAllNamed(RouteHelper.getAccessLocationRoute('splash'));
      }
    } catch (e) {
      debugPrint('Splash forceFallback error: $e');
      Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    if(AddressHelper.getUserAddressFromSharedPref() != null && AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
      Get.find<AuthController>().clearSharedAddress();
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final double logoWidth = (screenWidth * 0.72).clamp(280.0, 360.0);

    return Scaffold(
      key: _globalKey,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.95,
            colors: [
              Color(0xFFF22830),
              Color(0xFF9E0B11),
            ],
          ),
        ),
        child: GetBuilder<SplashController>(builder: (splashController) {
          return Center(
            child: splashController.hasConnection ? const Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 36,
                  width: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ) : NoInternetScreen(child: SplashScreen(body: widget.body, deeplinkUrl: widget.deeplinkUrl)),
          );
        }),
      ),
    );
  }
}
