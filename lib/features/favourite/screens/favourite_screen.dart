import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/common/widgets/exclusive_deal_card.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class FavouriteScreen extends StatefulWidget {
  final Function()? onBackPressed;
  const FavouriteScreen({super.key, this.onBackPressed});

  @override
  FavouriteScreenState createState() => FavouriteScreenState();
}

class FavouriteScreenState extends State<FavouriteScreen> {
  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() {
    if (AuthHelper.isLoggedIn()) {
      Get.find<FavouriteController>().getFavouriteList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color tinted = Color.alphaBlend(
      Theme.of(context).disabledColor.withAlpha(30),
      Theme.of(context).cardColor,
    );

    return Scaffold(
      backgroundColor: tinted,
      appBar: CustomAppBar(title: 'favourite'.tr, backButton: true, onBackPressed: widget.onBackPressed),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: AuthHelper.isLoggedIn()
          ? SafeArea(
              bottom: false,
              child: GetBuilder<FavouriteController>(builder: (controller) {
                final List<Item> items = (controller.wishItemList ?? const <Item?>[])
                    .where((Item? e) => e != null).cast<Item>().toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.getFavouriteList();
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: _buildItemsBody(context: context, controller: controller, items: items),
                      ),
                    ],
                  ),
                );
              }),
            )
          : NotLoggedInScreen(callBack: (value) {
              _initCall();
              setState(() {});
            }),
    );
  }

  Widget _buildItemsBody({required BuildContext context, required FavouriteController controller, required List<Item> items}) {
    if (controller.wishItemList == null) {
      return const _LoadingPlaceholder();
    }
    if (items.isEmpty) {
      return _EmptyView(message: 'no_wish_data_found'.tr);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeDefault,
      ),
      child: Column(
        children: items.map((Item item) {
          final bool isLast = identical(item, items.last);
          final int index = items.indexOf(item);
          return Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : Dimensions.paddingSizeDefault),
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              border: isLast ? null : Border(
                bottom: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.18)),
              ),
            ),
            child: ExclusiveDealCard(
              item: item,
              width: double.infinity,
              index: index,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          children: List<Widget>.generate(6, (int index) => Padding(
            padding: EdgeInsets.only(bottom: index == 5 ? 0 : Dimensions.paddingSizeLarge),
            child: const _ItemShimmerRow(),
          )),
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const _ShimmerBox({this.width, required this.height, this.radius = Dimensions.radiusSmall});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _ItemShimmerRow extends StatelessWidget {
  const _ItemShimmerRow();

  @override
  Widget build(BuildContext context) {
    return const Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      _ShimmerBox(width: 90, height: 90, radius: Dimensions.radiusDefault),
      SizedBox(width: Dimensions.paddingSizeDefault),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          _ShimmerBox(width: 160, height: 14),
          SizedBox(height: Dimensions.paddingSizeSmall),
          _ShimmerBox(width: 110, height: 12),
          SizedBox(height: Dimensions.paddingSizeSmall),
          _ShimmerBox(width: 70, height: 12),
          SizedBox(height: Dimensions.paddingSizeSmall),
          _ShimmerBox(width: 90, height: 14),
        ]),
      ),
    ]);
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}
