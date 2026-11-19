import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/custom/custom_format_number.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/feed_page/controller/feed_controller.dart';
import 'package:shortie/pages/feed_page/model/fetch_popular_user_model.dart';
import 'package:shortie/pages/multi_live_page/view/multi_live_page_view.dart';
import 'package:shortie/pages/stream_page/model/fetch_live_user_model.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/utils.dart';

class FeedSectionTabBar extends StatelessWidget {
  const FeedSectionTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedController>(
      id: "onSectionChange",
      builder: (controller) {
        return Container(
          width: Get.width,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColor.white,
            border: Border(
              bottom: BorderSide(color: AppColor.colorBorder.withValues(alpha: 0.5), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(
                title: "Popular",
                index: 0,
                isSelected: controller.selectedSection == 0,
                onTap: () => controller.onChangeSection(0),
              ),
              _buildTabItem(
                title: "Feed",
                index: 1,
                isSelected: controller.selectedSection == 1,
                onTap: () => controller.onChangeSection(1),
              ),
              _buildTabItem(
                title: "PK Matches",
                index: 2,
                isSelected: controller.selectedSection == 2,
                onTap: () => controller.onChangeSection(2),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabItem({
    required String title,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              title,
              style: isSelected
                  ? AppFontStyle.styleW700(AppColor.primary, 16)
                  : AppFontStyle.styleW500(AppColor.colorTextGrey, 15),
            ),
          ),
          const SizedBox(height: 2),
          // Stylish underline indicator (similar to cyan wave indicator in user reference)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 3,
            width: isSelected ? 40 : 0,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(colors: [Color(0xFF00E5FF), AppColor.primary])
                  : null,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class PopularUserCard extends StatelessWidget {
  const PopularUserCard({super.key, required this.user});

  final PopularUser user;

  @override
  Widget build(BuildContext context) {
    final int score = (user.receivedCoin ?? 0) > 0
        ? user.receivedCoin!
        : ((user.receivedGift ?? 0) > 0 ? (user.receivedGift! * 250) : (user.coin ?? 1200));

    return GestureDetector(
      onTap: () => _openPkMatch(context),
      child: Container(
        height: 220,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // User Image
            CustomPreviewImage(
              image: user.image,
              isProfileImage: false,
              fit: BoxFit.cover,
            ),

            // Top Badges (PK on left, Rising Star on right)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF5252), Color(0xFFFF7A00)]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on, color: Colors.white, size: 11),
                    const SizedBox(width: 2),
                    Text("PK", style: AppFontStyle.styleW800(Colors.white, 10)),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B0FF).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 11),
                    const SizedBox(width: 3),
                    Text("Rising Star", style: AppFontStyle.styleW700(Colors.white, 9)),
                  ],
                ),
              ),
            ),

            // Bottom Gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Bottom Info (Name on left, gifts/coins on right)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text("🔥", style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            user.name ?? user.userName ?? "User",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.styleW700(Colors.white, 12),
                          ),
                        ),
                        if (user.isVerified ?? false) const SizedBox(width: 3),
                        if (user.isVerified ?? false)
                          const Icon(Icons.verified, color: Color(0xFF29B6F6), size: 13),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${CustomFormatNumber.convert(score)}",
                      style: AppFontStyle.styleW700(Colors.white, 11),
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

  void _openPkMatch(BuildContext context) {
    if (user.liveHistoryId != null && user.liveHistoryId!.isNotEmpty) {
      if (user.isFake == true) {
        Get.toNamed(AppRoutes.fakeLivePage, arguments: {
          "isHost": false,
          "isFollow": false,
          "roomId": user.liveHistoryId ?? "",
          "userId": user.id ?? "",
          "userName": user.userName ?? "",
          "name": user.name ?? "",
          "image": user.image ?? "",
          "videoUrl": "",
          "host2Image": user.image ?? "",
          "host2VideoUrl": "",
          "isPkMode": true,
        });
      } else {
        Get.to(
          MultiLivePageView(
            userId: user.id ?? "",
            liveUserObjId: user.liveUserObjId ?? "",
            liveHistoryId: user.liveHistoryId ?? "",
            isHost: false,
          ),
        );
      }
    } else {
      Get.toNamed(AppRoutes.fakeLivePage, arguments: {
        "isHost": false,
        "isFollow": false,
        "roomId": "pk_${user.id ?? "room"}",
        "userId": user.id ?? "",
        "userName": user.userName ?? "",
        "name": user.name ?? "",
        "image": user.image ?? "",
        "videoUrl": "",
        "host2Image": user.image ?? "",
        "host2VideoUrl": "",
        "isPkMode": true,
      });
    }
  }
}

class PkMatchCard extends StatelessWidget {
  const PkMatchCard({super.key, required this.liveData});

  final LiveUserList liveData;

  @override
  Widget build(BuildContext context) {
    final List pkImages = liveData.pkPreviewImages ?? [];

    return GestureDetector(
      onTap: () => _openPkLive(context),
      child: Container(
        height: 220,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Preview Image(s)
            (pkImages.length >= 2)
                ? Row(
                    children: [
                      Expanded(
                        child: CustomPreviewImage(
                          image: pkImages[0],
                          isProfileImage: false,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(width: 1, color: Colors.white24),
                      Expanded(
                        child: CustomPreviewImage(
                          image: pkImages[1],
                          isProfileImage: false,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  )
                : CustomPreviewImage(
                    image: (pkImages.isNotEmpty) ? pkImages[0] : (liveData.image ?? liveData.videoImage),
                    isProfileImage: false,
                    fit: BoxFit.cover,
                  ),

            // Top Badges (PK on left, Rising Star on right)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF5252), Color(0xFFFF7A00)]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on, color: Colors.white, size: 11),
                    const SizedBox(width: 2),
                    Text("PK", style: AppFontStyle.styleW800(Colors.white, 10)),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B0FF).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 11),
                    const SizedBox(width: 3),
                    Text("Rising Star", style: AppFontStyle.styleW700(Colors.white, 9)),
                  ],
                ),
              ),
            ),

            // Bottom Gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Bottom Info
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      liveData.name ?? liveData.userName ?? "PK Streamer",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontStyle.styleW700(Colors.white, 12),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${CustomFormatNumber.convert(liveData.view ?? 3400)}",
                      style: AppFontStyle.styleW700(Colors.white, 11),
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

  void _openPkLive(BuildContext context) {
    if (liveData.isFake == true) {
      final List pkImages = liveData.pkPreviewImages ?? [];
      final List pkVideoUrl = liveData.pkMediaSources ?? [];

      Get.toNamed(AppRoutes.fakeLivePage, arguments: {
        "isHost": false,
        "isFollow": liveData.isFollow ?? false,
        "roomId": liveData.liveHistoryId ?? "",
        "userId": liveData.userId ?? "",
        "userName": liveData.userName ?? "",
        "name": liveData.name ?? "",
        "image": pkImages.isNotEmpty ? pkImages[0] : (liveData.videoImage ?? liveData.image ?? ""),
        "videoUrl": pkVideoUrl.isNotEmpty ? pkVideoUrl[0] : (liveData.videoUrl ?? ""),
        "host2Image": pkImages.length >= 2 ? pkImages[1] : (liveData.host2Image ?? liveData.image ?? ""),
        "host2VideoUrl": pkVideoUrl.length >= 2 ? pkVideoUrl[1] : (liveData.videoUrl ?? ""),
        "isPkMode": true,
      });
    } else {
      Get.to(
        MultiLivePageView(
          userId: liveData.userId ?? "",
          liveUserObjId: liveData.liveUserObjId ?? "",
          liveHistoryId: liveData.liveHistoryId ?? "",
          isHost: false,
        ),
      );
    }
  }
}
