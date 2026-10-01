import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/feed_page/model/post_image_model.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/utils.dart';

class PreviewFullScreenImageWidget extends StatefulWidget {
  const PreviewFullScreenImageWidget({super.key, required this.posts, required this.initialIndex});

  final List<PostImage>? posts;
  final int initialIndex;

  @override
  State<PreviewFullScreenImageWidget> createState() => _PreviewFullScreenImageWidgetState();
}

class _PreviewFullScreenImageWidgetState extends State<PreviewFullScreenImageWidget> {
  PageController _controller = PageController();

  num currentPage = 0;

  double dragStartPosition = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
    currentPage = widget.initialIndex;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onHandleDragStart({required DragStartDetails details}) {
    try {
      dragStartPosition = details.globalPosition.dy;
    } catch (e) {
      Utils.showLog("onHandleDragStart Error => $e");
    }
  }

  void onHandleDragUpdate({required DragUpdateDetails details, required BuildContext context}) {
    try {
      final currentPosition = details.globalPosition.dy;
      final delta = currentPosition - dragStartPosition;

      if (delta > 20) {
        Get.back();
      } else if (delta < -20) {
        Get.back();
      }
    } catch (e) {
      Utils.showLog("onHandleDragUpdate Error => $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light, delay: 300);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.posts?.length,
            onPageChanged: (value) {
              currentPage = value;
              setState(() {});
            },
            itemBuilder: (context, index) {
              PostImage? post = widget.posts?[index];
              return GestureDetector(
                onVerticalDragStart: (details) => onHandleDragStart(details: details),
                onVerticalDragUpdate: (details) => onHandleDragUpdate(details: details, context: context),
                child: SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: PreviewPostImageWidget(
                      image: post?.url,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColor.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 30,
            child: Visibility(
              visible: widget.posts!.length >= 2,
              child: DotsIndicator(
                dotsCount: widget.posts!.length,
                position: currentPage.toDouble(),
                decorator: DotsDecorator(
                  color: AppColor.coloGreyText,
                  activeColor: AppColor.white,
                  size: const Size.square(8),
                  activeSize: const Size(20, 8),
                  spacing: EdgeInsets.all(3),
                  activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
