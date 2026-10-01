import 'dart:io';
 import 'package:flutter/material.dart';
import 'package:shortie/pages/splash_screen_page/api/admin_setting_api.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateDialog extends StatefulWidget {
  const ForceUpdateDialog({super.key});

  @override
  State<ForceUpdateDialog> createState() => _ForceUpdateDialogState();
}

class _ForceUpdateDialogState extends State<ForceUpdateDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withValues(alpha:0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Icon
                  TweenAnimationBuilder(
                    duration: const Duration(seconds: 2),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: 1 + (0.08 * (1 - (value - 0.5).abs() * 2)),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColor.primary.withValues(alpha:0.2),
                                AppColor.primary.withValues(alpha:0.05),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primary.withValues(alpha:0.3),
                                blurRadius: 25,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.primary,
                                    AppColor.primary.withValues(alpha:0.7),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.system_update_alt_rounded,
                                size: 38,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: AppColor.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          "New Version",
                          style: AppFontStyle.styleW600(AppColor.primary, 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    "Update Required",
                    style: AppFontStyle.styleW700(AppColor.black, 24),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    "Please update to the latest version to continue using the app with new features and improvements.",
                    style: AppFontStyle.styleW400(
                      AppColor.black.withValues(alpha:0.65),
                      14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 28),

                  // Update Button
                  InkWell(
                    onTap: _openStore,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            AppColor.primary,
                            AppColor.primary.withValues(alpha:0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primary.withValues(alpha:0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.download_rounded, color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            "Update Now",
                            style: AppFontStyle.styleW700(Colors.white, 16),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Footer
                  Text(
                    "This update is required to continue",
                    style: AppFontStyle.styleW500(
                      AppColor.black.withValues(alpha:0.5),
                      12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openStore() async {
    final url = Platform.isAndroid
        ? AdminSettingsApi.adminSettingModel?.data?.androidAppLink ?? ""
        : AdminSettingsApi.adminSettingModel?.data?.iosAppLink ?? "";

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shortie/pages/splash_screen_page/api/admin_setting_api.dart';
// import 'package:shortie/utils/color.dart';
// import 'package:shortie/utils/font_style.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class ForceUpdateDialog extends StatefulWidget {
//   const ForceUpdateDialog({super.key});
//
//   @override
//   State<ForceUpdateDialog> createState() => _ForceUpdateDialogState();
// }
//
// class _ForceUpdateDialogState extends State<ForceUpdateDialog> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
//     );
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
//     _controller.forward();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
//         insetPadding: const EdgeInsets.symmetric(horizontal: 20),
//         backgroundColor: Colors.transparent,
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: SlideTransition(
//             position: _slideAnimation,
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(28),
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.white,
//                     AppColor.primary.withValues(alpha:0.02),
//                   ],
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha:0.15),
//                     blurRadius: 40,
//                     offset: const Offset(0, 20),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Top Gradient Header
//                   Container(
//                     height: 180,
//                     decoration: BoxDecoration(
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(28),
//                         topRight: Radius.circular(28),
//                       ),
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           AppColor.primary,
//                           AppColor.primary.withValues(alpha:0.7),
//                         ],
//                       ),
//                     ),
//                     child: Stack(
//                       children: [
//                         // Background Pattern
//                         Positioned.fill(
//                           child: CustomPaint(
//                             painter: _CirclePatternPainter(),
//                           ),
//                         ),
//                         // Icon
//                         Center(
//                           child: TweenAnimationBuilder(
//                             duration: const Duration(seconds: 2),
//                             tween: Tween<double>(begin: 0, end: 1),
//                             builder: (context, double value, child) {
//                               return Transform.rotate(
//                                 angle: value * 0.1 - 0.05,
//                                 child: Container(
//                                   width: 90,
//                                   height: 90,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withValues(alpha:0.2),
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       color: Colors.white.withValues(alpha:0.3),
//                                       width: 2,
//                                     ),
//                                   ),
//                                   child: const Icon(
//                                     Icons.rocket_launch_rounded,
//                                     size: 45,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Content
//                   Padding(
//                     padding: const EdgeInsets.all(32),
//                     child: Column(
//                       children: [
//                         // Version Badge
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           decoration: BoxDecoration(
//                             color: AppColor.primary.withValues(alpha:0.08),
//                             borderRadius: BorderRadius.circular(30),
//                             border: Border.all(
//                               color: AppColor.primary.withValues(alpha:0.2),
//                               width: 1,
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Container(
//                                 width: 8,
//                                 height: 8,
//                                 decoration: BoxDecoration(
//                                   color: AppColor.primary,
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 "Version Update Available",
//                                 style: AppFontStyle.styleW600(AppColor.primary, 12),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const SizedBox(height: 20),
//
//                         // Title
//                         Text(
//                           "Time to Update!",
//                           style: AppFontStyle.styleW700(AppColor.black, 26),
//                           textAlign: TextAlign.center,
//                         ),
//
//                         const SizedBox(height: 12),
//
//                         // Description
//                         Text(
//                           "We've made the app better for you. Update now to enjoy new features and improvements.",
//                           style: AppFontStyle.styleW400(
//                             AppColor.black.withValues(alpha:0.6),
//                             15,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//
//                         const SizedBox(height: 28),
//
//                         // Features List
//                         _buildFeature(Icons.security_rounded, "Enhanced Security"),
//                         const SizedBox(height: 12),
//                         _buildFeature(Icons.speed_rounded, "Better Performance"),
//                         const SizedBox(height: 12),
//                         _buildFeature(Icons.auto_awesome_rounded, "New Features"),
//
//                         const SizedBox(height: 32),
//
//                         // Update Button
//                         GestureDetector(
//                           onTap: _openStore,
//                           child: Container(
//                             width: double.infinity,
//                             height: 58,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(16),
//                               gradient: LinearGradient(
//                                 colors: [
//                                   AppColor.primary,
//                                   AppColor.primary.withValues(alpha:0.8),
//                                 ],
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: AppColor.primary.withValues(alpha:0.35),
//                                   blurRadius: 20,
//                                   offset: const Offset(0, 10),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(Icons.system_update_alt_rounded, color: Colors.white, size: 24),
//                                 const SizedBox(width: 12),
//                                 Text(
//                                   "Update Now",
//                                   style: AppFontStyle.styleW700(Colors.white, 17),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(height: 16),
//
//                         // Info Text
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.info_outline_rounded,
//                               size: 14,
//                               color: AppColor.black.withValues(alpha:0.4),
//                             ),
//                             const SizedBox(width: 6),
//                             Text(
//                               "Required to continue using the app",
//                               style: AppFontStyle.styleW500(
//                                 AppColor.black.withValues(alpha:0.45),
//                                 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFeature(IconData icon, String text) {
//     return Row(
//       children: [
//         Container(
//           width: 36,
//           height: 36,
//           decoration: BoxDecoration(
//             color: AppColor.primary.withValues(alpha:0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: AppColor.primary, size: 18),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           text,
//           style: AppFontStyle.styleW500(AppColor.black.withValues(alpha:0.75), 14),
//         ),
//       ],
//     );
//   }
//
//   void _openStore() async {
//     final url = Platform.isAndroid
//         ? AdminSettingsApi.adminSettingModel?.data?.id ?? ""
//         : AdminSettingsApi.adminSettingModel?.data?.id ?? "";
//
//     await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//   }
// }
//
// class _CirclePatternPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withValues(alpha:0.1)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;
//
//     // Draw circular patterns
//     canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 40, paint);
//     canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 30, paint);
//     canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.7), 50, paint);
//     canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 25, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }