// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shortie/main.dart';
// import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
// import 'package:shortie/utils/asset.dart';
// import 'package:shortie/utils/color.dart';
// import 'package:shortie/utils/font_style.dart';
//
// class PkTimerWidget extends StatefulWidget {
//   @override
//   State<PkTimerWidget> createState() => _PkTimerWidgetState();
// }
//
// class _PkTimerWidgetState extends State<PkTimerWidget> with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<Offset> _slideAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _animationController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: Offset.zero, // Starts from above
//       end: const Offset(0, 0.8), // Slides to normal position
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutBack,
//     ));
//   }
//
//   @override
//   void didChangeDependencies() {
//     final controller = Get.find<MultiLiveController>();
//     if (controller.pkSuperCountTime > 0) {
//       _animationController.forward(); // Trigger animation when super timer starts
//     } else {
//       _animationController.reverse(); // Hide if needed
//     }
//     super.didChangeDependencies();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<MultiLiveController>(
//       id: "onChangePkTime",
//       builder: (controller) {
//         if (controller.pkSuperCountTime > 0) {
//           _animationController.forward();
//         } else {
//           _animationController.reverse();
//         }
//
//         return Visibility(
//           visible: controller.pkCountTime != 0,
//           child: Stack(
//             alignment: Alignment.topCenter,
//             clipBehavior: Clip.none,
//             children: [
//               // Slide-in Super Timer (behind)
//               SlideTransition(
//                 position: _slideAnimation,
//                 child: Container(
//                   height: 25,
//                   width: 75,
//                   alignment: Alignment.center,
//                   decoration: const BoxDecoration(
//                     color: AppColor.colorTextRed,
//                     borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(10),
//                       bottomRight: Radius.circular(10),
//                     ),
//                   ),
//                   child: Text(
//                     controller.onConvertSecondToMS(controller.pkSuperCountTime),
//                     style: AppFontStyle.styleW800(AppColor.white, 14),
//                   ),
//                 ),
//               ),
//
//               // Actual PK Timer
//               Container(
//                 height: 25,
//                 width: 100,
//                 alignment: Alignment.center,
//                 decoration: const BoxDecoration(
//                   color: AppColor.black,
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(10),
//                     bottomRight: Radius.circular(10),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset(AppAsset.img_pk_time_icon, width: 22),
//                     const SizedBox(width: 8),
//                     Text(
//                       controller.onConvertSecondToHMS(controller.pkCountTime),
//                       style: AppFontStyle.styleW600(AppColor.white, 12),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';

class PkTimerWidget extends StatefulWidget {
  @override
  State<PkTimerWidget> createState() => _PkTimerWidgetState();
}

class _PkTimerWidgetState extends State<PkTimerWidget> with SingleTickerProviderStateMixin {
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
    return GetBuilder<MultiLiveController>(
      id: "onChangePkTime",
      builder: (controller) {
        // Trigger animation based on logic
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (controller.pkCountTime <= controller.pkSuperCountTime && controller.pkSuperCountTime > 0) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        });

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
