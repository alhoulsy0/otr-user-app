import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/onboard/controllers/onboard_controller.dart';
import 'package:sixam_mart/features/onboard/domain/repository/onboard_repository.dart';
import 'package:sixam_mart/features/onboard/domain/service/onboard_service.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class OnBoardingNewScreen extends StatefulWidget {
  const OnBoardingNewScreen({super.key});

  @override
  State<OnBoardingNewScreen> createState() => _OnBoardingNewScreenState();
}

class _OnBoardingNewScreenState extends State<OnBoardingNewScreen> {
  final PageController _pageController = PageController();
  late final OnBoardingController _onBoardingController =
      OnBoardingController(onboardServiceInterface: OnboardService(onboardRepositoryInterface: OnboardRepository()));

  static const List<_OnBoardingNewText> _onBoardingText = [
    _OnBoardingNewText(
      image: Images.onboard_1,
      title: 'Groceries for\nEveryone',
      description: 'Shop fresh produce, dairy, bakery and household goods from OTR Supermarket with instant delivery.',
    ),
    _OnBoardingNewText(
      image: Images.onboard_2,
      title: 'Lightning Fast\nDelivery 24/7',
      description: 'Your grocery orders delivered fresh and fast right to your doorstep anytime across Irbid.',
    ),
    _OnBoardingNewText(
      image: Images.onboard_3,
      title: 'Exclusive Daily\nFlash Deals',
      description: 'Enjoy unbelievable discounts on your favorite supermarket items every single day.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _onBoardingController.getOnBoardingList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      body: SafeArea(
        child: GetBuilder<OnBoardingController>(
          init: _onBoardingController,
          global: false,
          builder: (onBoardingController) {
            int displayIndex = onBoardingController.selectedIndex.clamp(0, _onBoardingText.length - 1);

            return Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(
                  children: [
                    // Top Hero Card with circular badge
                    Expanded(
                      flex: 6,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(36),
                            bottomRight: Radius.circular(36),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            PageView.builder(
                              itemCount: _onBoardingText.length,
                              controller: _pageController,
                              onPageChanged: (index) {
                                onBoardingController.changeSelectIndex(index);
                              },
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 20),
                                    Container(
                                      width: 170,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.08),
                                            blurRadius: 18,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      child: Image.asset(Images.logo, fit: BoxFit.contain),
                                    ),
                                    const SizedBox(height: 28),
                                    Image.asset(
                                      _onBoardingText[index].image,
                                      height: context.height * 0.22,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                );
                              },
                            ),

                            // Skip Button
                            Positioned(
                              top: Dimensions.paddingSizeDefault,
                              right: Dimensions.paddingSizeDefault,
                              child: TextButton(
                                onPressed: _configureToRouteInitialPage,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: Text(
                                  'skip'.tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom info & prominent "Get started" button
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  _onBoardingText[displayIndex].title.tr,
                                  style: robotoBold.copyWith(
                                    fontSize: 28,
                                    height: 1.2,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1C1C1E),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 10),

                                Text(
                                  _onBoardingText[displayIndex].description.tr,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: const Color(0xFF707070),
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),

                            Column(
                              children: [
                                // Dots indicator
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(_onBoardingText.length, (index) {
                                    final isSelected = index == displayIndex;
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      height: 8,
                                      width: isSelected ? 28 : 8,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : const Color(0xFFD6D6D6),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 24),

                                // Large rounded pill button "Get started"
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _configureToRouteInitialPage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: Text(
                                      'Get started'.tr,
                                      style: robotoBold.copyWith(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _configureToRouteInitialPage() async {
    Get.find<SplashController>().disableIntro();
    try {
      await Get.find<AuthController>().guestLogin().timeout(const Duration(seconds: 3));
    } catch (_) {}
    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.offAllNamed(RouteHelper.getAccessLocationRoute('splash'));
    }
  }
}

class _OnBoardingNewText {
  final String image;
  final String title;
  final String description;

  const _OnBoardingNewText({required this.image, required this.title, required this.description});
}
