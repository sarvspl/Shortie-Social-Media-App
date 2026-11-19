import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/custom/custom_format_number.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/fake_live_page/widget/fake_send_gift_bottom_sheet_widget.dart';
import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
import 'package:shortie/pages/multi_live_page/model/pk_gift_top_user_model.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';

/// Modern PK Battle Score and Contributor Bar matching the provided reference
class ModernPkScoreBarWidget extends StatelessWidget {
  const ModernPkScoreBarWidget({
    super.key,
    required this.rank1,
    required this.rank2,
    required this.pkTimeSeconds,
    this.host1Gifters = const [],
    this.host2Gifters = const [],
  });

  final int rank1;
  final int rank2;
  final int pkTimeSeconds;
  final List<dynamic> host1Gifters;
  final List<dynamic> host2Gifters;

  String _formatTime(int seconds) {
    if (seconds <= 0) return "00:00";
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final int total = rank1 + rank2;
    final double r1 = total == 0 ? 0.5 : (rank1 / total).clamp(0.15, 0.85);
    final double r2 = 1.0 - r1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 1. The Main PK Battle Bar ──────────────────────────────────────
        Container(
          height: 32,
          width: Get.width,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  // Left Side: Pink/Magenta Gradient (Host 1)
                  Expanded(
                    flex: (r1 * 100).toInt(),
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.only(left: 12),
                      alignment: Alignment.centerLeft,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFFFF4081)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Text(
                        "$rank1",
                        style: AppFontStyle.styleW900(Colors.white, 16),
                      ),
                    ),
                  ),

                  // Right Side: Cyan/Electric Blue Gradient (Host 2)
                  Expanded(
                    flex: (r2 * 100).toInt(),
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.only(right: 12),
                      alignment: Alignment.centerRight,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFF0091EA)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Text(
                        "$rank2",
                        style: AppFontStyle.styleW900(Colors.white, 16),
                      ),
                    ),
                  ),
                ],
              ),

              // Center Capsule Badge: "PK 01:33"
              Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E0A3C), Color(0xFF2C1052)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amberAccent, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "PK",
                      style: AppFontStyle.styleW900(Colors.amberAccent, 12),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatTime(pkTimeSeconds),
                      style: AppFontStyle.styleW700(Colors.white, 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── 2. Top Gifter / Contributor Avatars Under the Bar ──────────────
        Container(
          height: 38,
          width: Get.width,
          color: Colors.black.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Host Gifters (1, 2, 3)
              Row(
                children: List.generate(3, (index) {
                  final String? image = (index < host1Gifters.length)
                      ? _extractGifterImage(host1Gifters[index])
                      : null;
                  return _buildGifterAvatar(
                    rank: index + 1,
                    image: image,
                    isLeft: true,
                  );
                }),
              ),

              // Right Host Gifters (1, 2, 3)
              Row(
                children: List.generate(3, (index) {
                  final String? image = (index < host2Gifters.length)
                      ? _extractGifterImage(host2Gifters[index])
                      : null;
                  return _buildGifterAvatar(
                    rank: index + 1,
                    image: image,
                    isLeft: false,
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _extractGifterImage(dynamic item) {
    if (item == null) return null;
    if (item is TopGifter) return item.userId?.image;
    if (item is Map) return item["image"] ?? item["userImage"];
    try {
      return item.userId?.image ?? item.image;
    } catch (_) {
      return null;
    }
  }

  Widget _buildGifterAvatar({required int rank, String? image, required bool isLeft}) {
    final Color badgeColor = rank == 1
        ? const Color(0xFFFFD700)
        : (rank == 2 ? const Color(0xFFC0C0C0) : const Color(0xFFCD7F32));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 28,
            width: 28,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: badgeColor, width: 1.2),
              color: isLeft ? const Color(0xFFE91E63).withValues(alpha: 0.3) : const Color(0xFF00E5FF).withValues(alpha: 0.3),
            ),
            child: (image != null && image.isNotEmpty)
                ? CustomPreviewImage(image: image, fit: BoxFit.cover)
                : Icon(
                    Icons.card_giftcard,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 14,
                  ),
          ),
          Positioned(
            bottom: -3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "$rank",
                style: AppFontStyle.styleW800(Colors.black, 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal Quick Gifts Row above bottom controls (as seen in image 1)
class ModernQuickGiftBarWidget extends StatelessWidget {
  const ModernQuickGiftBarWidget({super.key, required this.onSendGift});

  final Function(int coins, String giftName) onSendGift;

  static const List<Map<String, dynamic>> _quickGifts = [
    {"name": "Sports Car", "coins": 50000, "label": "50 K", "icon": "🏎️"},
    {"name": "Dragon", "coins": 40000, "label": "40 K", "icon": "🐉"},
    {"name": "Rocket", "coins": 25000, "label": "25 K", "icon": "🚀"},
    {"name": "Super Ring", "coins": 5000, "label": "5 K", "icon": "💍"},
    {"name": "Crown", "coins": 25000, "label": "25 K", "icon": "👑"},
    {"name": "Hawk", "coins": 30000, "label": "30 K", "icon": "🦅"},
    {"name": "Castle", "coins": 100000, "label": "100 K", "icon": "🏰"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: Get.width,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: _quickGifts.length,
        itemBuilder: (context, index) {
          final item = _quickGifts[index];
          return GestureDetector(
            onTap: () => onSendGift(item["coins"] as int, item["name"] as String),
            child: Container(
              width: 58,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item["icon"] as String, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppAsset.icCoin, width: 11, height: 11),
                      const SizedBox(width: 2),
                      Text(
                        item["label"] as String,
                        style: AppFontStyle.styleW700(Colors.amberAccent, 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// SVIP / VIP Chat Bubble Card (as seen in image 1)
class ModernVipChatBubble extends StatelessWidget {
  const ModernVipChatBubble({
    super.key,
    required this.userName,
    required this.message,
    this.userImage,
    this.isEntrance = false,
  });

  final String userName;
  final String message;
  final String? userImage;
  final bool isEntrance;

  @override
  Widget build(BuildContext context) {
    if (isEntrance) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF7B1FA2).withValues(alpha: 0.85),
              const Color(0xFF4A148C).withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purpleAccent, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text("SVIP", style: AppFontStyle.styleW900(Colors.black, 9)),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.purple.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text("Lv11", style: AppFontStyle.styleW800(Colors.white, 9)),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFontStyle.styleW700(Colors.white, 12),
              ),
            ),
          ],
        ),
      );
    }

    // Glowing VIP Chat Bubble
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF004D40).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00E676), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withValues(alpha: 0.25),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text("A", style: AppFontStyle.styleW900(Colors.black, 9)),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFF8E24AA),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text("SVIP", style: AppFontStyle.styleW900(Colors.white, 9)),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFF1DE9B6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text("Lv26", style: AppFontStyle.styleW800(Colors.black, 8)),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              "$userName: $message",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFontStyle.styleW600(Colors.white, 12),
            ),
          ),
        ],
      ),
    );
  }
}
