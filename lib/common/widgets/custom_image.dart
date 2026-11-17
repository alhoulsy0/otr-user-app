import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/images.dart';

class CustomImage extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool isNotification;
  final String placeholder;
  final bool isHovered;
  final Color? color;
  final int? cacheWidth;
  final int? cacheHeight;
  final String? blurHash;

  const CustomImage({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.isNotification = false,
    this.placeholder = '',
    this.isHovered = false,
    this.color,
    this.cacheWidth,
    this.cacheHeight,
    this.blurHash,
  });

  static const String _defaultHash = 'L6PZfSi_.AyE_3t7t7R**0o#DgR4';

  static const List<String> _groceryHashes = [
    'L6PZfSi_.AyE_3t7t7R**0o#DgR4', // Warm grocery
    'L8O:w=~q00%MofWBoffQ00xu?bof', // Fresh produce green
    'LEHV6nWB2yk8pyo0adR*.7kCMdnj', // Cold beverages blue
    'LKO2?U%2Tw=w]~RBVZRi};RPxuwH', // Bakery warm golden
    'L9PQ=yxa00~qIUj[M{of00WB?bof', // Meat & seafood
    'LRN^r.00-;~qIUj[M{of00WB?bof', // Dairy & cheese
    'LLN^0#~q00_300xu00WB00WB?bof', // Snacks & candy
    'LKN^r.00-;~qIUj[M{of00WB?bof', // Cleaning & home
    'LGF5]+Yk^6#M@-5c,1J5@[or[Q6.', // Banners & store
  ];

  static String getHashForUrl(String url) {
    if (url.isEmpty) return _defaultHash;
    final int code = url.codeUnits.fold(0, (prev, elem) => prev + elem);
    return _groceryHashes[code % _groceryHashes.length];
  }

  @override
  Widget build(BuildContext context) {
    final String activeHash = (blurHash != null && blurHash!.isNotEmpty)
        ? blurHash!
        : getHashForUrl(image);

    final Widget blurPlaceholder = ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          BlurHash(
            hash: activeHash,
            imageFit: fit ?? BoxFit.cover,
            color: const Color(0xFFF2F2F2),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.03),
          ),
        ],
      ),
    );

    return AnimatedScale(
      scale: isHovered ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: CachedNetworkImage(
        color: color,
        imageUrl: kIsWeb ? '${AppConstants.baseUrl}/image-proxy?url=$image' : image,
        height: height,
        width: width,
        fit: fit,
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        fadeInDuration: const Duration(milliseconds: 350),
        fadeOutDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => SizedBox(
          height: height,
          width: width,
          child: blurPlaceholder,
        ),
        errorWidget: (context, url, error) => SizedBox(
          height: height,
          width: width,
          child: Stack(
            fit: StackFit.expand,
            children: [
              blurPlaceholder,
              Center(
                child: Opacity(
                  opacity: 0.35,
                  child: Image.asset(
                    placeholder.isNotEmpty
                        ? placeholder
                        : (isNotification
                            ? Images.notificationPlaceholder
                            : Images.placeholder),
                    height: height != null ? height! * 0.45 : 32,
                    width: width != null ? width! * 0.45 : 32,
                    fit: BoxFit.contain,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
