import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/screens/global_cart_screen.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class DetailsAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  const DetailsAppBarWidget({super.key, this.onBackPressed});

  @override
  DetailsAppBarWidgetState createState() => DetailsAppBarWidgetState();

  @override
  Size get preferredSize => const Size(double.maxFinite, 50);
}

class DetailsAppBarWidgetState extends State<DetailsAppBarWidget> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void shake() {
    controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 15.0).chain(CurveTween(curve: Curves.elasticIn)).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        }
      });

    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: 56,
      titleSpacing: 8,
      centerTitle: false,
      leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).textTheme.bodyLarge!.color), onPressed: () {
        if(widget.onBackPressed != null) {
          widget.onBackPressed!();
        } else if(Get.find<SplashController>().deeplinkRoute != null) {
          Get.find<SplashController>().setDeeplink(null);
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          Navigator.pop(context);
        }
      }),
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      title: Text(
        'item_details'.tr,
        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color),
      ),
      actions: [AnimatedBuilder(
        animation: offsetAnimation,
        builder: (buildContext, child) {
          return Container(
            padding: EdgeInsets.only(left: offsetAnimation.value + 15.0, right: 15.0 - offsetAnimation.value),
            child: Stack(children: [
              IconButton(icon: Icon(Icons.shopping_cart, color: Theme.of(context).primaryColor), onPressed: () {
                Get.to(() => const GlobalCartScreen(fromNav: false));
              }),
              Positioned(
                top: 5, right: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                  child: GetBuilder<CartController>(builder: (cartController) {
                    return Text(
                      cartController.cartList.length.toString(),
                      style: robotoMedium.copyWith(color: Colors.white, fontSize: 8),
                    );
                  }),
                ),
              ),

            ]),
          );
        },
      )],
    );
  }
}
