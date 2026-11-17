import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class CustomButton extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final double radius;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final bool isBold;
  final bool isBorder;
  final Color? iconColor;
  final TextStyle? textStyle;
  const CustomButton({super.key, this.onPressed, required this.buttonText, this.transparent = false, this.margin, this.width, this.height,
    this.fontSize, this.radius = 30, this.icon, this.color, this.textColor, this.isLoading = false, this.isBold = true, this.isBorder = false, this.iconColor, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).primaryColor;
    final isEnabled = onPressed != null && !isLoading;
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: !isEnabled ? const Color(0xff93A2AE) : (transparent ? Colors.transparent : effectiveColor),
      foregroundColor: transparent ? effectiveColor : Colors.white,
      minimumSize: Size(width != null ? width! : Dimensions.webMaxWidth, height != null ? height! : 50),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      elevation: (isEnabled && !transparent && !isBorder) ? 1.5 : 0,
      shadowColor: (isEnabled && !transparent) ? effectiveColor.withValues(alpha: 0.35) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: isBorder ? BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)) : BorderSide.none,
      ),
    );

    return Center(
      child: SizedBox(
        width: width ?? Dimensions.webMaxWidth,
        child: Padding(
          padding: margin ?? EdgeInsets.zero,
          child: TextButton(
            onPressed: isEnabled ? onPressed as void Function()? : null,
            style: flatButtonStyle,
            child: isLoading
                ? Center(
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const SizedBox(
                        height: 16, width: 16,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.2,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Text('loading'.tr, style: robotoMedium.copyWith(color: Colors.white)),
                    ]),
                  )
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (icon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                        child: Icon(icon, size: (fontSize ?? Dimensions.fontSizeLarge) + 2, color: iconColor ?? (transparent ? effectiveColor : Theme.of(context).cardColor)),
                      ),
                    Flexible(
                      child: Text(
                        buttonText,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle ?? (isBold ? robotoBold : robotoRegular).copyWith(
                          color: textColor ?? (transparent ? effectiveColor : Colors.white),
                          fontSize: fontSize ?? Dimensions.fontSizeLarge,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ]),
          ),
        ),
      ),
    );
  }
}
