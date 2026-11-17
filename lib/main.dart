import 'dart:async';
import 'dart:ui';
import 'package:app_links/app_links.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/dashboard/widgets/home_status_bar_tint.dart';
import 'package:sixam_mart/features/pro/controllers/pro_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/link_converter_helper.dart';
import 'package:sixam_mart/helper/notification_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/theme/dark_theme.dart';
import 'package:sixam_mart/theme/light_theme.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/home/widgets/cookies_view.dart';
import 'helper/get_di.dart' as di;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_web_plugins/url_strategy.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER_ERROR: ${details.exceptionAsString()}\n${details.stack}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PLATFORM_ERROR: $error\n$stack');
    return true;
  };
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Text(
              'Startup UI Error:\n${details.exceptionAsString()}\n\n${details.stack}',
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  };

  try {
    if (GetPlatform.isWeb) {
      await Firebase.initializeApp(options: const FirebaseOptions(
          apiKey: "AIzaSyD0Z911mOoWCVkeGdjhIKwWFPRgvd6ZyAw",
          authDomain: "stackmart-500c7.firebaseapp.com",
          projectId: "stackmart-500c7",
          storageBucket: "stackmart-500c7.appspot.com",
          messagingSenderId: "491987943015",
          appId: "1:491987943015:web:d8bc7ab8dbc9991c8f1ec2"
      ));
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase.initializeApp error: $e');
  }

  Map<String, Map<String, String>> languages = await di.init();

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance.getInitialMessage().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  } catch (e) {
    debugPrint('FirebaseMessaging init error: $e');
  }

  if (ResponsiveHelper.isWeb()) {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "380903914182154",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  }

  runApp(MyApp(languages: languages, body: body));
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  const MyApp({super.key, required this.languages, required this.body});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  String? deeplinkRoute;
  String? _initialRoute;

  @override
  void initState() {
    super.initState();

    if(!GetPlatform.isWeb) {
      _initAppLinks();
    }

    _route();
    
    _initialRoute = GetPlatform.isWeb ? RouteHelper.getInitialRoute() : RouteHelper.getSplashRoute(widget.body, deeplinkRoute);

  }

  void _initAppLinks() async {
    _appLinks = AppLinks();

    // Listen for any subsequent incoming links
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        if (kDebugMode) {
          print('=======Received URI: $uri and previous deeplinkRoute: ${Get.find<SplashController>().deeplinkRoute}');
        }
        LinkConverter.convertDeepLink(uri);
      }
    }, onError: (err) {
      if (kDebugMode) {
        print('catch Error in initAppLinksStream: $err');
      }
    });
  }

  void _route() async {
    if(GetPlatform.isWeb) {
       Get.find<SplashController>().initSharedData();
      if(AddressHelper.getUserAddressFromSharedPref() != null && AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
        Get.find<AuthController>().clearSharedAddress();
      }

      if(!AuthHelper.isLoggedIn() && !AuthHelper.isGuestLoggedIn()) {
        await Get.find<AuthController>().guestLogin();
      }

      if((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) && Get.find<SplashController>().cacheModule != null) {
        Get.find<CartController>().getAllCarts();
      }

      Get.find<SplashController>().getConfigData(loadLandingData: (GetPlatform.isWeb && AddressHelper.getUserAddressFromSharedPref() == null), fromMainFunction: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetBuilder<SplashController>(builder: (splashController) {
          return (GetPlatform.isWeb && splashController.configModel == null) ? const SizedBox() : GetMaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: Get.key,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
            ),
            theme: themeController.darkTheme ? dark() : light(),
            locale: localizeController.locale,
            translations: Messages(languages: widget.languages),
            fallbackLocale: Locale(AppConstants.languages[0].languageCode!, AppConstants.languages[0].countryCode),
            initialRoute: _initialRoute,
            getPages: RouteHelper.routes,
            routingCallback: (routing) {
              // Keep the home status-bar tint overlay in sync with modal state so it
              // doesn't paint a bright strip above a bottom sheet's / dialog's scrim.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                HomeStatusBarTint.modalOpen.value = routing != null && ((routing.isBottomSheet ?? false) || (routing.isDialog ?? false));
              });
              if (routing == null || (routing.isBottomSheet ?? false) || (routing.isDialog ?? false)) return;
              if (Get.isRegistered<ProController>()) {
                Get.find<ProController>().maybeShowRenewOnRoute(routing.current);
              }
            },
            defaultTransition: GetPlatform.isWeb ? Transition.fadeIn : Transition.topLevel,
            transitionDuration: const Duration(milliseconds: 700),
            builder: (BuildContext context, widget) {
              return MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)), child: Material(
                child: SafeArea(
                  top: false, bottom: GetPlatform.isAndroid,
                  child: Stack(children: [
                    widget!,

                    GetBuilder<SplashController>(builder: (splashController){
                      final cookiesText = splashController.configModel?.cookiesText ?? '';
                      if(ResponsiveHelper.isWeb() && !splashController.savedCookiesData && !splashController.getAcceptCookiesStatus(cookiesText)){
                        return const Align(alignment: Alignment.bottomCenter, child: CookiesView());
                      }else{
                        return const SizedBox.shrink();
                      }
                    }),

                    // Keeps the home dashboard status-bar tint stable above modal
                    // barriers (bottom sheets / dialogs). Inert unless the home tab
                    // is the visible, uncovered page.
                    const HomeStatusBarTintOverlay(),
                  ]),
                ),
              ));
            },
          );
        });
      });
    });
  }
}

