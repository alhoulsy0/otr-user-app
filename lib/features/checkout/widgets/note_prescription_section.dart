import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';

class NoteAndPrescriptionSection extends StatelessWidget {
  final CheckoutController checkoutController;
  final int? storeId;
  const NoteAndPrescriptionSection({super.key, required this.checkoutController, this.storeId, });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('additional_note'.tr, style: robotoMedium),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      CustomTextField(
        controller: checkoutController.noteController,
        titleText: 'please_provide_extra_napkin'.tr,
        showLabelText: false,
        maxLines: 3,
        inputType: TextInputType.multiline,
        inputAction: TextInputAction.done,
        capitalization: TextCapitalization.sentences,
      ),
      const SizedBox(height: Dimensions.paddingSizeDefault),

      GetBuilder<CheckoutController>(builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: controller.bringAtmMachine ? Theme.of(context).primaryColor.withValues(alpha: 0.08) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(
              color: controller.bringAtmMachine ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3),
              width: controller.bringAtmMachine ? 1.5 : 1.0,
            ),
          ),
          child: InkWell(
            onTap: () => controller.toggleBringAtmMachine(!controller.bringAtmMachine),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
              child: Row(
                children: [
                  Checkbox(
                    value: controller.bringAtmMachine,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: controller.toggleBringAtmMachine,
                  ),
                  Icon(
                    Icons.credit_card_outlined,
                    color: controller.bringAtmMachine ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                    size: 24,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'request_mobile_atm_machine'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: controller.bringAtmMachine ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'bring_mobile_atm_remark'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      const SizedBox(height: Dimensions.paddingSizeLarge),

      /*storeId == null && Get.find<SplashController>().configModel!.moduleConfig!.module!.orderAttachment! ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('prescription'.tr, style: robotoMedium),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            Text(
              '(${'max_size_2_mb'.tr})',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          ImagePickerWidget(
            image: '', rawFile: checkoutController.rawAttachment,
            onTap: () => checkoutController.pickImage(),
          ),
        ],
      ) : const SizedBox(),*/
    ]);
  }
}
