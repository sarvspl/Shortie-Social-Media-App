import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/fake_live_page/controller/fake_live_controller.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';

class FakePkTimerWidget extends StatefulWidget {
  @override
  State<FakePkTimerWidget> createState() => _PkTimerWidgetState();
}

class _PkTimerWidgetState extends State<FakePkTimerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // starts from above
      end: const Offset(0, 0), // slides into place
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FakeLiveController>(
      id: "onChangePkTime",
      builder: (controller) {
        return Visibility(
          visible: controller.pkCountTime != 0,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              // Slide-in Super Timer

              // PK Timer (always visible)
              Container(
                height: 25,
                width: 100,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColor.black,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppAsset.img_pk_time_icon, width: 22),
                    const SizedBox(width: 8),
                    Text(
                      controller.onConvertSecondToHMS(controller.pkCountTime),
                      style: AppFontStyle.styleW600(AppColor.white, 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // isShowMultiplier
        );
      },
    );
  }
}
