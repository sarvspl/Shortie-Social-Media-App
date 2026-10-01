import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:story_view/story_view.dart' as s;
import 'package:story_view/story_view.dart';

/// your app deps (already used in your current views/controllers)
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/utils.dart';
import 'package:shortie/utils/database.dart';

import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/ui/circle_icon_button_ui.dart';

import 'package:shortie/pages/story_page/widget/story_item_widget.dart'
    show onStoryItem;
import 'package:shortie/pages/story_page/widget/story_data_format.dart';

import 'package:shortie/pages/story_page/bottom_sheet/reaction_bottom_sheet_ui.dart';
import 'package:shortie/pages/story_page/bottom_sheet/viewers_bottom_sheet_ui.dart';
import 'package:shortie/pages/story_page/api/send_comment_to_story_api.dart';
import 'package:shortie/pages/story_page/api/create_view_story_history_api.dart';
import 'package:shortie/pages/story_page/api/delete_story_api.dart';
import 'package:shortie/pages/story_page/Dialog/delete_story_dialog_ui.dart';
import 'package:shortie/ui/loading_ui.dart';

import 'package:shortie/pages/story_page/model/fetch_story_model.dart'; // StoryGroup, Stories, User model
import 'package:shortie/pages/chat_page/model/fetch_user_chat_model.dart'; // Chat

/// ------------------------------------------------------------
/// Public API: openers (no nullable Future issue; we await Get.to<void>())
/// ------------------------------------------------------------
class StoryViewer {
  /// Others’ stories: pass your `List<StoryGroup>`
  static Future<void> openOthers({
    required List<StoryGroup> groups,
    int initialGroupIndex = 0,
  }) async {
    await Get.to<void>(
        () => _OthersDeck(groups: groups, initialPage: initialGroupIndex));
  }

  /// Your own stories: pass your `List<Stories>`
  static Future<void> openOwn({
    required List<Stories> stories,
    int initialIndex = 0,
  }) async {
    await Get.to<void>(
        () => _OwnGroup(stories: stories, initialIndex: initialIndex));
  }

  /// Single story (e.g., from chat item)
  static Future<void> openSingle({required Chat chat}) async {
    await Get.to<void>(() => _SingleStory(chat: chat));
  }
}

/// ------------------------------------------------------------
/// OTHERS DECK  (PageView across users; each page is StoryView)
/// ------------------------------------------------------------

///
class _OthersDeck extends StatefulWidget {
  const _OthersDeck({required this.groups, required this.initialPage});
  final List<StoryGroup> groups;
  final int initialPage;

  @override
  State<_OthersDeck> createState() => _OthersDeckState();
}

class _OthersDeckState extends State<_OthersDeck> {
  final s.StoryController _story = s.StoryController();
  late final PageController _page = PageController(
      initialPage: widget.initialPage.clamp(0, widget.groups.length - 1));

  final TextEditingController _comment = TextEditingController();

  int _pageIndex = 0; // group idx
  int _storyIndex = 0; // story idx inside group
  double _dragStartY = 0;
  bool _keyboardUp = false;
  bool _isLongPressing = false;
  bool _isPotentialLongPress = false;
  Timer? _tapTimer;
  late final List<List<StoryItem>> _itemsPerGroup;
  @override
  void initState() {
    super.initState();
    _pageIndex = widget.initialPage.clamp(0, widget.groups.length - 1);
    // Build once and keep object identities stable
    _itemsPerGroup = widget.groups.map((g) {
      final list = g.stories ?? const <Stories>[];
      return list
          .map((e) => onStoryItem(controller: _story, itemData: e))
          .toList();
    }).toList();
  }

  @override
  void dispose() {
    _page.dispose();
    _story.dispose();
    _comment.dispose();
    _tapTimer?.cancel(); // Add this
    super.dispose();
  }

  void _maybeCreateViewHistory() async {
    final group = widget.groups[_pageIndex];
    final stories = group.stories ?? const <Stories>[];
    if (_storyIndex < stories.length) {
      final st = stories[_storyIndex];
      if (st.isView == false) {
        await CreateViewStoryHistoryApi.callApi(
          loginUserId: Database.loginUserId,
          storyId: st.id ?? "",
        );
      }
    }
  }

  void _sendComment() async {
    final text = _comment.text.trim();
    if (text.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();

    Get.dialog(PopScope(canPop: false, child: const LoadingUi()),
        barrierDismissible: false);
    try {
      final st = widget.groups[_pageIndex].stories?[_storyIndex];
      await SendCommentToStoryApi.callApi(
        loginUserId: Database.loginUserId,
        storyId: st?.id ?? "",
        message: text,
      );
    } finally {
      Get.back();
    }
    _comment.clear();
    Utils.showToast("Comment Send To Story");
  }

  void _reaction(BuildContext context) {
    _story.pause();
    final st = widget.groups[_pageIndex].stories?[_storyIndex];
    ReactionBottomSheetUi.show(
      context: context,
      storyId: st?.id ?? "",
      callback: () => _story.play(),
    );
  }

  void _onStoryShow(int i) {
    if (!mounted || _storyIndex == i) return; // avoid redundant updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _storyIndex = i);
      _maybeCreateViewHistory(); // safe to run after the frame
    });
  }

  void _onCompleteGroup() {
    if (_pageIndex >= widget.groups.length - 1) {
      Navigator.maybePop(context);
    } else {
      _pageIndex++;
      _storyIndex = 0;
      _page.animateToPage(_pageIndex,
          duration: const Duration(milliseconds: 300), curve: Curves.linear);
      setState(() {});
    }
  }

  int initialStoryIndexForPage = 0;
  final Map<int, s.StoryController> storyControllers = {};
  s.StoryController getStoryController(int index) {
    if (!storyControllers.containsKey(index)) {
      storyControllers[index] = s.StoryController();
    }
    return storyControllers[index]!;
  }

  void onPreviousStory() {
    final storyCtrl = getStoryController(_pageIndex);

    // Same user
    if (_storyIndex > 0) {
      _storyIndex--;
      storyCtrl.previous();
      return;
    }

    // Previous user
    if (_pageIndex > 0) {
      _pageIndex--;
      initialStoryIndexForPage = _itemsPerGroup[_pageIndex].length - 1;

      _page.animateToPage(_pageIndex,
          duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final kUp = bottomInset > 0.0;
    if (_keyboardUp != kUp) {
      _keyboardUp = kUp;
      if (!_keyboardUp && !_isLongPressing) _story.play(); // Check long press
    }
    return Scaffold(
      backgroundColor: AppColor.black,
      body: PageView.builder(
        controller: _page,
        itemCount: widget.groups.length,
        onPageChanged: (i) => setState(() {
          _pageIndex = i;
          _storyIndex = 0;
        }),
        itemBuilder: (_, page) {
          final items = _itemsPerGroup[page];

          final group = widget.groups[page];
          final stories = group.stories ?? const <Stories>[];
          final current =
              (_storyIndex < stories.length) ? stories[_storyIndex] : null;

          return Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPressStart: (_) {
                  if (_keyboardUp || ReactionBottomSheetUi.isBottomSheetOpen) return;
                  Utils.showLog("LONG PRESS START - Story Paused");
                  _isPotentialLongPress = false;
                  _tapTimer?.cancel();
                  _isLongPressing = true;
                  _story.pause();
                },
                onLongPressEnd: (_) {
                  if (_keyboardUp || ReactionBottomSheetUi.isBottomSheetOpen) return;
                  Utils.showLog("LONG PRESS END - Story Playing");
                  _isLongPressing = false;
                  _isPotentialLongPress = false;
                  _story.play();
                },
                onLongPressCancel: () {
                  if (_keyboardUp || ReactionBottomSheetUi.isBottomSheetOpen) return;
                  Utils.showLog("LONG PRESS CANCELLED");
                  _isLongPressing = false;
                  _isPotentialLongPress = false;
                  _story.play();
                },
                onTapDown: (details) {
                  if (_keyboardUp || ReactionBottomSheetUi.isBottomSheetOpen) {
                    if (_keyboardUp) FocusManager.instance.primaryFocus?.unfocus();
                    return;
                  }
                  Utils.showLog("TAP DOWN");
                  _tapTimer?.cancel();
                  _isPotentialLongPress = true;

                  final screenWidth = MediaQuery.of(context).size.width;
                  final dx = details.globalPosition.dx;
                  final isLeftTap = dx < screenWidth / 2;

                  _tapTimer = Timer(const Duration(milliseconds: 200), () {
                    if (!_isLongPressing && _isPotentialLongPress) {
                      Utils.showLog("TAP CONFIRMED - Navigate");
                      _isPotentialLongPress = false;

                      if (isLeftTap) {
                        onPreviousStory();
                      } else {
                        _story.next();
                      }
                    }
                  });
                },
                onTapUp: (_) {
                  if (!_isLongPressing) {
                    Utils.showLog("TAP UP - Quick tap");
                  }
                },
                onTapCancel: () {
                  Utils.showLog("TAP CANCELLED");
                  _isPotentialLongPress = false;
                  _tapTimer?.cancel();
                },
                onVerticalDragStart: (d) {
                  _dragStartY = d.globalPosition.dy;
                  _tapTimer?.cancel();
                  _isPotentialLongPress = false;
                },
                onVerticalDragUpdate: (d) {
                  if (d.globalPosition.dy - _dragStartY > 20) {
                    Navigator.maybePop(context);
                  }
                },
                child: SizedBox.expand(
                  child: s.StoryView(
                    storyItems: items,
                    controller: _story,
                    onStoryShow: (_, i) => _onStoryShow(i),
                    onComplete: _onCompleteGroup,
                  ),
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: Get.height / 4,
                    width: Get.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.black.withValues(alpha: 0.8),
                          AppColor.transparent
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: MediaQuery.of(context).viewPadding.top + 20,
                child: Container(
                  height: 70,
                  width: Get.width,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Container(
                        height: 55,
                        width: 55,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: PreviewProfileImageWidget(
                          image: group.user?.image ?? "",
                          isBanned: group.user?.isProfileImageBanned ?? false,
                        ),
                      ),
                      10.width,
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    group.user?.name ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFontStyle.styleW700(
                                        AppColor.white, 15),
                                  ),
                                ),
                                5.width,
                                Text(
                                  StoryDataFormat.onFormat(
                                      current?.createdAt ?? ""),
                                  style: AppFontStyle.styleW400(
                                      AppColor.white, 12),
                                ),
                              ],
                            ),
                            if (current?.backgroundSong?.id != null)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                child: Row(
                                  children: [
                                    Image.asset(AppAsset.icMusic, width: 10),
                                    5.width,
                                    Expanded(
                                      child: Text(
                                        "${current?.backgroundSong?.songTitle ?? ""} • ${current?.backgroundSong?.singerName ?? ""}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppFontStyle.styleW400(
                                            AppColor.white, 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      10.width,
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Image.asset(AppAsset.icClose,
                            width: 25, color: AppColor.white),
                      ),
                    ],
                  ),
                ),
              ),

              // bottom bar (comment + emoji)
              Positioned(
                bottom: MediaQuery.of(context).viewPadding.bottom + 20,
                child: Container(
                  width: Get.width,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: _CommentField(
                          controller: _comment,
                          onTap: () => _story.pause(),
                          onDone: () => _story.play(),
                          onSend: _sendComment,
                        ),
                      ),
                      10.width,
                      CircleIconButtonUi(
                        circleSize: 50,
                        iconSize: 45,
                        color: AppColor.white,
                        icon: AppAsset.icEmoji,
                        callback: () => _reaction(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ------------------------------------------------------------
/// OWN GROUP (your stories; supports delete + viewers bottom sheet)
/// ------------------------------------------------------------
class _OwnGroup extends StatefulWidget {
  const _OwnGroup({required this.stories, required this.initialIndex});
  final List<Stories> stories;
  final int initialIndex;

  @override
  State<_OwnGroup> createState() => _OwnGroupState();
}

class _OwnGroupState extends State<_OwnGroup> {
  final s.StoryController story = s.StoryController();
  int _index = 0;
  double _dragStartY = 0;
  void _onStoryShow(int i) {
    _index = i; // only update index
  }

  late List<StoryItem> _storyItems;

  @override
  void initState() {
    super.initState();

    _index = widget.initialIndex.clamp(0, widget.stories.length - 1);

    _storyItems = widget.stories
        .map((e) => onStoryItem(
              controller: story,
              itemData: e,
            ))
        .toList();

    /// 🔥 IMPORTANT: jump to initial story manually
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _index; i++) {
        story.next();
      }
    });
  }

  @override
  void dispose() {
    story.dispose();
    super.dispose();
  }

  void _delete() {
    story.pause();

    DeleteStoryDialogUi.onShow(
      onDelete: () async {
        Get.dialog(PopScope(canPop: false, child: const LoadingUi()),
            barrierDismissible: false);
        try {
          await DeleteStoryApi.callApi(
              loginUserId: Database.loginUserId,
              storyId: widget.stories[_index].id ?? "");
        } finally {
          Get.back();
          Get.back();
        }

        setState(() {
          _storyItems.removeAt(_index);
          widget.stories.removeAt(_index);
          if (widget.stories.isEmpty) {
            Navigator.maybePop(context);
          } else {
            _index = (_index >= widget.stories.length)
                ? widget.stories.length - 1
                : _index;
            story.play();
          }
        });
      },
      callback: () {
        story.play();
      },
    );
  }

  void _openViewers() {
    story.pause();
    ViewersBottomSheetUi.show(
      context: context,
      storyId: widget.stories[_index].id ?? "",
      callback: () => story.play(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.stories[_index];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onVerticalDragStart: (d) => _dragStartY = d.globalPosition.dy,
            onVerticalDragUpdate: (d) {
              final delta = d.globalPosition.dy - _dragStartY;
              if (delta > 20) Navigator.maybePop(context);
              if (delta < -20 && !ViewersBottomSheetUi.isBottomSheetOpen)
                _openViewers();
            },
            child: SizedBox.expand(
              child: s.StoryView(
                storyItems: _storyItems,
                controller: story,
                onComplete: () => Navigator.maybePop(context),
                onStoryShow: (_, i) => _onStoryShow(i),
              ),
            ),
          ),

          // Header (back, avatar, name, time, song, delete)
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 20,
            child: Container(
              width: Get.width,
              height: 70,
              padding: const EdgeInsets.only(left: 8, right: 15),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Image.asset(AppAsset.icBack,
                        width: 25, color: AppColor.white),
                  ),
                  5.width,
                  Container(
                    height: 55,
                    width: 55,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: PreviewProfileImageWidget(
                      image: Database.fetchLoginUserProfileModel?.user?.image ??
                          "",
                      isBanned: Database.fetchLoginUserProfileModel?.user
                              ?.isProfileImageBanned ??
                          false,
                    ),
                  ),
                  10.width,
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                Database.fetchLoginUserProfileModel?.user
                                        ?.name ??
                                    "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    AppFontStyle.styleW700(AppColor.white, 15),
                              ),
                            ),
                            5.width,
                            Text(
                              StoryDataFormat.onFormat(current.createdAt ?? ""),
                              style: AppFontStyle.styleW400(AppColor.white, 12),
                            ),
                          ],
                        ),
                        if (current.backgroundSong?.id != null)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                Image.asset(AppAsset.icMusic, width: 10),
                                5.width,
                                Expanded(
                                  child: Text(
                                    "${current.backgroundSong?.songTitle ?? ""} • ${current.backgroundSong?.singerName ?? ""}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFontStyle.styleW400(
                                        AppColor.white, 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  10.width,
                  GestureDetector(
                    onTap: _delete,
                    child: Image.asset(AppAsset.icDelete,
                        width: 22, color: AppColor.white),
                  ),
                ],
              ),
            ),
          ),

          // Bottom (views count like your current own-view)
          Positioned(
            bottom: MediaQuery.of(context).viewPadding.bottom + 20,
            child: Container(
              width: Get.width,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppAsset.icView,
                      width: 22, color: AppColor.white),
                  8.width,
                  Text("${current.viewsCount ?? 0} Views",
                      style: AppFontStyle.styleW700(AppColor.white, 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// SINGLE STORY (from Chat)
/// ------------------------------------------------------------
class _SingleStory extends StatelessWidget {
  const _SingleStory({required this.chat});
  final Chat chat;

  @override
  Widget build(BuildContext context) {
    final s.StoryController ctrl = s.StoryController();

    final one = Stories(
      id: chat.storyId?.id,
      mediaImageUrl: chat.storyId?.mediaImageUrl,
      mediaVideoUrl: chat.storyId?.mediaVideoUrl,
      createdAt: chat.storyId?.createdAt,
      storyType: chat.storyId?.storyType,
      reactionsCount: chat.storyId?.reactionsCount,
      viewsCount: chat.storyId?.viewsCount,
      isView: true,
      duration: chat.storyId?.duration,
      backgroundSong: chat.storyId?.backgroundSong,
    );

    final items = [onStoryItem(controller: ctrl, itemData: one)];

    final TextEditingController comment = TextEditingController();
    double dragStart = 0;

    void sendComment() async {
      final text = comment.text.trim();
      if (text.isEmpty) return;
      Get.dialog(PopScope(canPop: false, child: const LoadingUi()),
          barrierDismissible: false);
      try {
        await SendCommentToStoryApi.callApi(
          loginUserId: Database.loginUserId,
          storyId: chat.storyId?.id ?? "",
          message: text,
        );
      } finally {
        Get.back();
      }
      comment.clear();
      Utils.showToast("Comment Send To Story");
    }

    void react() {
      ctrl.pause();
      ReactionBottomSheetUi.show(
        context: context,
        storyId: chat.storyId?.id ?? "",
        callback: () => ctrl.play(),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.black,
      body: Stack(
        children: [
          GestureDetector(
            onVerticalDragStart: (d) => dragStart = d.globalPosition.dy,
            onVerticalDragUpdate: (d) {
              if (d.globalPosition.dy - dragStart > 20)
                Navigator.maybePop(context);
            },
            child: SizedBox.expand(
              child: s.StoryView(
                storyItems: items,
                controller: ctrl,
                onComplete: () => Navigator.maybePop(context),
                onStoryShow: (_, __) {},
              ),
            ),
          ),

          // header (avatar + name + time + song + close)
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 20,
            child: Container(
              width: Get.width,
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: PreviewProfileImageWidget(
                      image: chat.storyOwnerId?.image ?? "",
                      isBanned:
                          chat.storyOwnerId?.isProfileImageBanned ?? false,
                    ),
                  ),
                  10.width,
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(chat.storyOwnerId?.name ?? "",
                                  style: AppFontStyle.styleW700(
                                      AppColor.white, 15)),
                            ),
                            5.width,
                            Text(
                                StoryDataFormat.onFormat(
                                    chat.storyId?.createdAt ?? ""),
                                style:
                                    AppFontStyle.styleW400(AppColor.white, 12)),
                          ],
                        ),
                        if (chat.storyId?.backgroundSong?.id != null)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                Image.asset(AppAsset.icMusic, width: 10),
                                5.width,
                                Expanded(
                                  child: Text(
                                    "${chat.storyId?.backgroundSong?.songTitle ?? ""} • ${chat.storyId?.backgroundSong?.singerName ?? ""}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFontStyle.styleW400(
                                        AppColor.white, 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Image.asset(AppAsset.icClose,
                        width: 25, color: AppColor.white),
                  ),
                ],
              ),
            ),
          ),

          // bottom (comment + emoji)
          Positioned(
            bottom: MediaQuery.of(context).viewPadding.bottom + 20,
            child: Container(
              width: Get.width,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: _CommentField(
                      controller: comment,
                      onTap: () => ctrl.pause(),
                      onDone: () => ctrl.play(),
                      onSend: sendComment,
                    ),
                  ),
                  10.width,
                  CircleIconButtonUi(
                    circleSize: 50,
                    iconSize: 45,
                    color: AppColor.white,
                    icon: AppAsset.icEmoji,
                    callback: react,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small internal comment field (same UX as your current one)
class _CommentField extends StatelessWidget {
  const _CommentField(
      {required this.controller, this.onSend, this.onTap, this.onDone});
  final TextEditingController controller;
  final VoidCallback? onSend;
  final VoidCallback? onTap;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 15, right: 5),
      decoration: BoxDecoration(
          color: AppColor.white, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Image.asset(AppAsset.icCommentGradiant, height: 22, width: 22),
          const SizedBox(width: 5),
          VerticalDivider(
              indent: 12,
              endIndent: 12,
              color: AppColor.coloGreyText.withValues(alpha: 0.3)),
          const SizedBox(width: 5),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: 1,
              onTap: onTap,
              onFieldSubmitted: (_) => onDone?.call(),
              decoration: InputDecoration(
                hintText: "Type a comment…",
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 3),
                hintStyle: AppFontStyle.styleW400(AppColor.coloGreyText, 15),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';
//
// // Your models / utils
// import 'package:shortie/utils/database.dart';
// import 'package:shortie/utils/color.dart';
// import 'package:shortie/utils/font_style.dart';
// import 'package:shortie/utils/asset.dart';
// import 'package:shortie/pages/story_page/model/fetch_story_model.dart';
// import 'package:shortie/pages/story_page/widget/story_data_format.dart';
// import 'package:shortie/ui/preview_network_image_ui.dart';
//
// // story_view (alias to avoid conflicts)
// import 'package:story_view/controller/story_controller.dart' as sv;
// import 'package:story_view/widgets/story_view.dart' as sv;
//
// /// A single, reusable story viewer that adapts between:
// ///  - Owner view (Delete + Viewers)
// ///  - Other user view (Comment + Reaction)
// ///
// /// Pass a list of [Stories] (one user's story group).
// class UniversalStoryView extends StatefulWidget {
//   const UniversalStoryView({
//     super.key,
//     required this.stories,
//     required this.ownerUserId,
//     this.ownerName,
//     this.ownerImage,
//     this.initialIndex = 0,
//     this.onClose,
//     this.onViewed,
//     this.onOpenViewers,
//     this.onDeleteStory,
//     this.onSendComment,
//     this.onOpenReaction,
//     this.storyController,
//   });
//
//   final List<Stories> stories;
//   final String ownerUserId;
//
//   final String? ownerName;
//   final String? ownerImage;
//
//   final int initialIndex;
//
//   /// Called when user taps close/back.
//   final VoidCallback? onClose;
//
//   /// Called when a story (that wasn't viewed) is shown.
//   final FutureOr<void> Function(Stories story)? onViewed;
//
//   /// Owner-only: open viewers bottom sheet (or anything you prefer).
//   final void Function(Stories story)? onOpenViewers;
//
//   /// Owner-only: delete the current story.
//   /// Return true if delete succeeded (the widget will advance/close automatically).
//   final Future<bool> Function(int index, Stories story)? onDeleteStory;
//
//   /// Others-only: send a comment for the current story.
//   final FutureOr<void> Function(String text, Stories story)? onSendComment;
//
//   /// Others-only: open reaction bottom sheet (or any UI).
//   final void Function(Stories story)? onOpenReaction;
//
//   /// Optionally pass an external story controller (kept if you manage state outside).
//   final sv.StoryController? storyController;
//
//   @override
//   State<UniversalStoryView> createState() => _UniversalStoryViewState();
// }
//
// class _UniversalStoryViewState extends State<UniversalStoryView> {
//   late final sv.StoryController _controller;
//   late List<sv.StoryItem> _items;
//
//   final _commentCtrl = TextEditingController();
//
//   int _currentIndex = 0;
//   double _dragStartY = 0;
//   bool _isOwner = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _isOwner = widget.ownerUserId == Database.loginUserId;
//     _controller = widget.storyController ?? sv.StoryController();
//     _items = _buildStoryItems(widget.stories, _controller);
//
//     // Jump to initial index (simulate by advancing N times)
//     // NOTE: story_view doesn't support initialIndex directly, so we skip frames quickly.
//     if (widget.initialIndex > 0 && widget.initialIndex < _items.length) {
//       // queue advancing after first frame
//       WidgetsBinding.instance.addPostFrameCallback((_) async {
//         for (int i = 0; i < widget.initialIndex; i++) {
//           _controller.next();
//           await Future.delayed(const Duration(milliseconds: 5));
//         }
//       });
//       _currentIndex = widget.initialIndex;
//     }
//   }
//
//   @override
//   void dispose() {
//     if (widget.storyController == null) {
//       _controller.dispose();
//     }
//     _commentCtrl.dispose();
//     super.dispose();
//   }
//
//   // Build list of StoryItems from your Stories model
//   List<sv.StoryItem> _buildStoryItems(List<Stories> list, sv.StoryController controller) {
//     return list.map((s) => _mapStoryToItem(s, controller)).toList();
//   }
//
//   sv.StoryItem _mapStoryToItem(Stories s, sv.StoryController controller) {
//     final seconds = (s.duration == null || s.duration == 0) ? 15 : s.duration!.clamp(1, 60);
//     if (s.storyType == 2) {
//       // Video
//       return sv.StoryItem(
//         _InlineVideo(url: s.mediaVideoUrl ?? ''),
//         duration: Duration(seconds: seconds),
//       );
//     } else if (s.storyType == 1) {
//       // Image
//       return sv.StoryItem.pageImage(
//         url: s.mediaImageUrl ?? '',
//         controller: controller,
//         imageFit: BoxFit.cover,
//         duration: Duration(seconds: seconds),
//       );
//     } else {
//       return sv.StoryItem.text(
//         title: 'Unsupported',
//         backgroundColor: AppColor.primary,
//         duration: Duration(seconds: seconds),
//       );
//     }
//   }
//
//   void _onStoryShow(sv.StoryItem item, int index) async {
//     setState(() => _currentIndex = index);
//
//     // Track views for "others" only, if not marked as viewed.
//     final current = widget.stories[index];
//     if (!_isOwner && (current.isView == false || current.isView == null)) {
//       await widget.onViewed?.call(current);
//     }
//   }
//
//   Future<void> _onComplete() async {
//     // Finished all stories in this group → just close by default
//     if (widget.onClose != null)
//       widget.onClose!();
//     else if (mounted) Navigator.of(context).maybePop();
//   }
//
//   void _onVerticalDragStart(DragStartDetails d) {
//     _dragStartY = d.globalPosition.dy;
//   }
//
//   void _onVerticalDragUpdate(DragUpdateDetails d) {
//     final delta = d.globalPosition.dy - _dragStartY;
//
//     // Swipe down to close
//     if (delta > 20) {
//       if (widget.onClose != null)
//         widget.onClose!();
//       else
//         Navigator.of(context).maybePop();
//       return;
//     }
//
//     // Owner: swipe up to open viewers (if provided)
//     if (delta < -20 && _isOwner && widget.onOpenViewers != null) {
//       widget.onOpenViewers!(widget.stories[_currentIndex]);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final story = widget.stories.isEmpty ? null : widget.stories[_currentIndex];
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // Main gesture layer (vertical swipe & story)
//           GestureDetector(
//             onVerticalDragStart: _onVerticalDragStart,
//             onVerticalDragUpdate: _onVerticalDragUpdate,
//             child: SizedBox(
//               height: Get.height,
//               width: Get.width,
//               child: sv.StoryView(
//                 storyItems: _items,
//                 controller: _controller,
//                 onStoryShow: _onStoryShow,
//                 onComplete: _onComplete,
//               ),
//             ),
//           ),
//
//           // Top gradient (for readability)
//           Positioned(
//             top: 0,
//             child: Container(
//               height: Get.height / 4,
//               width: Get.width,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [AppColor.black.withValues(alpha: 0.8), AppColor.transparent],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//             ),
//           ),
//
//           // Top bar (profile, time, close / delete)
//           Positioned(
//             top: MediaQuery.of(context).viewPadding.top + 16,
//             left: 12,
//             right: 12,
//             child: _TopBar(
//               isOwner: _isOwner,
//               ownerImage: widget.ownerImage,
//               ownerName: widget.ownerName ?? '',
//               createdAt: story?.createdAt ?? '',
//               onClose: widget.onClose ??
//                   () {
//                     Navigator.of(context).maybePop();
//                   },
//               onDelete: widget.onDeleteStory == null
//                   ? null
//                   : () async {
//                       final ok = await widget.onDeleteStory!(_currentIndex, widget.stories[_currentIndex]);
//                       if (!ok) return;
//
//                       // Remove locally & advance / close
//                       setState(() {
//                         widget.stories.removeAt(_currentIndex);
//                         _items.removeAt(_currentIndex);
//                       });
//
//                       if (_items.isEmpty) {
//                         _onComplete();
//                       } else if (_currentIndex >= _items.length) {
//                         // If last was deleted, jump to previous item
//                         _controller.previous();
//                         setState(() => _currentIndex = _items.length - 1);
//                       } else {
//                         // Refresh current item
//                         _controller.next();
//                         await Future.delayed(const Duration(milliseconds: 5));
//                         _controller.previous();
//                       }
//                     },
//             ),
//           ),
//
//           // Bottom actions
//           Positioned(
//             bottom: MediaQuery.of(context).viewPadding.bottom + 16,
//             left: 12,
//             right: 12,
//             child: _isOwner
//                 ? _OwnerFooter(
//                     viewsCount: story?.viewsCount ?? 0,
//                     onOpenViewers: widget.onOpenViewers == null ? null : () => widget.onOpenViewers!(widget.stories[_currentIndex]),
//                   )
//                 : _OthersFooter(
//                     controller: _controller,
//                     commentCtrl: _commentCtrl,
//                     onSend: widget.onSendComment == null
//                         ? null
//                         : () async {
//                             final text = _commentCtrl.text.trim();
//                             if (text.isEmpty) return;
//                             await widget.onSendComment!(text, widget.stories[_currentIndex]);
//                             _commentCtrl.clear();
//                           },
//                     onReaction: widget.onOpenReaction == null ? null : () => widget.onOpenReaction!(widget.stories[_currentIndex]),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /// ---------- UI PARTS ----------
//
// class _TopBar extends StatelessWidget {
//   const _TopBar({
//     required this.isOwner,
//     required this.ownerImage,
//     required this.ownerName,
//     required this.createdAt,
//     required this.onClose,
//     this.onDelete,
//   });
//
//   final bool isOwner;
//   final String? ownerImage;
//   final String ownerName;
//   final String createdAt;
//   final VoidCallback onClose;
//   final FutureOr<void> Function()? onDelete;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         // Back/Close
//         GestureDetector(
//           onTap: onClose,
//           child: Container(
//             height: 40,
//             width: 40,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: AppColor.white.withValues(alpha: 0.15),
//             ),
//             child: Image.asset(AppAsset.icBack, width: 22, color: AppColor.white),
//           ),
//         ),
//         const SizedBox(width: 8),
//         // Avatar
//         Container(
//           height: 48,
//           width: 48,
//           clipBehavior: Clip.antiAlias,
//           decoration: const BoxDecoration(shape: BoxShape.circle),
//           child: PreviewProfileImageWidget(
//             image: ownerImage ?? '',
//             isBanned: false,
//           ),
//         ),
//         const SizedBox(width: 10),
//         // Name + time
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(ownerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppFontStyle.styleW700(Colors.white, 15)),
//               Text(
//                 StoryDataFormat.onFormat(createdAt),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: AppFontStyle.styleW400(Colors.white, 12),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 10),
//         // Owner: Delete, Others: Close-only
//         if (isOwner && onDelete != null)
//           GestureDetector(
//             onTap: onDelete,
//             child: Container(
//               height: 40,
//               width: 40,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: AppColor.white.withValues(alpha: 0.2),
//               ),
//               child: Image.asset(AppAsset.icDelete, width: 22, color: AppColor.white),
//             ),
//           ),
//       ],
//     );
//   }
// }
//
// class _OwnerFooter extends StatelessWidget {
//   const _OwnerFooter({required this.viewsCount, this.onOpenViewers});
//
//   final int viewsCount;
//   final VoidCallback? onOpenViewers;
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: GestureDetector(
//         onTap: onOpenViewers,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           decoration: BoxDecoration(
//             color: AppColor.white.withValues(alpha: 0.16),
//             borderRadius: BorderRadius.circular(999),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Image.asset(AppAsset.icView, width: 22, color: Colors.white),
//               const SizedBox(width: 8),
//               Text("$viewsCount Views", style: AppFontStyle.styleW700(Colors.white, 14)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _OthersFooter extends StatefulWidget {
//   const _OthersFooter({
//     required this.controller,
//     required this.commentCtrl,
//     this.onSend,
//     this.onReaction,
//   });
//
//   final sv.StoryController controller;
//   final TextEditingController commentCtrl;
//   final VoidCallback? onSend;
//   final VoidCallback? onReaction;
//
//   @override
//   State<_OthersFooter> createState() => _OthersFooterState();
// }
//
// class _OthersFooterState extends State<_OthersFooter> {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         // Comment text field
//         Expanded(
//           child: Container(
//             height: 50,
//             padding: const EdgeInsets.only(left: 14, right: 6),
//             alignment: Alignment.center,
//             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
//             child: Row(
//               children: [
//                 Image.asset(AppAsset.icCommentGradiant, width: 20, height: 20),
//                 const SizedBox(width: 8),
//                 VerticalDivider(color: Colors.black.withValues(alpha:0.12), indent: 12, endIndent: 12),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: TextFormField(
//                     controller: widget.commentCtrl,
//                     cursorColor: Colors.black54,
//                     maxLines: 1,
//                     onTap: () => widget.controller.pause(),
//                     onFieldSubmitted: (_) => widget.controller.play(),
//                     decoration: InputDecoration(
//                       hintText: 'Type a comment...',
//                       hintStyle: AppFontStyle.styleW400(Colors.black54, 15),
//                       border: InputBorder.none,
//                       isCollapsed: true,
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     widget.controller.pause();
//                     widget.onSend?.call();
//                     widget.controller.play();
//                   },
//                   child: SizedBox(
//                     width: 42,
//                     height: 42,
//                     child: Center(child: Image.asset(AppAsset.icSend, width: 26)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         // Reaction button
//         GestureDetector(
//           onTap: () {
//             widget.controller.pause();
//             widget.onReaction?.call();
//             // resume will be handled by caller after bottom sheet close if needed
//           },
//           child: Container(
//             height: 50,
//             width: 50,
//             alignment: Alignment.center,
//             decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
//             child: Image.asset(AppAsset.icEmoji, width: 40, height: 40),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// /// Inline video player used by StoryItems (looping, covers full area)
// class _InlineVideo extends StatefulWidget {
//   const _InlineVideo({required this.url});
//   final String url;
//
//   @override
//   State<_InlineVideo> createState() => _InlineVideoState();
// }
//
// class _InlineVideoState extends State<_InlineVideo> {
//   late final VideoPlayerController _vc;
//   bool _ready = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _vc = VideoPlayerController.networkUrl(Uri.parse(widget.url));
//     _init();
//   }
//
//   Future<void> _init() async {
//     try {
//       await _vc.initialize();
//       await _vc.setLooping(true);
//       await _vc.play();
//       if (mounted) setState(() => _ready = true);
//     } catch (_) {
//       // swallow; keep loader
//     }
//   }
//
//   @override
//   void dispose() {
//     _vc.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.black,
//       width: double.infinity,
//       height: double.infinity,
//       child: _ready
//           ? FittedBox(
//               fit: BoxFit.cover,
//               child: SizedBox(
//                 width: _vc.value.size.width,
//                 height: _vc.value.size.height,
//                 child: VideoPlayer(_vc),
//               ),
//             )
//           : const Center(child: CircularProgressIndicator()),
//     );
//   }
// }
