import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/category/domain/models/category_model.dart';
import 'package:sixam_mart/features/category/screens/category_item_screen.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/onboard/screens/onboarding_new_screen.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/reels/screens/reels_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Vibrant full-feature side drawer matching modern supermarket standards.
class BellaMenuDrawer extends StatelessWidget {
  const BellaMenuDrawer({super.key});

  CategoryModel? _resolveCategory(int fallbackId, {String? slug}) {
    if (!Get.isRegistered<CategoryController>()) return null;
    final List<CategoryModel>? list = Get.find<CategoryController>().categoryList;
    if (list == null || list.isEmpty) return null;
    return list.firstWhereOrNull((c) => c.id == fallbackId) ??
        (slug != null ? list.firstWhereOrNull((c) => c.slug == slug) : null);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthHelper.isLoggedIn();
    final Color drawerColor = Theme.of(context).primaryColor;

    return Drawer(
      backgroundColor: drawerColor,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge,
            vertical: Dimensions.paddingSizeDefault,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Greeting & Supermarket Header
              GetBuilder<ProfileController>(builder: (profileController) {
                final String? name = profileController.userInfoModel?.fName;
                final String greeting = (name != null && name.trim().isNotEmpty)
                    ? name
                    : (isLoggedIn ? 'Valued Customer'.tr : 'Guest Shopper'.tr);

                return Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(Images.logo, fit: BoxFit.contain),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: robotoBold.copyWith(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.flash_on_rounded, color: Color(0xFFFFD700), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '24/7 Express • 3 Branches'.tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              Divider(
                color: Colors.white.withValues(alpha: 0.25),
                thickness: 0.8,
                height: 1,
              ),

              // Scrollable Menu Items List
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // 1. Profile
                    _buildMenuItem(
                      icon: CupertinoIcons.person_crop_circle,
                      title: 'Profile'.tr,
                      onTap: () {
                        Get.back();
                        Get.toNamed(RouteHelper.getProfileRoute());
                      },
                    ),
                    _buildDivider(),

                    // 2. 🏪 3 Branches (University St, Abu Rashid, Lawazem)
                    _buildMenuItem(
                      icon: Icons.storefront_rounded,
                      title: 'OTR Branches (فروع إربد)'.tr,
                      onTap: () {
                        Get.back();
                        Get.toNamed(RouteHelper.getAllStoreRoute('branches'));
                      },
                    ),
                    _buildDivider(),

                    // 3. 🎬 OTR Reels
                    _buildMenuItem(
                      icon: Icons.play_circle_fill_rounded,
                      title: 'OTR Reels (عروض الفيديو)'.tr,
                      badge: 'NEW',
                      onTap: () {
                        Get.back();
                        Get.to(() => const ReelsScreen());
                      },
                    ),
                    _buildDivider(),

                    // 4. 🌍 Imported Luxury Goods
                    _buildMenuItem(
                      icon: Icons.public_rounded,
                      title: 'Imported Goods (بضائع مستوردة)'.tr,
                      badge: 'HOT',
                      onTap: () {
                        Get.back();
                        final CategoryModel? importedCat = _resolveCategory(
                          AppConstants.importedLuxuryCategoryId,
                          slug: AppConstants.importedLuxuryCategorySlug,
                        );
                        Get.to(() => CategoryItemScreen(
                          categoryID: (importedCat?.id ?? AppConstants.importedLuxuryCategoryId).toString(),
                          categoryName: importedCat?.name ?? 'Imported Luxury'.tr,
                        ));
                      },
                    ),
                    _buildDivider(),

                    // 5. 💎 Exclusive Luxury Items
                    _buildMenuItem(
                      icon: Icons.diamond_rounded,
                      title: 'Exclusive Luxury (حصريات OTR)'.tr,
                      onTap: () {
                        Get.back();
                        final CategoryModel? exclusiveCat = _resolveCategory(
                          AppConstants.snacksChocolateCategoryId,
                          slug: 'snacks-chocolate',
                        );
                        Get.to(() => CategoryItemScreen(
                          categoryID: (exclusiveCat?.id ?? AppConstants.snacksChocolateCategoryId).toString(),
                          categoryName: exclusiveCat?.name ?? 'Snacks & Chocolate'.tr,
                        ));
                      },
                    ),
                    _buildDivider(),

                    // 6. 🔥 Flash Sale
                    _buildMenuItem(
                      icon: CupertinoIcons.bolt_fill,
                      title: 'Flash Sale 🔥'.tr,
                      onTap: () {
                        Get.back();
                        Get.toNamed(RouteHelper.getFlashSaleDetailsScreen(1));
                      },
                    ),
                    _buildDivider(),

                    // 7. 🛍️ All Categories
                    _buildMenuItem(
                      icon: CupertinoIcons.square_grid_2x2,
                      title: 'All Categories'.tr,
                      onTap: () {
                        Get.back();
                        Get.toNamed(RouteHelper.getCategoryRoute());
                      },
                    ),
                    _buildDivider(),

                    // 8. 📦 Orders
                    _buildMenuItem(
                      icon: CupertinoIcons.bag,
                      title: 'orders'.tr,
                      onTap: () {
                        Get.back();
                        Get.toNamed(RouteHelper.getOrderRoute());
                      },
                    ),
                    _buildDivider(),

                    // 9. 🎟️ Offers & Coupons
                    _buildMenuItem(
                      icon: CupertinoIcons.tag,
                      title: 'offer and promo'.tr,
                      onTap: () {
                        Get.back();
                        Get.toNamed(RouteHelper.getCouponRoute());
                      },
                    ),
                    _buildDivider(),

                    // 10. 📍 Delivery Addresses
                    _buildMenuItem(
                      icon: CupertinoIcons.location,
                      title: 'My Addresses'.tr,
                      onTap: () {
                        Get.back();
                        Get.toNamed(RouteHelper.getAddressRoute());
                      },
                    ),
                    _buildDivider(),

                    // 11. 💬 24/7 Customer Support
                    _buildMenuItem(
                      icon: CupertinoIcons.chat_bubble_2,
                      title: '24/7 Live Support'.tr,
                      onTap: () {
                        Get.back();
                        Get.toNamed(RouteHelper.getSupportRoute());
                      },
                    ),
                    _buildDivider(),

                    // 12. 🌐 Language
                    _buildMenuItem(
                      icon: Icons.language_rounded,
                      title: 'Language (اللغة)'.tr,
                      onTap: () {
                        Get.back();
                        Get.toNamed(RouteHelper.getLanguageRoute('menu'));
                      },
                    ),
                    _buildDivider(),

                    // 13. 🚀 App Tour (First-Time Wizard)
                    _buildMenuItem(
                      icon: Icons.explore_rounded,
                      title: 'App Tour (دليل التطبيق)'.tr,
                      onTap: () {
                        Get.back();
                        Get.to(() => const OnBoardingNewScreen());
                      },
                    ),
                    _buildDivider(),

                    // 14. 📜 Privacy Policy
                    _buildMenuItem(
                      icon: CupertinoIcons.doc_text,
                      title: 'Privacy policy'.tr,
                      onTap: () {
                        Get.back();
                        Get.toNamed(RouteHelper.privacyPolicy);
                      },
                    ),
                    _buildDivider(),

                    // 15. ⚖️ Terms & Conditions
                    _buildMenuItem(
                      icon: CupertinoIcons.shield_lefthalf_fill,
                      title: 'terms_conditions'.tr,
                      onTap: () {
                        Get.back();
                        Get.toNamed(RouteHelper.termsAndCondition);
                      },
                    ),
                    _buildDivider(),

                    // 16. 📸 Official Instagram
                    _buildMenuItem(
                      icon: CupertinoIcons.camera_fill,
                      title: 'Instagram (@otr.market1)',
                      badge: 'Follow',
                      onTap: () async {
                        Get.back();
                        const url = 'https://www.instagram.com/otr.market1';
                        if (await canLaunchUrlString(url)) {
                          await launchUrlString(url, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                    _buildDivider(),

                    // 17. 💬 WhatsApp Support
                    _buildMenuItem(
                      icon: CupertinoIcons.chat_bubble_2_fill,
                      title: 'WhatsApp Support'.tr,
                      badge: '24/7',
                      onTap: () async {
                        Get.back();
                        const url = 'https://wa.me/962788882470';
                        if (await canLaunchUrlString(url)) {
                          await launchUrlString(url, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ],
                ),
              ),

              Divider(
                color: Colors.white.withValues(alpha: 0.25),
                thickness: 0.8,
                height: 1,
              ),

              // Sign-out / Sign-in at bottom
              InkWell(
                onTap: () {
                  Get.back();
                  if (isLoggedIn) {
                    Get.dialog(ConfirmationDialog(
                      icon: Images.support,
                      description: 'are_you_sure_to_logout'.tr,
                      isLogOut: true,
                      onYesPressed: () async {
                        Get.find<AuthController>().resetOtpView();
                        Get.find<ProfileController>().clearUserInfo();
                        await Get.find<AuthController>().clearSharedData();
                        Get.find<CartController>().clearCartList();
                        Get.find<AuthController>().socialLogout();
                        Get.find<FavouriteController>().removeFavourite();
                        Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                      },
                    ));
                  } else {
                    Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isLoggedIn ? 'Sign-out'.tr : 'Sign-in'.tr,
                        style: robotoBold.copyWith(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 21),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoMedium.copyWith(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge.tr,
                  style: robotoBold.copyWith(
                    fontSize: 10,
                    color: const Color(0xFF891C1E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.15),
      thickness: 0.5,
      height: 1,
    );
  }
}
