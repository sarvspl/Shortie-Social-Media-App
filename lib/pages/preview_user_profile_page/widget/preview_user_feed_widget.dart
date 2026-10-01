import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/feed_page/widget/feed_widget.dart' as feed_widget;
import 'package:shortie/pages/preview_user_profile_page/controller/preview_user_profile_controller.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';

class PreviewUserFeedWidget extends StatelessWidget {
  final int initialIndex;
  final PreviewUserProfileController controller;

  const PreviewUserFeedWidget({
    Key? key,
    required this.initialIndex,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Posts',
          style: TextStyle(
            color: AppColor.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.builder(
        itemCount: controller.postCollection.length,
        itemBuilder: (context, index) {
          final post = controller.postCollection[index];
          return feed_widget.PostView(
            isProfileTap: false,
            id: post.id ?? '',
            userId: post.userId ?? '',
            profileImage: post.userImage ?? '',
            postImages: post.postImage ?? [],
            title: post.name ?? '',
            subTitle: post.userName ?? '',
            time: "",
            description: post.caption ?? '',
            hastTag: post.hashTag ?? [],
            isLike: post.isLike ?? false,
            isFollow: false,
            isVerified: post.isVerified ?? false,
            likes: post.totalLikes ?? 0,
            comments: post.totalComments ?? 0,
            isFakeUser: false,
            isProfileImageBanned: post.isProfileImageBanned ?? false,
            userStory: [],
          );
        },
      ),
    );
  }
}

class PreviewUserFeedGridView extends StatelessWidget {
  final PreviewUserProfileController controller;

  const PreviewUserFeedGridView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      itemCount: controller.postCollection.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final post = controller.postCollection[index];
        return GestureDetector(
          onTap: () {
            Get.to(
              () => PreviewUserFeedWidget(
                initialIndex: index,
                controller: controller,
              ),
              transition: Transition.cupertino,
              duration: const Duration(milliseconds: 300),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(20),
                child: PreviewNetworkImageUi(
                  image: post.mainPostImage ?? '',
                ),
              ),
              if ((post.postImage?.length ?? 0) > 1)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Image.asset(
                    AppAsset.icMultipleImage,
                    color: AppColor.white,
                    width: 20,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
