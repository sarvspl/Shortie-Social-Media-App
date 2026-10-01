import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/custom/custom_format_number.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
import 'package:shortie/pages/multi_live_page/model/pk_gift_top_user_model.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/ui/preview_profile_bottom_sheet_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/socket_services.dart';
import 'package:shortie/utils/utils.dart';

class ViewersBottomSheet extends StatefulWidget {
  ViewersBottomSheet({super.key, this.initialIndex});
  int? initialIndex;
  @override
  _ViewersBottomSheetState createState() => _ViewersBottomSheetState();
}

class _ViewersBottomSheetState extends State<ViewersBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List viewers = [];
  List<PkGiftTopUserModel> topGiftUser = [];

  late MultiLiveController controller;

  @override
  void initState() {
    if (Get.isRegistered<MultiLiveController>()) {
      controller = Get.find<MultiLiveController>();
      topGiftUser = controller.totalGiftUserData;
    } else {
      // You would need to implement proper initialization here
      // This is just an example - adapt to your app's architecture
      controller = Get.put(MultiLiveController());
      Utils.showLog("MultiLiveController recreated for socket connection");
      topGiftUser = controller.totalGiftUserData;
    }
    viewers = SocketServices.liveViewers;

    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex ?? 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Tab Bar
              Container(
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColor.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppColor.black,
                        dividerColor: AppColor.transparent,
                        labelStyle: AppFontStyle.styleW400(AppColor.black, 14),
                        tabs: [
                          Tab(text: 'Viewers'),
                          Tab(text: 'Top Gifter'),
                        ],
                      ),
                    ),
                    5.width,
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildViewersList(),
                    _buildTopGifterList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildViewersList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: viewers.length,
      itemBuilder: (context, index) {
        final viewer = viewers[index];
        return _buildViewerItem(viewer);
      },
    );
  }

  Widget _buildTopGifterList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: topGiftUser.length,
      itemBuilder: (context, index) {
        return _buildGiftUserItem(topGiftUser[index], index);
      },
    );
  }

  Widget _buildViewerItem(indexData) {
    return GestureDetector(
      onTap: () {
        Utils.showLog("Tapped on viewer: ${indexData}");
        // Handle tap on the viewer item
        if (indexData['userId'] != Database.loginUserId) {
          PreviewProfileBottomSheetUi.show(
            context: context,
            userId: indexData['userId'],
          );
        } else {
          final bottomBarController = Get.find<BottomBarController>();
          bottomBarController.onChangeBottomBar(4);
        }
        Utils.showLog("Tapped on viewer: ${indexData['name']}");
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 4,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100], // Light background color
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300] ?? Colors.yellow),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: (indexData['image']?.isEmpty ?? true)
                  ? Icon(Icons.person, color: Colors.grey[600])
                  : ClipOval(
                      child: PreviewNetworkImageUi(
                        image: indexData['image'],
                      ),
                    ),
            ),

            12.width,

            // Name and badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    indexData['name'] ?? "Unknown",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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

  Widget _buildGiftUserItem(PkGiftTopUserModel indexData, int rankIndex) {
    // Background colors for top 3
    Color? backgroundColor;
    if (rankIndex == 0)
      backgroundColor = Colors.amber.withValues(alpha:0.2);
    else if (rankIndex == 1)
      backgroundColor = Colors.grey.withValues(alpha:0.2);
    else if (rankIndex == 2) backgroundColor = Colors.brown.withValues(alpha:0.2);

    // Border colors for top 3
    Color borderColor;
    if (rankIndex == 0)
      borderColor = Colors.amber.shade300;
    else if (rankIndex == 1)
      borderColor = Colors.grey.shade300;
    else if (rankIndex == 2)
      borderColor = Colors.brown.shade300;
    else
      borderColor = Colors.grey[300]!; // Default border for others

    return GestureDetector(
      onTap: () {
        // Handle tap on the gift user item
        if (indexData.userId?.id != Database.loginUserId) {
          PreviewProfileBottomSheetUi.show(
            context: context,
            userId: indexData.userId?.id ?? "",
          );
        } else {
          final bottomBarController = Get.find<BottomBarController>();
          bottomBarController.onChangeBottomBar(4);
        }
        Utils.showLog("Tapped on gift user: ${indexData.userId?.name}");
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Rank number
            Text(
              "${rankIndex + 1}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: rankIndex < 3 ? Colors.deepOrange : Colors.black,
              ),
            ),
            SizedBox(width: 12),

            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: indexData.userId?.image?.isEmpty ?? true
                  ? Icon(Icons.person, color: Colors.grey[600])
                  : ClipOval(
                      child: PreviewNetworkImageUi(
                        image: indexData.userId?.image ?? "",
                      ),
                    ),
            ),
            SizedBox(width: 12),

            // Name
            Expanded(
              child: Text(
                indexData.userId?.name ?? "Unknown",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),

            Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColor.colorPendingYellow.withAlpha(52),
              ),
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              // width: 80,

              child: Row(
                children: [
                  Image.asset(
                    AppAsset.icCoin,
                    width: 20,
                    height: 20,
                  ),
                  5.width,
                  Text(
                    CustomFormatNumber.convert(indexData.totalCoins ?? 0),
                    style: AppFontStyle.styleW600(AppColor.colorPendingYellow, 14),
                  ),
                  5.width
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ViewerModel {
  final String name;
  final String avatar;
  final int level;
  final String badge;
  final Color badgeColor;
  final bool isVerified;
  final bool isVip;
  final String? specialTag;
  final String? specialIcon;

  ViewerModel({
    required this.name,
    required this.avatar,
    required this.level,
    this.badge = '',
    required this.badgeColor,
    this.isVerified = false,
    this.isVip = false,
    this.specialTag,
    this.specialIcon,
  });
}
