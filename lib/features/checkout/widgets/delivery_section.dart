import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart/common/widgets/custom_dropdown.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/checkout/widgets/address_bottom_sheet.dart';
import 'package:sixam_mart/features/checkout/widgets/delivery_instraction_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/checkout/widgets_new/address_info_bottom_sheet.dart';
import 'package:sixam_mart/features/checkout/widgets_new/custom_card_checkout.dart';
import 'package:sixam_mart/features/location/screens/pick_location_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class DeliverySection extends StatelessWidget {
  final CheckoutController checkoutController;
  final List<AddressModel> address;
  final List<DropdownItem<int>> addressList;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final bool isServiceAddress;
  final int? zoneId;

  const DeliverySection({
    super.key,
    required this.checkoutController,
    required this.address,
    required this.addressList,
    required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController,
    required this.guestNumberNode,
    required this.guestEmailController,
    required this.guestEmailNode,
    this.isServiceAddress = false,
    this.zoneId,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGuest = AuthHelper.isGuestLoggedIn();
    final bool takeAway = checkoutController.orderType == 'take_away';

    return GetBuilder<CheckoutController>(builder: (controller) {
      if (takeAway) {
        return CustomCardCheckout(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.store_mall_directory_rounded, color: Theme.of(context).primaryColor, size: 22),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text('Store Pickup Details'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  controller.store?.name ?? 'OTR Supermarket',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.store?.address ?? 'OTR Supermarket - Irbid',
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _ContactBlock(
              name: _resolveName(controller, isGuest),
              dialCode: controller.countryDialCode,
              phone: _resolvePhone(controller, isGuest),
              onEdit: () => _openSheet(context, isGuest),
              onAdd: () => _openSheet(context, isGuest),
            ),
          ]),
        );
      }

      return CustomCardCheckout(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Text('delivery_address'.tr, style: robotoBold),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          _LocationRow(
            addressText: _resolveAddressText(controller, isGuest),
            onSelectAddress: () => _openSelectAddress(context, isGuest),
            onAddNewAddress: () => _openAddNewAddress(context, isGuest),
            onEditCurrentAddress: () => _openEditCurrentAddress(context, isGuest),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          _ContactBlock(
            name: _resolveName(controller, isGuest),
            dialCode: controller.countryDialCode,
            phone: _resolvePhone(controller, isGuest),
            onEdit: () => _openSheet(context, isGuest),
            onAdd: () => _openSheet(context, isGuest),
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),
          const _DeliveryNoteField(),

          const SizedBox(height: Dimensions.paddingSizeDefault),
          const _AtmMachineOption(),
        ]),
      );
    });
  }

  void _openSelectAddress(BuildContext context, bool isGuest) {
    if (isGuest) {
      _openPickLocationScreen(true);
    } else {
      showCustomBottomSheet(
        child: const AddressBottomSheet(),
      );
    }
  }

  void _openAddNewAddress(BuildContext context, bool isGuest) async {
    if (isGuest) {
      _openPickLocationScreen(true);
      return;
    }
    var newAddress = await Get.toNamed(RouteHelper.getAddAddressRoute(true, false, checkoutController.store?.zoneId));
    if (newAddress != null && newAddress is AddressModel) {
      await checkoutController.insertAddresses(newAddress, notify: true);
      final store = checkoutController.store;
      if (store != null &&
          newAddress.latitude != null && newAddress.latitude!.isNotEmpty &&
          newAddress.longitude != null && newAddress.longitude!.isNotEmpty &&
          store.latitude != null && store.longitude != null) {
        checkoutController.getDistanceInKM(
          LatLng(double.parse(newAddress.latitude!), double.parse(newAddress.longitude!)),
          LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
        );
      }
    }
  }

  void _openEditCurrentAddress(BuildContext context, bool isGuest) async {
    if (isGuest) {
      _openPickLocationScreen(true);
      return;
    }
    final AddressModel? current = checkoutController.address ?? (address.isNotEmpty && checkoutController.addressIndex != null && checkoutController.addressIndex! < address.length ? address[checkoutController.addressIndex!] : null);
    if (current != null) {
      var updated = await Get.toNamed(RouteHelper.getEditAddressRoute(current));
      if (updated != null && updated is AddressModel) {
        await checkoutController.insertAddresses(updated, notify: true);
        final store = checkoutController.store;
        if (store != null &&
            updated.latitude != null && updated.latitude!.isNotEmpty &&
            updated.longitude != null && updated.longitude!.isNotEmpty &&
            store.latitude != null && store.longitude != null) {
          checkoutController.getDistanceInKM(
            LatLng(double.parse(updated.latitude!), double.parse(updated.longitude!)),
            LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
          );
        }
      } else {
        _openPickLocationScreen(false);
      }
    } else {
      _openPickLocationScreen(false);
    }
  }

  void _openSheet(BuildContext context, bool isGuest) {
    AddressInfoBottomSheet.open(
      context,
      checkoutController: checkoutController,
      isGuest: isGuest,
      guestNameController: isGuest ? guestNameTextEditingController : null,
      guestNumberController: isGuest ? guestNumberTextEditingController : null,
      guestEmailController: isGuest ? guestEmailController : null,
      guestNumberNode: isGuest ? guestNumberNode : null,
      guestEmailNode: isGuest ? guestEmailNode : null,
    );
  }

  void _openPickLocationScreen(bool isGuest) {
    Get.to(
      () => PickLocationScreen(
        mode: PickLocationMode.checkout,
        initialSearchText: _resolveAddressText(checkoutController, isGuest),
        onAddressPicked: (address) async {
          if (isGuest) {
            checkoutController.setGuestAddress(address);
          } else {
            await checkoutController.insertAddresses(address, notify: true);
          }
          // Recalculate distance for the newly picked address.
          // Without this call the distance stays stale (calculated on init with
          // the SharedPref address), so delivery charge and the order body are wrong.
          final store = checkoutController.store;
          if (store != null &&
              address.latitude != null && address.latitude!.isNotEmpty &&
              address.longitude != null && address.longitude!.isNotEmpty &&
              store.latitude != null && store.longitude != null) {
            checkoutController.getDistanceInKM(
              LatLng(double.parse(address.latitude!), double.parse(address.longitude!)),
              LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
            );
          }
        },
      ),
      preventDuplicates: false,
    );
  }

  String _resolveAddressText(CheckoutController controller, bool isGuest) {
    if (isGuest) {
      return controller.guestAddress?.address ?? controller.contactPersonAddressController.text;
    }
    final String? current = controller.address?.address;
    if (current != null && current.isNotEmpty) {
      return current;
    }
    if (address.isNotEmpty && controller.addressIndex != null && controller.addressIndex! < address.length) {
      return address[controller.addressIndex!].address ?? '';
    }
    return controller.contactPersonAddressController.text;
  }

  String _resolveName(CheckoutController controller, bool isGuest) {
    return isGuest ? guestNameTextEditingController.text : controller.contactPersonNameController.text;
  }

  String _resolvePhone(CheckoutController controller, bool isGuest) {
    return isGuest ? guestNumberTextEditingController.text : controller.contactPersonNumberController.text;
  }
}

class _LocationRow extends StatelessWidget {
  final String addressText;
  final VoidCallback onSelectAddress;
  final VoidCallback onAddNewAddress;
  final VoidCallback onEditCurrentAddress;

  const _LocationRow({
    required this.addressText,
    required this.onSelectAddress,
    required this.onAddNewAddress,
    required this.onEditCurrentAddress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = addressText.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onSelectAddress,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const _IconBadge(icon: Icons.location_on_outlined),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    children: [
                      Text('delivery_address'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                      const Spacer(),
                      Row(
                        children: [
                          Text('change'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                          Icon(Icons.arrow_forward_ios, size: 12, color: Theme.of(context).primaryColor),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEmpty ? 'set_your_delivery_location'.tr : addressText,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: isEmpty ? Theme.of(context).colorScheme.error : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onAddNewAddress,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_location_alt_outlined, size: 16, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'add_new_address'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: InkWell(
                onTap: onEditCurrentAddress,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_location_alt_outlined, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'edit_address'.tr.isNotEmpty && 'edit_address'.tr != 'edit_address' ? 'edit_address'.tr : 'Edit Address',
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContactBlock extends StatelessWidget {
  final String name;
  final String? dialCode;
  final String phone;
  final VoidCallback onEdit;
  final VoidCallback onAdd;

  const _ContactBlock({
    required this.name,
    required this.dialCode,
    required this.phone,
    required this.onEdit,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasContact = name.trim().isNotEmpty && phone.trim().isNotEmpty;
    if (!hasContact) {
      return _AddContactInfoButton(onTap: onAdd);
    }
    final String formattedPhone = (dialCode != null && dialCode!.isNotEmpty) ? '$dialCode $phone' : phone;
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const _IconBadge(icon: Icons.person_outline),
      const SizedBox(width: Dimensions.paddingSizeSmall),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
          const SizedBox(height: 2),
          Text(
            formattedPhone,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
          ),
        ]),
      ),
      const SizedBox(width: Dimensions.paddingSizeSmall),
      _EditIconButton(onTap: onEdit),
    ]);
  }
}

class _AddContactInfoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddContactInfoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_circle_outline, size: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text(
            'add_contact_info'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
        ]),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;

  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      ),
      child: Icon(icon, size: 18, color: Theme.of(context).disabledColor),
    );
  }
}

class _EditIconButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EditIconButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        child: Icon(Icons.edit_outlined, size: 18, color: Theme.of(context).primaryColor),
      ),
    );
  }
}

class _DeliveryNoteField extends StatelessWidget {
  const _DeliveryNoteField();

  void _openPicker(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      Get.dialog(const Dialog(child: DeliveryInstractionBottomSheetWidget()));
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const DeliveryInstractionBottomSheetWidget(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (controller) {
      final bool hasInstruction = controller.selectedInstruction != -1;
      final String? selectedText = hasInstruction
          ? AppConstants.deliveryInstructionList[controller.selectedInstruction].tr
          : null;

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: 'delivery_note'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            TextSpan(
              text: ' (${'optional'.tr})',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).disabledColor,
              ),
            ),
          ]),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeDefault,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                width: 0.7,
              ),
            ),
            child: Row(children: [
              Expanded(
                child: Text(
                  hasInstruction ? selectedText! : 'select_your_instruction'.tr,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: hasInstruction
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Theme.of(context).hintColor,
                  ),
                ),
              ),
              if (hasInstruction)
                GestureDetector(
                  onTap: () => controller.setInstruction(-1),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                    child: Icon(Icons.clear, size: 18, color: Theme.of(context).disabledColor),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                  child: Icon(
                    Icons.keyboard_arrow_right,
                    size: 20,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
            ]),
          ),
        ),
      ]);
    });
  }
}

class _AtmMachineOption extends StatelessWidget {
  const _AtmMachineOption();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (controller) {
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
    });
  }
}
