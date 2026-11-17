import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/checkout/widgets_new/custom_card_checkout.dart';
import 'package:sixam_mart/features/store/domain/models/store_branch_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class BranchSelectionWidget extends StatelessWidget {
  final CheckoutController checkoutController;
  final AddressModel? userAddress;

  const BranchSelectionWidget({
    super.key,
    required this.checkoutController,
    this.userAddress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';
    final branches = checkoutController.branches;
    final selectedBranch = checkoutController.selectedBranch;

    if (checkoutController.isBranchesLoading && (branches == null || branches.isEmpty)) {
      return Padding(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
        child: CustomCardCheckout(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Row(children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(
              isArabic ? 'جاري تحميل الفروع القريبة...' : 'Loading nearest branches...',
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
          ]),
        ),
      );
    }

    // If there are no branches defined for the store, do not render the card
    if (branches == null || branches.isEmpty) {
      return const SizedBox.shrink();
    }

    final String displayName = isArabic
        ? ((selectedBranch?.nameAr?.isNotEmpty ?? false) ? selectedBranch!.nameAr! : (selectedBranch?.name ?? ''))
        : (selectedBranch?.name ?? '');

    final String displayAddress = isArabic
        ? ((selectedBranch?.addressAr?.isNotEmpty ?? false) ? selectedBranch!.addressAr! : (selectedBranch?.address ?? ''))
        : (selectedBranch?.address ?? '');

    final bool isNearest = selectedBranch?.isNearest == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: CustomCardCheckout(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.storefront_rounded, color: Theme.of(context).primaryColor, size: 22),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Text(
                  checkoutController.orderType == 'take_away'
                      ? (isArabic ? 'فرع الاستلام والتجهيز' : 'Pickup & Fulfillment Branch')
                      : (isArabic ? 'فرع تجهيز الطلب' : 'Fulfillment Branch'),
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
              ),
              if (branches.length > 1)
                InkWell(
                  onTap: () => _openBranchSelector(context),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isArabic ? 'تغيير' : 'Change',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Theme.of(context).primaryColor),
                      ],
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Branch card view
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayName.isNotEmpty ? displayName : (checkoutController.store?.name ?? ''),
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isNearest) ...[
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                                ),
                                child: Text(
                                  isArabic ? 'الأقرب إليك' : 'Nearest',
                                  style: robotoRegular.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (displayAddress.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            displayAddress,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (selectedBranch?.phone != null && selectedBranch!.phone!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(children: [
                            Icon(Icons.phone_rounded, size: 12, color: Theme.of(context).disabledColor),
                            const SizedBox(width: 4),
                            Text(
                              selectedBranch.phone!,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                          ]),
                        ],
                      ],
                    ),
                  ),

                  if (selectedBranch?.distance != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        '${selectedBranch!.distance!.toStringAsFixed(1)} ${isArabic ? 'كم' : 'km'}',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBranchSelector(BuildContext context) {
    showCustomBottomSheet(
      child: _BranchListBottomSheet(
        branches: checkoutController.branches ?? [],
        selectedBranch: checkoutController.selectedBranch,
        userAddress: userAddress,
        onBranchSelected: (branch) {
          checkoutController.selectBranch(branch, address: userAddress);
        },
      ),
    );
  }
}

class _BranchListBottomSheet extends StatelessWidget {
  final List<StoreBranchModel> branches;
  final StoreBranchModel? selectedBranch;
  final AddressModel? userAddress;
  final Function(StoreBranchModel) onBranchSelected;

  const _BranchListBottomSheet({
    required this.branches,
    required this.selectedBranch,
    this.userAddress,
    required this.onBranchSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'اختر الفرع المناسب' : 'Select Branch',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          const Divider(),

          // Branch list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              itemCount: branches.length,
              separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingSizeSmall),
              itemBuilder: (context, index) {
                final branch = branches[index];
                final bool isSelected = selectedBranch?.id == branch.id;
                final bool isNearest = branch.isNearest == true;

                final String name = isArabic
                    ? ((branch.nameAr?.isNotEmpty ?? false) ? branch.nameAr! : (branch.name ?? ''))
                    : (branch.name ?? '');

                final String address = isArabic
                    ? ((branch.addressAr?.isNotEmpty ?? false) ? branch.addressAr! : (branch.address ?? ''))
                    : (branch.address ?? '');

                return InkWell(
                  onTap: () {
                    Get.back();
                    onBranchSelected(branch);
                  },
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor.withValues(alpha: 0.2),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                          size: 22,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      name,
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: isSelected ? Theme.of(context).primaryColor : null,
                                      ),
                                    ),
                                  ),
                                  if (isNearest) ...[
                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                                      ),
                                      child: Text(
                                        isArabic ? 'الأقرب إليك' : 'Nearest',
                                        style: robotoMedium.copyWith(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (address.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  address,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                              ],
                              if (branch.phone != null && branch.phone!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.phone_rounded, size: 13, color: Theme.of(context).disabledColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      branch.phone!,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (branch.distance != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: Text(
                              '${branch.distance!.toStringAsFixed(1)} ${isArabic ? 'كم' : 'km'}',
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).primaryColor,
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
        ],
      ),
    );
  }
}
