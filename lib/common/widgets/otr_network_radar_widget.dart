import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Live Radar Capsule showing 24/7 Supermarket delivery status in Irbid.
/// Tapping opens an informative bottom sheet explaining the 3 branches and smart auto-routing.
class OtrNetworkRadarWidget extends StatefulWidget {
  const OtrNetworkRadarWidget({super.key});

  @override
  State<OtrNetworkRadarWidget> createState() => _OtrNetworkRadarWidgetState();
}

class _OtrNetworkRadarWidgetState extends State<OtrNetworkRadarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showNetworkModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Modal Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A859).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: Color(0xFF00A859),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OTR Supermarket Network'.tr,
                        style: robotoBold.copyWith(
                          fontSize: 18,
                          color: const Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '3 Branches in Irbid • 24/7 Express Delivery'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Smart Auto-Routing Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0FDF4), Color(0xFFE8F5E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00A859).withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.lightbulb_fill,
                    color: Color(0xFF00A859),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1 Unified Basket • Smart Auto-Routing'.tr,
                          style: robotoBold.copyWith(
                            fontSize: 13,
                            color: const Color(0xFF008746),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Shop our full 70,000+ catalog in one single basket. Our smart system automatically fulfills and dispatches your order from the nearest branch for lightning-fast arrival (~18-25 mins).'
                              .tr,
                          style: robotoRegular.copyWith(
                            fontSize: 11.5,
                            color: const Color(0xFF2D3748),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Our Active Branches in Irbid'.tr,
              style: robotoBold.copyWith(
                fontSize: 14,
                color: const Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 10),

            // Branch 1
            _buildBranchTile(
              name: 'University Street Branch (شارع الجامعة)'.tr,
              badge: '24/7 Open • Fast Dispatch'.tr,
              desc: 'Central Irbid & Yarmouk University Zone'.tr,
            ),
            const SizedBox(height: 8),

            // Branch 2
            _buildBranchTile(
              name: 'Abu Rashid Street Branch (شارع أبو راشد)'.tr,
              badge: '24/7 Open • Fresh Goods Hub'.tr,
              desc: 'Daily bakery, dairy & produce fulfillment'.tr,
            ),
            const SizedBox(height: 8),

            // Branch 3
            _buildBranchTile(
              name: 'Yarmouk Roundabout Branch (دوار اليرموك)'.tr,
              badge: '24/7 Open • Mega Supermarket'.tr,
              desc: 'Complete 70,000+ grocery catalog'.tr,
            ),
            const SizedBox(height: 20),

            // Got it button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A859),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Explore Supermarket'.tr,
                  style: robotoBold.copyWith(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchTile({
    required String name,
    required String badge,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF00A859).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xFF00A859),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: robotoBold.copyWith(
                          fontSize: 12.5,
                          color: const Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: robotoRegular.copyWith(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF00A859).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '24/7'.tr,
              style: robotoBold.copyWith(
                color: const Color(0xFF00A859),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showNetworkModal(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF00A859).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00A859).withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _pulseScale,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00A859),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00A859),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              '24/7 LIVE • 3 Irbid Branches • ~18m ETA'.tr,
              style: robotoMedium.copyWith(
                fontSize: 11,
                color: const Color(0xFF008746),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.info_outline_rounded,
              size: 13,
              color: Color(0xFF008746),
            ),
          ],
        ),
      ),
    );
  }
}
