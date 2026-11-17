import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/common/models/config_model.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/checkout/widgets/slot_widget.dart';
import 'package:sixam_mart/features/checkout/widgets/time_slot_bottom_sheet.dart';
import 'package:sixam_mart/features/checkout/widgets_new/custom_card_checkout.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class TimeSlotSection extends StatelessWidget {
  final int? storeId;
  final CheckoutController checkoutController;
  final List<CartModel?>? cartList;
  final JustTheController tooltipController2;
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;
  final Widget? trailingContent;
  const TimeSlotSection({super.key,
    this.storeId, required this.checkoutController, this.cartList, required this.tooltipController2, required this.tomorrowClosed,
    required this.todayClosed, this.module, this.trailingContent,
  });

  static bool shouldRender({
    required int? storeId, required CheckoutController checkoutController, required List<CartModel?>? cartList,
  }) {
    return storeId == null;
  }

  void _openSheet(BuildContext context) {
    final sheet = TimeSlotBottomSheet(
      tomorrowClosed: tomorrowClosed,
      todayClosed: todayClosed,
      module: module,
    );
    if (ResponsiveHelper.isDesktop(context)) {
      showDialog(context: context, builder: (_) => Dialog(child: sheet));
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => sheet,
      );
    }
  }

  bool _isInstant(CheckoutController c) => c.isInstantDelivery;

  bool _selectedDateClosed(CheckoutController c) {
    return (c.selectedDateSlot == 0 && todayClosed)
        || (c.selectedDateSlot == 1 && tomorrowClosed);
  }

  String _scheduledDisplay(CheckoutController c) {
    if (c.timeSlots == null || c.timeSlots!.isEmpty) return c.preferableTime;
    if (c.selectedTimeSlot >= c.timeSlots!.length) return c.preferableTime;
    final slot = c.timeSlots![c.selectedTimeSlot];
    if (slot.startTime == null) return c.preferableTime;
    final DateTime base = c.selectedDateSlot == 0
        ? DateTime.now()
        : DateTime.now().add(const Duration(days: 1));
    final DateTime when = DateTime(
      base.year, base.month, base.day,
      slot.startTime!.hour, slot.startTime!.minute,
    );
    return DateConverter.dateMonthTime(when);
  }

  void _selectSlot(CheckoutController controller, int index) {
    controller.updateTimeSlot(index);
    if (controller.timeSlots != null && index < controller.timeSlots!.length) {
      final slot = controller.timeSlots![index];
      if (slot.endTime != null && controller.store != null) {
        DateTime date = controller.selectedDateSlot == 0 ? DateTime.now() : DateTime.now().add(const Duration(days: 1));
        DateTime scheduleEndDate = DateTime(date.year, date.month, date.day, slot.endTime!.hour, slot.endTime!.minute + 1);

        controller.getSurgePrice(
          zoneId: controller.store!.zoneId.toString(),
          moduleId: controller.store!.moduleId.toString(),
          dateTime: DateConverter.dateToDateAndTime(scheduleEndDate),
          guestId: AuthHelper.getGuestId(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!shouldRender(storeId: storeId, checkoutController: checkoutController, cartList: cartList)) {
      return const SizedBox();
    }

    return GetBuilder<CheckoutController>(builder: (controller) {
      final bool instant = controller.isInstantDelivery;
      final bool dateClosed = _selectedDateClosed(controller);

      return Column(children: [
        CustomCardCheckout(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            
            // Header with tooltip
            Row(children: [
              Text('Delivery Schedule'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              JustTheTooltip(
                backgroundColor: Colors.black87,
                controller: tooltipController2,
                preferredDirection: AxisDirection.right,
                tailLength: 14,
                tailBaseWidth: 20,
                content: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Text('schedule_time_tool_tip'.tr, style: robotoRegular.copyWith(color: Colors.white)),
                ),
                child: InkWell(
                  onTap: () => tooltipController2.showTooltip(),
                  child: Icon(Icons.info_outline, size: 18, color: Theme.of(context).disabledColor),
                ),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Segmented Switcher: [ Instant Delivery ] vs [ Schedule Order ]
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      controller.setScheduleOrder(false);
                    },
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: instant ? Theme.of(context).primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        boxShadow: instant ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt, size: 18, color: instant ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color),
                          const SizedBox(width: 4),
                          Text(
                            'instant_delivery'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: instant ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      controller.setScheduleOrder(true);
                      if (controller.timeSlots == null || controller.timeSlots!.isEmpty) {
                        // If today has no slots left, switch to tomorrow
                        controller.updateDateSlot(1, Get.find<StoreController>().store?.orderPlaceToScheduleInterval);
                      }
                    },
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !instant ? Theme.of(context).primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        boxShadow: !instant ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 18, color: !instant ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color),
                          const SizedBox(width: 4),
                          Text(
                            'schedule_delivery'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: !instant ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Content based on selection
            if (instant) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(children: [
                  Icon(Icons.access_time_filled, color: Theme.of(context).primaryColor, size: 20),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('instant_delivery'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)),
                      Text('instant_delivery_subtitle'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                    ]),
                  ),
                ]),
              ),
            ] else ...[
              // Scheduled Delivery View
              Row(children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      controller.updateDateSlot(0, Get.find<StoreController>().store?.orderPlaceToScheduleInterval);
                    },
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: controller.selectedDateSlot == 0 ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(
                          color: controller.selectedDateSlot == 0 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3),
                          width: controller.selectedDateSlot == 0 ? 1.5 : 1.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'today'.tr,
                        style: robotoMedium.copyWith(
                          color: controller.selectedDateSlot == 0 ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      controller.updateDateSlot(1, Get.find<StoreController>().store?.orderPlaceToScheduleInterval);
                    },
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: controller.selectedDateSlot == 1 ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(
                          color: controller.selectedDateSlot == 1 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3),
                          width: controller.selectedDateSlot == 1 ? 1.5 : 1.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'tomorrow'.tr,
                        style: robotoMedium.copyWith(
                          color: controller.selectedDateSlot == 1 ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              if (dateClosed)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Center(
                    child: Text(
                      module?.showRestaurantText ?? false ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr,
                      style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                )
              else if (controller.timeSlots != null && controller.timeSlots!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Preferred Time Slot:'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : 2,
                        mainAxisSpacing: Dimensions.paddingSizeSmall,
                        crossAxisSpacing: Dimensions.paddingSizeSmall,
                        mainAxisExtent: 44,
                      ),
                      itemCount: controller.timeSlots!.length,
                      itemBuilder: (context, index) {
                        final slot = controller.timeSlots![index];
                        final String timeStr = '${DateConverter.dateToTimeOnly(slot.startTime!)} - ${DateConverter.dateToTimeOnly(slot.endTime!)}';
                        final bool isSelected = controller.selectedTimeSlot == index;

                        return SlotWidget(
                          title: timeStr,
                          isSelected: isSelected,
                          onTap: () => _selectSlot(controller, index),
                        );
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Scheduled for: ${_scheduledDisplay(controller)}',
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Center(
                    child: Text('no_slot_available'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                  ),
                ),
            ],

            if (trailingContent != null) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),
              trailingContent!,
            ],
          ]),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
      ]);
    });
  }
}
