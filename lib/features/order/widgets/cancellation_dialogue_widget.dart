import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class CancellationDialogueWidget extends StatefulWidget {
  final int? orderId;
  final String? contactNumber;
  final String? orderCreatedAt;
  const CancellationDialogueWidget({super.key, required this.orderId, this.contactNumber, this.orderCreatedAt});

  @override
  State<CancellationDialogueWidget> createState() => _CancellationDialogueWidgetState();
}

class _CancellationDialogueWidgetState extends State<CancellationDialogueWidget> {
  TextEditingController commentController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = 300;

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().getOrderCancelReasons();
    _calculateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _calculateRemainingTime() {
    if (widget.orderCreatedAt != null && widget.orderCreatedAt!.isNotEmpty) {
      String dateStr = widget.orderCreatedAt!.trim();
      DateTime? orderTime;
      try {
        if (!dateStr.contains('Z') && !dateStr.contains('+')) {
          dateStr = '${dateStr.replaceAll(' ', 'T')}+03:00';
        }
        orderTime = DateTime.parse(dateStr);
      } catch (_) {
        orderTime = DateTime.tryParse(dateStr);
      }

      if (orderTime != null) {
        final elapsedSeconds = DateTime.now().toUtc().difference(orderTime.toUtc()).inSeconds;
        final safeElapsed = elapsedSeconds < 0 ? 0 : elapsedSeconds;
        final remaining = 300 - safeElapsed;

        if (remaining <= 0) {
          _secondsRemaining = 0;
          return;
        }
        _secondsRemaining = remaining.clamp(0, 300);
        return;
      }
    }
    _secondsRemaining = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    commentController.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final clamped = totalSeconds.clamp(0, 300);
    final minutes = clamped ~/ 60;
    final seconds = clamped % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: GetBuilder<OrderController>(builder: (orderController) {
        return SizedBox(
          width: 500,
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Container(
              width: 500,
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
              ),
              child: Column(children: [
                Text('select_cancellation_reasons'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                if (_secondsRemaining > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          'Time remaining: ${_formatDuration(_secondsRemaining)}',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.orange.shade800),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Time limit expired (5 minutes)',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.red),
                    ),
                  ),
              ]),
            ),

            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  orderController.orderCancelReasons != null ? orderController.orderCancelReasons!.isNotEmpty ? Flexible(
                    child: ListView.builder(
                      itemCount: orderController.orderCancelReasons!.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index){
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: (){
                            orderController.setOrderCancelReason(orderController.orderCancelReasons![index].reason);
                          },
                          title: Row(
                            children: [
                              Icon(orderController.orderCancelReasons![index].reason == orderController.cancelReason ? Icons.radio_button_checked : Icons.radio_button_off, color: Theme.of(context).primaryColor, size: 18),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Flexible(child: Text(orderController.orderCancelReasons![index].reason!, style: robotoRegular, maxLines: 3, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        );
                      },
                    ),
                  ) : const SizedBox() : const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault), child: CircularProgressIndicator())),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text(
                    'comments'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  CustomTextField(
                    controller: commentController,
                    titleText: 'type_here_your_cancel_reason'.tr,
                    showLabelText: false,
                    maxLines: 2,
                    inputType: TextInputType.multiline,
                    inputAction: TextInputAction.done,
                    capitalization: TextCapitalization.sentences,
                  ),

                ]),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: !orderController.isLoading ? Row(children: [
                Expanded(child: CustomButton(
                  buttonText: 'cancel'.tr, color: Theme.of(context).disabledColor, radius: 50,
                  onPressed: () => Get.back(),
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: CustomButton(
                  buttonText: 'submit'.tr, radius: 50,
                  onPressed: _secondsRemaining <= 0 ? () {
                    Get.back();
                    showCustomSnackBar('order_cancellation_time_limit_expired'.tr);
                  } : () {
                    if((orderController.cancelReason != '' && orderController.cancelReason != null) || commentController.text.isNotEmpty){
                      orderController.cancelOrder(
                        orderID: widget.orderId!,
                        reason: orderController.cancelReason,
                        isParcel: false,
                        comment: commentController.text.trim(),
                      ).then((success) {
                        Get.back();
                        if(success){
                          showCustomSnackBar('order_cancelled_successfully'.tr, isError: false);
                          orderController.trackOrder(widget.orderId.toString(), null, true, contactNumber: widget.contactNumber);
                        } else {
                          showCustomSnackBar('cannot_cancel_order_limit_expired'.tr);
                          orderController.trackOrder(widget.orderId.toString(), null, true, contactNumber: widget.contactNumber);
                        }
                      });
                    } else {
                      if(orderController.cancelReason != '' && orderController.cancelReason != null){
                        showCustomSnackBar('you_did_not_select_any_reason'.tr);
                      } else if(commentController.text.isEmpty){
                        showCustomSnackBar('you_did_not_write_any_comment'.tr, getXSnackBar: true);
                      }
                    }
                  },
                )),
              ]) : const Center(child: CircularProgressIndicator()),
            ),
          ]),
        );
      }),
    );
  }
}
