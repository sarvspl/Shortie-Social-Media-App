import 'package:flutter/material.dart';
//
// class PreviewLiveScrollWidget extends StatefulWidget {
//   const PreviewLiveScrollWidget({super.key, required this.initialIndex});
//
//   final int initialIndex;
//
//   @override
//   State<PreviewLiveScrollWidget> createState() => _PreviewLiveScrollWidgetState();
// }
//
// class _PreviewLiveScrollWidgetState extends State<PreviewLiveScrollWidget> {
//   late int _currentActiveIndex;
//   final double _pageVisibilityThreshold = 0.8; // 80% visibility required
//   PageController _pageController = PageController();
//
//   @override
//   void initState() {
//     super.initState();
//
//     Utils.showLog("widget.initialIndex ::  ${widget.initialIndex}");
//     _currentActiveIndex = widget.initialIndex;
//     Utils.showLog("widget.initialIndex :: _currentActiveIndex  ${_currentActiveIndex}");
//     _pageController = PageController(initialPage: widget.initialIndex);
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   bool _shouldUpdateActiveIndex(double page) {
//     final currentPage = page.floor();
//     final nextPage = currentPage + 1;
//     final progress = page - currentPage;
//
//     // If scrolling forward
//     if (progress > 0) {
//       // Current page is becoming less visible
//       if (1 - progress < _pageVisibilityThreshold) {
//         return true; // Switch to next page
//       }
//     }
//     // If scrolling backward
//     else if (progress < 0) {
//       // Next page is becoming less visible
//       if (progress.abs() < _pageVisibilityThreshold) {
//         return true; // Switch back to current page
//       }
//     }
//     return false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<StreamController>(
//       id: "onChangeLiveUsers",
//       builder: (controller) {
//         return NotificationListener<ScrollNotification>(
//           onNotification: (notification) {
//             if (notification is ScrollUpdateNotification) {
//               final page = _pageController.page ?? 0;
//               if (_shouldUpdateActiveIndex(page)) {
//                 final newIndex = page.round();
//                 if (newIndex != _currentActiveIndex) {
//                   _currentActiveIndex = newIndex;
//                   if (mounted) setState(() {});
//                 }
//               }
//             }
//             return false;
//           },
//           child: PageView.builder(
//             itemCount: controller.liveUsers.length,
//             scrollDirection: Axis.vertical,
//             controller: _pageController,
//             physics: const ClampingScrollPhysics(),
//             onPageChanged: (index) {
//               // Fallback if scroll detection fails
//               if (_currentActiveIndex != index) {
//                 _currentActiveIndex = index;
//                 if (mounted) setState(() {});
//               }
//             },
//             itemBuilder: (context, index) {
//               return KeepAliveWrapper(
//                 child: MultiLivePageView(
//                   isActive: index == _currentActiveIndex,
//                   liveUserList: controller.liveUsers[index],
//                   isHost: false,
//                   currentActivePage: _currentActiveIndex,
//                   pageIndex: index,
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

// old code snippet for reference

// return
//   PageView.builder(
//   itemCount: controller.liveUsers.length,
//   scrollDirection: Axis.vertical,
//   controller: PageController(initialPage: widget.initialIndex),
//   physics: const ClampingScrollPhysics(),
//   onPageChanged: (index) {
//     setState(() => currentPageIndex = index); // Update index on scroll
//   },
//   itemBuilder: (context, index) {
//     return MultiLivePageView(
//       liveUserList: controller.liveUsers[index],
//       isHost: false,
//       isActive: index == currentPageIndex,
//     );
//   },
// );
