import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/checkout/widgets_new/custom_card_checkout.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

import 'package:flutter/services.dart';

class DeliveryManTipsSection extends StatefulWidget {
  final bool takeAway;
  final JustTheController tooltipController3;
  final double totalPrice;
  final Function(double x) onTotalChange;
  final int? storeId;
  const DeliveryManTipsSection({
    super.key,
    required this.takeAway,
    required this.tooltipController3,
    required this.totalPrice,
    required this.onTotalChange,
    this.storeId,
  });

  @override
  State<DeliveryManTipsSection> createState() => _DeliveryManTipsSectionState();
}

class _DeliveryManTipsSectionState extends State<DeliveryManTipsSection> {
  bool canCheckSmall = false;
  late final TextEditingController _customTipController;

  @override
  void initState() {
    super.initState();
    final initialTip = Get.find<CheckoutController>().tips;
    _customTipController = TextEditingController(
      text: initialTip > 0 ? (initialTip % 1 == 0 ? initialTip.toInt().toString() : initialTip.toString()) : '',
    );
  }

  @override
  void dispose() {
    _customTipController.dispose();
    super.dispose();
  }

  void _applyTip(CheckoutController checkoutController, double newTip, {bool updateCustomController = true}) {
    if (newTip < 0) {
      newTip = 0;
    }
    double total = widget.totalPrice - checkoutController.tips;
    checkoutController.addTips(newTip);
    checkoutController.tipController.text = newTip > 0 ? (newTip % 1 == 0 ? newTip.toInt().toString() : newTip.toString()) : '0';

    if (updateCustomController) {
      if (newTip <= 0) {
        _customTipController.clear();
      } else {
        _customTipController.text = newTip % 1 == 0 ? newTip.toInt().toString() : newTip.toString();
        _customTipController.selection = TextSelection.fromPosition(TextPosition(offset: _customTipController.text.length));
      }
    }

    total = total + checkoutController.tips;
    widget.onTotalChange(total);

    if (AuthHelper.isLoggedIn()) {
      final double walletBalance = Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0;
      if (walletBalance < total && checkoutController.paymentMethodIndex == 1) {
        checkoutController.checkBalanceStatus(total, 0);
        canCheckSmall = true;
      } else if (walletBalance > total && canCheckSmall && checkoutController.isPartialPay) {
        checkoutController.checkBalanceStatus(total, 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dmTipsEnabled = Get.find<SplashController>().configModel!.dmTipsStatus == 1;
    if (widget.takeAway || !dmTipsEnabled) {
      return const SizedBox.shrink();
    }

    final currencySymbol = Get.find<SplashController>().configModel?.currencySymbol ?? 'JD';

    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      final double currentTip = checkoutController.tips;

      return CustomCardCheckout(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          _TipsHeader(tooltipController: widget.tooltipController3),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Numeric Stepper with - and +
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.25)),
            ),
            child: Row(children: [
              // Decrement Button (-)
              InkWell(
                onTap: currentTip > 0 ? () {
                  double next = (currentTip - 0.50);
                  if (next < 0) next = 0;
                  _applyTip(checkoutController, next);
                } : null,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: Container(
                  height: 38, width: 38,
                  decoration: BoxDecoration(
                    color: currentTip > 0 ? Theme.of(context).primaryColor.withValues(alpha: 0.12) : Theme.of(context).disabledColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Icon(Icons.remove, size: 20, color: currentTip > 0 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                ),
              ),

              // Center display & input
              Expanded(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    PriceConverter.convertPrice(currentTip),
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: currentTip > 0 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                    ),
                  ),
                  if (currentTip == 0)
                    Text(
                      'not_now'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                    ),
                ]),
              ),

              // Increment Button (+)
              InkWell(
                onTap: () {
                  double next = currentTip + 0.50;
                  _applyTip(checkoutController, next);
                },
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: Container(
                  height: 38, width: 38,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: const Icon(Icons.add, size: 20, color: Colors.white),
                ),
              ),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Quick Preset Buttons (0 JD, 0.5 JD, 1 JD, 2 JD, 3 JD)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _buildPresetChip('0', '0.00', currentTip == 0.0, () => _applyTip(checkoutController, 0.0)),
              _buildPresetChip('0.5', '0.50', (currentTip - 0.5).abs() < 0.001, () => _applyTip(checkoutController, 0.5)),
              _buildPresetChip('1.0', '1.00', (currentTip - 1.0).abs() < 0.001, () => _applyTip(checkoutController, 1.0)),
              _buildPresetChip('2.0', '2.00', (currentTip - 2.0).abs() < 0.001, () => _applyTip(checkoutController, 2.0)),
              _buildPresetChip('3.0', '3.00', (currentTip - 3.0).abs() < 0.001, () => _applyTip(checkoutController, 3.0)),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Custom tip input allowing any floating number
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _customTipController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
              decoration: InputDecoration(
                hintText: '${'enter_amount'.tr} (e.g. 0.5, 1.25)',
                hintStyle: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
                prefixIcon: Icon(
                  Icons.volunteer_activism_outlined,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                suffixText: currencySymbol,
                suffixStyle: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).primaryColor,
                ),
                suffixIcon: currentTip > 0
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => _applyTip(checkoutController, 0.0),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 12),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                final trimmed = value.trim();
                if (trimmed.isEmpty) {
                  _applyTip(checkoutController, 0.0, updateCustomController: false);
                } else {
                  final parsed = double.tryParse(trimmed);
                  if (parsed != null && parsed >= 0) {
                    _applyTip(checkoutController, parsed, updateCustomController: false);
                  }
                }
              },
            ),
          ),

          // _SaveForLaterRow(checkoutController: checkoutController),
        ]),
      );
    });
  }

  Widget _buildPresetChip(String labelAmount, String displayVal, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            labelAmount == '0' ? 'not_now'.tr : PriceConverter.convertPrice(double.parse(labelAmount)),
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _TipsHeader extends StatelessWidget {
  final JustTheController tooltipController;

  const _TipsHeader({required this.tooltipController});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(
          'delivery_tips'.tr,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

        JustTheTooltip(
          backgroundColor: Colors.black87,
          controller: tooltipController,
          preferredDirection: AxisDirection.right,
          tailLength: 14,
          tailBaseWidth: 20,
          content: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Text(
              'it_s_a_great_way_to_show_your_appreciation_for_their_hard_work'.tr,
              style: robotoRegular.copyWith(color: Colors.white),
            ),
          ),
          child: InkWell(
            onTap: () => tooltipController.showTooltip(),
            child: Icon(Icons.info_outline, size: 18, color: Theme.of(context).disabledColor),
          ),
        ),
      ]),
      const SizedBox(height: 2),

      Text(
        'tips_goes_to_deliveryman'.tr,
        style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Theme.of(context).disabledColor,
        ),
      ),
    ]);
  }
}

class _SaveForLaterRow extends StatelessWidget {
  final CheckoutController checkoutController;

  const _SaveForLaterRow({required this.checkoutController});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => checkoutController.toggleDmTipSave(),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.4),
              width: 0.7,
            ),
          ),
          child: Row(children: [
            Expanded(
              child: Text(
                'save_it_for_later'.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            SizedBox(
              height: 22, width: 22,
              child: Checkbox(
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeColor: Theme.of(context).primaryColor,
                value: checkoutController.isDmTipSave,
                onChanged: (_) => checkoutController.toggleDmTipSave(),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
