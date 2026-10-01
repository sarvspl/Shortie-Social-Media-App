import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/custom/custom_format_number.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/multi_live_page/controller/multi_live_controller.dart';
import 'package:shortie/pages/stream_page/model/live_user_object_model.dart';
import 'package:shortie/ui/circle_icon_button_ui.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/ui/preview_network_image_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class HostVideoView extends StatefulWidget {
  String streamID;
  Requested? coHost;
  double height;
  bool isMute;
  HostVideoView({super.key, required this.streamID, required this.height, required this.coHost, required this.isMute});

  @override
  State<HostVideoView> createState() => _HostVideoViewState();
}

class _HostVideoViewState extends State<HostVideoView> {
  Widget? remoteView;

  @override
  void initState() {
    log("HostVideoView initState");
    // TODO: implement initState
    startPlayStream(widget.streamID);
    log("widget.coHost?.isCameraEnabled>>${widget.coHost?.isCameraEnabled}");
    super.initState();
  }

  Future<void> startPlayStream(String streamID) async {
    await 1.seconds.delay();
    log("Start Play startPlayStream>>>>>>>>>>$streamID");
    // Start to play streams. Set the view for rendering the remote streams.
    ZegoExpressEngine.instance.setVideoMirrorMode(ZegoVideoMirrorMode.BothMirror);
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      ZegoCanvas canvas = ZegoCanvas(
        viewID,
        viewMode: ZegoViewMode.AspectFill,
      );
      ZegoExpressEngine.instance.setVideoMirrorMode(ZegoVideoMirrorMode.NoMirror);
      log("start Play stream ${streamID}");
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
    }).then((canvasViewWidget) {
      setState(() => remoteView = canvasViewWidget);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: Get.width * 0.3,
      child: Stack(
        children: [
          // Blurred background image when camera is off
          if (!(widget.coHost?.isCameraEnabled ?? true))
            Container(
              height: widget.height,
              width: Get.width * 0.3,
              child: PreviewNetworkImageUi(image: widget.coHost?.image),
            ),
          if (!(widget.coHost?.isCameraEnabled ?? true))
            ClipRRect(
              // Clip it cleanly.
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.grey.withValues(alpha:0.1),
                  alignment: Alignment.center,
                ),
              ),
            ),
          // Normal profile image on top of the blurred background
          if (!(widget.coHost?.isCameraEnabled ?? true))
            Center(
              child: Container(
                height: Get.width * 0.12,
                width: Get.width * 0.12,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: PreviewNetworkImageUi(image: widget.coHost?.image),
              ),
            ),

          // Remote video view when camera is on
          if ((widget.coHost?.isCameraEnabled ?? true)) remoteView ?? Container(color: Colors.black),

          // coin show
          Positioned(
              right: 0,
              child: Container(
                height: 18,
                // width: 40,
                padding: EdgeInsets.all(2),
                margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColor.colorPendingYellow.withAlpha(52),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(AppAsset.icCoin),
                    8.width,
                    Text(
                      "${CustomFormatNumber.convert(widget.coHost?.coin ?? 0)}",
                      style: AppFontStyle.styleW600(AppColor.colorPendingYellow.withAlpha(200), 12),
                    ),
                    8.width,
                  ],
                ),
              )),

          // Bottom overlay with user name and mute icon
          Positioned(
            bottom: 6,
            child: Container(
              width: Get.width * 0.3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColor.black.withValues(alpha:0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.coHost?.name ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFontStyle.styleW700(AppColor.white, 10),
                      ),
                    ),
                    5.width,
                    !widget.isMute
                        ? CircleIconButtonUi(
                            circleSize: 20,
                            iconSize: 12,
                            gradient: AppColor.primaryLinearGradient,
                            icon: AppAsset.icMicOff,
                            iconColor: AppColor.white,
                            callback: () {},
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//
// class PkHostVideoView extends StatefulWidget {
//   String streamID;
//   double height;
//   bool isMute;
//   PkHostVideoView({super.key, required this.streamID, required this.height, required this.isMute});
//
//   @override
//   State<PkHostVideoView> createState() => _PkHostVideoViewState();
// }
//
// class _PkHostVideoViewState extends State<PkHostVideoView> {
//   Widget? remoteView;
//   MultiLiveController controller = Get.find<MultiLiveController>();
//   @override
//   void initState() {
//     log("HostVideoView initState");
//     // TODO: implement initState
//     startPlayStream(widget.streamID);
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     log("PkHostVideoView dispose");
//     ZegoExpressEngine.instance.stopPlayingStream(widget.streamID);
//     super.dispose();
//   }
//
//   ZegoCanvas canvas = ZegoCanvas.view(0);
//   Future<void> startPlayStream(String streamID) async {
//     await 1.seconds.delay();
//     log("Start Play startPlayStream>>>>>>>>>>$streamID");
//     // Start to play streams. Set the view for rendering the remote streams.
//     ZegoExpressEngine.instance.setVideoMirrorMode(ZegoVideoMirrorMode.BothMirror);
//     await ZegoExpressEngine.instance.createCanvasView((viewID) {
//       canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
//
//       log("remoteView start Play stream ${streamID}");
//       log("remoteView start Play stream ${viewID}");
//       log("remoteView start Play stream ${remoteView}");
//       ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
//     }).then((canvasViewWidget) {
//       setState(() => remoteView = canvasViewWidget);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<MultiLiveController>(
//       id: 'onUpdateMultiLive',
//       builder: (controller) {
//         Utils.showLog("stream ${remoteView.runtimeType}");
//
//         Utils.showLog("stream ${canvas.view}");
//         Utils.showLog("stream ${canvas.viewMode}");
//         Utils.showLog("stream ${canvas.viewMode}");
//         return Container(
//           height: widget.height,
//           width: Get.width * 0.3,
//           child: remoteView ?? _buildOffCameraUserProfile(controller, Get.height * 0.5, Get.width),
//         );
//       },
//     );
//   }
//
//   Widget _buildOffCameraUserProfile(MultiLiveController logic, double height, double width) {
//     return SizedBox(
//       height: height,
//       width: width,
//       child: Stack(
//         children: [
//           SizedBox(
//             height: height,
//             width: width,
//             child: PreviewNetworkImageUi(image: logic.host2Image),
//           ),
//           ClipRRect(
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
//               child: Container(
//                 color: Colors.grey.withValues(alpha:0.1),
//                 alignment: Alignment.center,
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.center,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   height: 100,
//                   width: 100,
//                   clipBehavior: Clip.hardEdge,
//                   decoration: const BoxDecoration(shape: BoxShape.circle),
//                   child: PreviewNetworkImageUi(image: logic.image),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(logic.name, style: AppFontStyle.styleW700(AppColor.white, 14))
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class PkHostVideoView extends StatefulWidget {
//   String streamID;
//   double height;
//   bool isMute;
//   PkHostVideoView({super.key, required this.streamID, required this.height, required this.isMute});
//
//   @override
//   State<PkHostVideoView> createState() => _PkHostVideoViewState();
// }
//
// class _PkHostVideoViewState extends State<PkHostVideoView> {
//   Widget? remoteView;
//   MultiLiveController controller = Get.find<MultiLiveController>();
//
//   // Stream state tracking
//   bool isStreamInitialized = false;
//   bool isStreamPlaying = false;
//   bool isStreamConnected = false;
//   bool hasStreamError = false;
//   String streamError = "";
//
//   ZegoCanvas? canvas;
//   int? viewID;
//
//   @override
//   void initState() {
//     log("HostVideoView initState");
//     _setupStreamListeners();
//     startPlayStream(widget.streamID);
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     log("PkHostVideoView dispose");
//     _removeStreamListeners();
//     if (isStreamPlaying) {
//       ZegoExpressEngine.instance.stopPlayingStream(widget.streamID);
//     }
//     super.dispose();
//   }
//
//   // Setup stream event listeners
//   void _setupStreamListeners() {
//     // Listen for stream state changes
//     ZegoExpressEngine.onPlayerStateUpdate = (String streamID, ZegoPlayerState state, int errorCode, Map<String, dynamic> extendedData) {
//       log("Stream state update: $streamID, state: $state, error: $errorCode");
//
//       if (widget.streamID == streamID) {
//         setState(() {
//           switch (state) {
//             case ZegoPlayerState.NoPlay:
//               isStreamPlaying = false;
//               isStreamConnected = false;
//               break;
//             case ZegoPlayerState.PlayRequesting:
//               isStreamPlaying = false;
//               isStreamConnected = false;
//               break;
//             case ZegoPlayerState.Playing:
//               isStreamPlaying = true;
//               isStreamConnected = true;
//               hasStreamError = false;
//               streamError = "";
//               break;
//           }
//
//           if (errorCode != 0) {
//             hasStreamError = true;
//             streamError = "Stream error: $errorCode";
//           }
//         });
//       }
//     };
//
//     // Listen for stream quality updates
//     ZegoExpressEngine.onPlayerQualityUpdate = (String streamID, ZegoPlayStreamQuality quality) {
//       if (widget.streamID == streamID) {
//         log("Stream quality update: $streamID, fps: ${quality.videoRecvFPS}, ");
//
//         // Check if stream is actually receiving video data
//         setState(() {
//           isStreamConnected = quality.videoRecvFPS > 0;
//         });
//       }
//     };
//   }
//
//   // Remove stream listeners
//   void _removeStreamListeners() {
//     ZegoExpressEngine.onPlayerStateUpdate = null;
//     ZegoExpressEngine.onPlayerQualityUpdate = null;
//   }
//
//   Future<void> startPlayStream(String streamID) async {
//     try {
//       await 1.seconds.delay();
//       log("Start Play startPlayStream>>>>>>>>>>$streamID");
//
//       setState(() {
//         isStreamInitialized = false;
//         hasStreamError = false;
//         streamError = "";
//       });
//
//       // Start to play streams. Set the view for rendering the remote streams.
//       ZegoExpressEngine.instance.setVideoMirrorMode(ZegoVideoMirrorMode.BothMirror);
//
//       await ZegoExpressEngine.instance.createCanvasView((createdViewID) {
//         viewID = createdViewID;
//         canvas = ZegoCanvas(createdViewID, viewMode: ZegoViewMode.AspectFill);
//
//         log("remoteView start Play stream ${streamID}");
//         log("remoteView canvas viewID ${createdViewID}");
//         log("remoteView canvas created: ${canvas != null}");
//
//         // Start playing the stream
//         ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas!);
//       }).then((canvasViewWidget) {
//         if (mounted) {
//           setState(() {
//             remoteView = canvasViewWidget;
//             isStreamInitialized = true;
//           });
//           log("remoteView created successfully: ${remoteView != null}");
//           log("Canvas view ID: $viewID");
//         }
//       }).catchError((error) {
//         log("Error creating canvas view: $error");
//         if (mounted) {
//           setState(() {
//             hasStreamError = true;
//             streamError = "Failed to create canvas: $error";
//             isStreamInitialized = false;
//           });
//         }
//       });
//     } catch (e) {
//       log("Error starting stream: $e");
//       if (mounted) {
//         setState(() {
//           hasStreamError = true;
//           streamError = "Failed to start stream: $e";
//           isStreamInitialized = false;
//         });
//       }
//     }
//   }
//
//   // Check if remote view is available and working
//   bool isRemoteViewAvailable() {
//     return remoteView != null && isStreamInitialized && isStreamPlaying && isStreamConnected && !hasStreamError;
//   }
//
//   // Get stream status for debugging
//   String getStreamStatus() {
//     if (hasStreamError) return "Error: $streamError";
//     if (!isStreamInitialized) return "Initializing...";
//     if (!isStreamPlaying) return "Not Playing";
//     if (!isStreamConnected) return "Not Connected";
//     return "Connected & Playing";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<MultiLiveController>(
//       id: 'onUpdateMultiLive',
//       builder: (controller) {
//         // Debug logs
//
//         return Container(
//           height: widget.height,
//           width: Get.width * 0.3,
//           child: Stack(
//             children: [
//               // Main content - show remote view or off-camera profile
//               isRemoteViewAvailable() ? remoteView! : _buildOffCameraUserProfile(controller, Get.height * 0.5, Get.width),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildOffCameraUserProfile(MultiLiveController logic, double height, double width) {
//     return SizedBox(
//       height: height,
//       width: width,
//       child: Stack(
//         children: [
//           SizedBox(
//             height: height,
//             width: width,
//             child: PreviewNetworkImageUi(image: logic.host2Image),
//           ),
//           ClipRRect(
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
//               child: Container(
//                 color: Colors.grey.withValues(alpha:0.1),
//                 alignment: Alignment.center,
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.center,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   height: 100,
//                   width: 100,
//                   clipBehavior: Clip.hardEdge,
//                   decoration: const BoxDecoration(shape: BoxShape.circle),
//                   child: PreviewNetworkImageUi(image: logic.host2Image),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(logic.host2Name ?? "User", style: AppFontStyle.styleW700(AppColor.white, 14)),
//                 const SizedBox(height: 5),
//
//                 // Status indicator
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class PkHostVideoView extends StatefulWidget {
  String streamID;
  double height;
  bool isMute;

  PkHostVideoView({
    super.key,
    required this.streamID,
    required this.height,
    required this.isMute,
  });

  @override
  State<PkHostVideoView> createState() => _PkHostVideoViewState();
}

class _PkHostVideoViewState extends State<PkHostVideoView> {
  Widget? remoteView;
  MultiLiveController controller = Get.find<MultiLiveController>();

  // Stream state tracking
  bool isStreamInitialized = false;
  bool isStreamPlaying = false;
  bool isStreamConnected = false;
  bool hasStreamError = false;
  String streamError = "";

  ZegoCanvas? canvas;
  int? viewID;

  @override
  void initState() {
    log("HostVideoView initState");
    _setupStreamListeners();
    startPlayStream(widget.streamID);
    super.initState();
  }

  @override
  void dispose() {
    log("PkHostVideoView dispose");
    _removeStreamListeners();
    if (isStreamPlaying) {
      ZegoExpressEngine.instance.stopPlayingStream(widget.streamID);
    }
    super.dispose();
  }

  // Setup stream event listeners
  void _setupStreamListeners() {
    // Listen for stream state changes
    ZegoExpressEngine.onPlayerStateUpdate = (String streamID, ZegoPlayerState state, int errorCode, Map<String, dynamic> extendedData) {
      log("Stream state update: $streamID, state: $state, error: $errorCode");

      if (widget.streamID == streamID) {
        setState(() {
          switch (state) {
            case ZegoPlayerState.NoPlay:
              isStreamPlaying = false;
              isStreamConnected = false;
              break;
            case ZegoPlayerState.PlayRequesting:
              isStreamPlaying = false;
              isStreamConnected = false;
              break;
            case ZegoPlayerState.Playing:
              isStreamPlaying = true;
              isStreamConnected = true;
              hasStreamError = false;
              streamError = "";
              break;
          }

          if (errorCode != 0) {
            hasStreamError = true;
            streamError = "Stream error: $errorCode";
          }
        });
      }
    };

    // Listen for stream quality updates
    ZegoExpressEngine.onPlayerQualityUpdate = (String streamID, ZegoPlayStreamQuality quality) {
      if (widget.streamID == streamID) {
        log("Stream quality update: $streamID, fps: ${quality.videoRecvFPS}");

        setState(() {
          isStreamConnected = quality.videoRecvFPS > 0;
        });
      }
    };
  }

  // Remove stream listeners
  void _removeStreamListeners() {
    ZegoExpressEngine.onPlayerStateUpdate = null;
    ZegoExpressEngine.onPlayerQualityUpdate = null;
  }

  // Start playing stream (create canvas once and reuse)
  Future<void> startPlayStream(String streamID) async {
    try {
      log("Start Play startPlayStream >>>>>>>>>> $streamID");

      setState(() {
        isStreamInitialized = false;
        hasStreamError = false;
        streamError = "";
      });

      ZegoExpressEngine.instance.setVideoMirrorMode(ZegoVideoMirrorMode.BothMirror);

      if (canvas == null) {
        // Only create canvas if not created already
        await ZegoExpressEngine.instance.createCanvasView((createdViewID) {
          viewID = createdViewID;
          canvas = ZegoCanvas(createdViewID, viewMode: ZegoViewMode.AspectFill);

          log("Canvas created for stream: $streamID, viewID: $viewID");
        }).then((canvasViewWidget) {
          if (mounted) {
            setState(() {
              remoteView = canvasViewWidget;
              isStreamInitialized = true;
            });
            log("Remote view created successfully: ${remoteView != null}");
          }
        }).catchError((error) {
          log("Error creating canvas view: $error");
          if (mounted) {
            setState(() {
              hasStreamError = true;
              streamError = "Failed to create canvas: $error";
              isStreamInitialized = false;
            });
          }
        });
      }

      // Start playing the stream (reuse existing canvas)
      if (canvas != null) {
        await ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas!);
      }
    } catch (e) {
      log("Error starting stream: $e");
      if (mounted) {
        setState(() {
          hasStreamError = true;
          streamError = "Failed to start stream: $e";
          isStreamInitialized = false;
        });
      }
    }
  }

  // Toggle video fast without recreating canvas
  Future<void> toggleVideo(bool enable) async {
    log("Toggle video: $enable");
    if (canvas != null) {
      if (enable) {
        await ZegoExpressEngine.instance.startPlayingStream(widget.streamID, canvas: canvas!);
      } else {
        await ZegoExpressEngine.instance.stopPlayingStream(widget.streamID);
      }
    }
  }

  bool isRemoteViewAvailable() {
    return remoteView != null && isStreamInitialized && isStreamPlaying && isStreamConnected && !hasStreamError;
  }

  String getStreamStatus() {
    if (hasStreamError) return "Error: $streamError";
    if (!isStreamInitialized) return "Initializing...";
    if (!isStreamPlaying) return "Not Playing";
    if (!isStreamConnected) return "Not Connected";
    return "Connected & Playing";
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MultiLiveController>(
      id: 'onUpdateMultiLive',
      builder: (controller) {
        return Container(
          height: widget.height,
          width: Get.width * 0.3,
          child: Stack(
            children: [
              // _buildOffCameraUserProfile(controller, Get.height * 0.5, Get.width),

              (controller.isLoading.value == false && remoteView != null) ? remoteView! : LoadingUi(color: AppColor.white),
              // isRemoteViewAvailable() ? remoteView! : _buildOffCameraUserProfile(controller, Get.height * 0.5, Get.width),
            ],
          ),
        );
      },
    );
  }

  // Widget _buildOffCameraUserProfile(MultiLiveController logic, double height, double width) {
  //   return SizedBox(
  //     height: height,
  //     width: width,
  //     child: Stack(
  //       children: [
  //         SizedBox(
  //           height: height,
  //           width: width,
  //           child: PreviewNetworkImageUi(image: logic.host2Image),
  //         ),
  //         ClipRRect(
  //           child: BackdropFilter(
  //             filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
  //             child: Container(
  //               color: Colors.grey.withValues(alpha:0.1),
  //               alignment: Alignment.center,
  //             ),
  //           ),
  //         ),
  //         Align(
  //           alignment: Alignment.center,
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Container(
  //                 height: 100,
  //                 width: 100,
  //                 clipBehavior: Clip.hardEdge,
  //                 decoration: const BoxDecoration(shape: BoxShape.circle),
  //                 child: PreviewNetworkImageUi(image: logic.host2Image),
  //               ),
  //               const SizedBox(height: 5),
  //               Text(logic.host2Name ?? "User", style: AppFontStyle.styleW700(AppColor.white, 14)),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
