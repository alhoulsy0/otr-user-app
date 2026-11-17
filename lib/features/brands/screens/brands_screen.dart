import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
import 'package:sixam_mart/features/brands/controllers/brands_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {

  @override
  void initState() {
    Get.find<BrandsController>().getBrandList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: CustomAppBar(title: 'all_brands'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<BrandsController>(builder: (brandsController) {
        return SingleChildScrollView(
          child: FooterView(
            child: Column(children: [

              WebScreenTitleWidget(title: 'all_brands'.tr),

              SizedBox(
                width: Dimensions.webMaxWidth,
                child: brandsController.brandList != null ? brandsController.brandList!.isNotEmpty ? GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 0 : Dimensions.paddingSizeExtraLarge,
                    vertical: Dimensions.paddingSizeExtraLarge,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 5 : 3,
                    crossAxisSpacing: Dimensions.paddingSizeDefault,
                    mainAxisSpacing: Dimensions.paddingSizeDefault,
                    mainAxisExtent: isDesktop ? 150 : 130,
                  ),
                  itemCount: brandsController.brandList!.length,
                  itemBuilder: (context, index) {
                    final brand = brandsController.brandList![index];
                    return InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getBrandsItemScreen(brand.id!, brand.name!, slug: brand.slug!)),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: Center(
                                child: CustomImage(
                                  image: '${brand.imageFullUrl}',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).disabledColor.withValues(alpha: 0.06),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusDefault)),
                            ),
                            child: Text(
                              brand.name ?? '',
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      ),
                    );
                  },
                ) : Center(child: Padding(padding: EdgeInsets.only(top: isDesktop ? context.height * 0.3 : context.height * 0.4), child: Text('no_brands_found'.tr)))
                    : Center(child: Padding(padding: EdgeInsets.only(top: isDesktop ? context.height * 0.3 : context.height * 0.4), child: const CircularProgressIndicator())),
              ),

            ]),
          ),
        );
      }),
    );
  }
}
