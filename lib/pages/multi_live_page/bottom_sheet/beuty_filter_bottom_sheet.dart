// lib/beauty_filter_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shortie/utils/utils.dart';
// import 'package:zego_express_engine/zego_express_engine.dart';
// import 'package:permission_handler/permission_handler.dart';

// // beauty_filter_types.dart
// enum ZegoBeautyType {
//   // Basic Beauty Effects
//   beautyBasicSmoothing,
//   beautyBasicSkinTone,
//   beautyBasicRosy,
//   beautyBasicSharpen,
//   beautyBasicWhiten,
//
//   // Advanced Beauty Effects
//   beautyAdvancedFaceSlimming,
//   beautyAdvancedEyesEnlarging,
//   beautyAdvancedEyesBrightening,
//   beautyAdvancedChinLengthening,
//   beautyAdvancedMouthReshape,
//   beautyAdvancedTeethWhitening,
//   beautyAdvancedNoseSlimming,
//   beautyAdvancedForeheadLift,
//
//   // Makeup Effects
//   makeupLipstick,
//   makeupBlusher,
//   makeupEyelash,
//   makeupEyeliner,
//   makeupEyeshadow,
//   makeupColoredContacts,
//
//   // Background Effects
//   backgroundPortraitSegmentation,
//
//   // Reset
//   beautyBasicReset,
// }
//
// enum ZegoEffectModelType {
//   basic,
//   advanced,
//   makeup,
//   background,
//   style,
//   lipstick,
//   blusher,
//   eyelash,
//   eyeliner,
//   eyeshadow,
//   coloredContacts,
// }
//
// // beauty_filter_data.dart
// class ZegoBeautyItem {
//   final ZegoBeautyType type;
//   final String iconText;
//   final String icon;
//   final String selectIcon;
//   final TextStyle textStyle;
//   final TextStyle selectedTextStyle;
//
//   ZegoBeautyItem({
//     required this.type,
//     required this.iconText,
//     required this.icon,
//     required this.selectIcon,
//     required this.textStyle,
//     required this.selectedTextStyle,
//   });
// }
//
// class ZegoEffectModel {
//   final ZegoEffectModelType type;
//   final String title;
//   final List<ZegoBeautyItem> items;
//
//   ZegoEffectModel({
//     required this.type,
//     required this.title,
//     required this.items,
//   });
// }
//
// class ZegoBeautyData {
//   static List<ZegoEffectModel> data() {
//     const defaultTextStyle = TextStyle(fontSize: 12, color: Color(0xffcccccc));
//     const selectedTextStyle = TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600);
//
//     return [
//       // Basic Beauty Effects
//       ZegoEffectModel(
//         type: ZegoEffectModelType.basic,
//         title: "Basic",
//         items: [
//           ZegoBeautyItem(
//             type: ZegoBeautyType.beautyBasicSmoothing,
//             iconText: "Smooth",
//             icon: "assets/icons/smooth.png",
//             selectIcon: "assets/icons/smooth_selected.png",
//             textStyle: defaultTextStyle,
//             selectedTextStyle: selectedTextStyle,
//           ),
//           ZegoBeautyItem(
//             type: ZegoBeautyType.beautyBasicWhiten,
//             iconText: "Whiten",
//             icon: "assets/icons/whiten.png",
//             selectIcon: "assets/icons/whiten_selected.png",
//             textStyle: defaultTextStyle,
//             selectedTextStyle: selectedTextStyle,
//           ),
//           ZegoBeautyItem(
//             type: ZegoBeautyType.beautyBasicSkinTone,
//             iconText: "Tone",
//             icon: "assets/icons/tone.png",
//             selectIcon: "assets/icons/tone_selected.png",
//             textStyle: defaultTextStyle,
//             selectedTextStyle: selectedTextStyle,
//           ),
//           ZegoBeautyItem(
//             type: ZegoBeautyType.beautyBasicRosy,
//             iconText: "Rosy",
//             icon: "assets/icons/rosy.png",
//             selectIcon: "assets/icons/rosy_selected.png",
//             textStyle: defaultTextStyle,
//             selectedTextStyle: selectedTextStyle,
//           ),
//           ZegoBeautyItem(
//             type: ZegoBeautyType.beautyBasicSharpen,
//             iconText: "Sharpen",
//             icon: "assets/icons/sharpen.png",
//             selectIcon: "assets/icons/sharpen_selected.png",
//             textStyle: defaultTextStyle,
//             selectedTextStyle: selectedTextStyle,
//           ),
//         ],
//       ),
//
//       // Advanced Beauty Effects
//       ZegoEffectModel(
//         type: ZegoEffectModelType.advanced,
//         title: "Advanced",
//         items: [
//           ZegoBeautyItem(
//             type: ZegoBeautyType.beautyAdvancedFaceSlimming,
//             iconText: "Face Slim",
//             icon: "assets/icons/face_slim.png",
//             selectIcon: "assets/icons/face_slim_selected.png",
//             textStyle: defaultTextStyle,
//             selectedTextStyle: selectedTextStyle,
//           ),
//           ZegoBeautyItem(
//             type: ZegoBeautyType.beautyAdvancedEyesEnlarging,
//             iconText: "Big Eyes",
//             icon: "assets/icons/big_eyes.png",
//             selectIcon: "assets/icons/big_eyes_selected.png",
//             textStyle: defaultTextStyle,
//             selectedTextStyle: selectedTextStyle,
//           ),
//           ZegoBeautyItem(
//             type: ZegoBeautyType.beautyAdvancedEyesBrightening,
//             iconText: "Bright Eyes",
//             icon: "assets/icons/bright_eyes.png",
//             selectIcon: "assets/icons/bright_eyes_selected.png",
//             textStyle: defaultTextStyle,
//             selectedTextStyle: selectedTextStyle,
//           ),
//           ZegoBeautyItem(
//             type: ZegoBeautyType.beautyAdvancedNoseSlimming,
//             iconText: "Nose Slim",
//             icon: "assets/icons/nose_slim.png",
//             selectIcon: "assets/icons/nose_slim_selected.png",
//             textStyle: defaultTextStyle,
//             selectedTextStyle: selectedTextStyle,
//           ),
//         ],
//       ),
//
//       // Makeup Effects
//       ZegoEffectModel(
//         type: ZegoEffectModelType.makeup,
//         title: "Makeup",
//         items: [
//           ZegoBeautyItem(
//             type: ZegoBeautyType.makeupLipstick,
//             iconText: "Lipstick",
//             icon: "assets/icons/lipstick.png",
//             selectIcon: "assets/icons/lipstick_selected.png",
//             textStyle: defaultTextStyle,
//             selectedTextStyle: selectedTextStyle,
//           ),
//           ZegoBeautyItem(
//             type: ZegoBeautyType.makeupBlusher,
//             iconText: "Blusher",
//             icon: "assets/icons/blusher.png",
//             selectIcon: "assets/icons/blusher_selected.png",
//             textStyle: defaultTextStyle,
//             selectedTextStyle: selectedTextStyle,
//           ),
//           ZegoBeautyItem(
//             type: ZegoBeautyType.makeupEyelash,
//             iconText: "Eyelash",
//             icon: "assets/icons/eyelash.png",
//             selectIcon: "assets/icons/eyelash_selected.png",
//             textStyle: defaultTextStyle,
//             selectedTextStyle: selectedTextStyle,
//           ),
//           ZegoBeautyItem(
//             type: ZegoBeautyType.makeupEyeliner,
//             iconText: "Eyeliner",
//             icon: "assets/icons/eyeliner.png",
//             selectIcon: "assets/icons/eyeliner_selected.png",
//             textStyle: defaultTextStyle,
//             selectedTextStyle: selectedTextStyle,
//           ),
//         ],
//       ),
//     ];
//   }
// }
//
// // beauty_filter_ability.dart
// class ZegoBeautyAbility {
//   final ZegoBeautyType type;
//   double currentValue;
//   final double minValue;
//   final double maxValue;
//   final double defaultValue;
//   final ZegoBeautyEditor editor;
//
//   ZegoBeautyAbility({
//     required this.type,
//     required this.currentValue,
//     required this.minValue,
//     required this.maxValue,
//     required this.defaultValue,
//     required this.editor,
//   });
//
//   void reset() {
//     currentValue = defaultValue;
//     editor.apply(currentValue);
//   }
// }
//
// class ZegoBeautyEditor {
//   final ZegoBeautyType type;
//   bool _isEnabled = false;
//
//   ZegoBeautyEditor(this.type);
//
//   void enable(bool enabled) {
//     _isEnabled = enabled;
//     // Here you would integrate with your actual beauty filter SDK
//     print('Beauty effect ${type.name} enabled: $enabled');
//   }
//
//   void apply(double value) {
//     if (_isEnabled) {
//       // Here you would apply the actual beauty filter with the given value
//       print('Applying beauty effect ${type.name} with value: $value');
//       // Example: Call your native beauty filter SDK
//       // BeautyFilterSDK.applyEffect(type, value);
//     }
//   }
//
//   bool get isEnabled => _isEnabled;
// }
//
// // beauty_filter_service.dart
// class ZegoBeautyFilterService {
//   static final ZegoBeautyFilterService _instance = ZegoBeautyFilterService._internal();
//   factory ZegoBeautyFilterService() => _instance;
//   ZegoBeautyFilterService._internal();
//
//   final Map<ZegoBeautyType, ZegoBeautyAbility> beautyAbilities = {};
//
//   void initialize() {
//     // Initialize all beauty abilities
//     for (final type in ZegoBeautyType.values) {
//       if (type == ZegoBeautyType.beautyBasicReset) continue;
//
//       beautyAbilities[type] = ZegoBeautyAbility(
//         type: type,
//         currentValue: _getDefaultValue(type),
//         minValue: _getMinValue(type),
//         maxValue: _getMaxValue(type),
//         defaultValue: _getDefaultValue(type),
//         editor: ZegoBeautyEditor(type),
//       );
//     }
//   }
//
//   double _getDefaultValue(ZegoBeautyType type) {
//     switch (type) {
//       case ZegoBeautyType.beautyBasicSmoothing:
//       case ZegoBeautyType.beautyBasicWhiten:
//       case ZegoBeautyType.beautyBasicSkinTone:
//       case ZegoBeautyType.beautyBasicRosy:
//       case ZegoBeautyType.beautyBasicSharpen:
//         return 0.0;
//       case ZegoBeautyType.beautyAdvancedFaceSlimming:
//       case ZegoBeautyType.beautyAdvancedEyesEnlarging:
//       case ZegoBeautyType.beautyAdvancedEyesBrightening:
//       case ZegoBeautyType.beautyAdvancedChinLengthening:
//       case ZegoBeautyType.beautyAdvancedMouthReshape:
//       case ZegoBeautyType.beautyAdvancedTeethWhitening:
//       case ZegoBeautyType.beautyAdvancedNoseSlimming:
//       case ZegoBeautyType.beautyAdvancedForeheadLift:
//         return 0.0;
//       default:
//         return 0.0;
//     }
//   }
//
//   double _getMinValue(ZegoBeautyType type) => 0.0;
//
//   double _getMaxValue(ZegoBeautyType type) {
//     switch (type) {
//       case ZegoBeautyType.beautyBasicSmoothing:
//       case ZegoBeautyType.beautyBasicWhiten:
//       case ZegoBeautyType.beautyBasicSkinTone:
//       case ZegoBeautyType.beautyBasicRosy:
//       case ZegoBeautyType.beautyBasicSharpen:
//         return 100.0;
//       case ZegoBeautyType.beautyAdvancedFaceSlimming:
//       case ZegoBeautyType.beautyAdvancedEyesEnlarging:
//       case ZegoBeautyType.beautyAdvancedEyesBrightening:
//       case ZegoBeautyType.beautyAdvancedChinLengthening:
//       case ZegoBeautyType.beautyAdvancedMouthReshape:
//       case ZegoBeautyType.beautyAdvancedTeethWhitening:
//       case ZegoBeautyType.beautyAdvancedNoseSlimming:
//       case ZegoBeautyType.beautyAdvancedForeheadLift:
//         return 100.0;
//       default:
//         return 100.0;
//     }
//   }
//
//   void applyBeautyEffect(ZegoBeautyType type, double value) {
//     final ability = beautyAbilities[type];
//     if (ability != null) {
//       ability.currentValue = value;
//       ability.editor.enable(true);
//       ability.editor.apply(value);
//     }
//   }
//
//   void resetAllEffects() {
//     for (final ability in beautyAbilities.values) {
//       ability.reset();
//     }
//   }
//
//   void disableAllEffects() {
//     for (final ability in beautyAbilities.values) {
//       ability.editor.enable(false);
//     }
//   }
// }
//
// // beauty_filter_widget.dart
//
// class BeautyFilterWidget extends StatefulWidget {
//   final Function(ZegoBeautyType, double)? onEffectChanged;
//   final Function()? onReset;
//
//   const BeautyFilterWidget({
//     Key? key,
//     this.onEffectChanged,
//     this.onReset,
//   }) : super(key: key);
//
//   @override
//   State<BeautyFilterWidget> createState() => _BeautyFilterWidgetState();
// }
//
// class _BeautyFilterWidgetState extends State<BeautyFilterWidget> {
//   final ZegoBeautyFilterService _beautyService = ZegoBeautyFilterService();
//   ZegoBeautyType? selectedEffectType;
//   ZegoEffectModel selectedModel = ZegoBeautyData.data()[0];
//   @override
//   void initState() {
//     super.initState();
//     ZegoEffectsPlugin.instance.create(Utils.liveAppId ?? 0, Utils.liveAppSign ?? "");
//     _beautyService.initialize();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 200,
//       decoration: const BoxDecoration(
//         color: Color(0xff222222),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//         ),
//       ),
//       child: Column(
//         children: [
//           // Handle bar
//           Container(
//             width: 30,
//             height: 4,
//             margin: const EdgeInsets.only(top: 8),
//             decoration: const BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(2)),
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 10),
//
//           // Slider
//           if (selectedEffectType != null && selectedEffectType != ZegoBeautyType.backgroundPortraitSegmentation) _buildSlider(),
//
//           // Category tabs
//           _buildCategoryTabs(),
//
//           const Divider(color: Colors.white, height: 1),
//
//           // Effect items
//           _buildEffectItems(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSlider() {
//     final ability = _beautyService.beautyAbilities[selectedEffectType!]!;
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Slider(
//         value: ability.currentValue,
//         min: ability.minValue,
//         max: ability.maxValue,
//         divisions: 100,
//         activeColor: Colors.blue,
//         inactiveColor: Colors.grey,
//         onChanged: (value) {
//           setState(() {
//             ability.currentValue = 100;
//             _beautyService.applyBeautyEffect(selectedEffectType!, 100);
//             widget.onEffectChanged?.call(selectedEffectType!, 100);
//           });
//         },
//       ),
//     );
//   }
//
//   Widget _buildCategoryTabs() {
//     return SizedBox(
//       height: 40,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: ZegoBeautyData.data().length,
//         itemBuilder: (context, index) {
//           final model = ZegoBeautyData.data()[index];
//           final isSelected = model.type == selectedModel.type;
//           return TextButton(
//             onPressed: () {
//               setState(() {
//                 selectedModel = model;
//                 selectedEffectType = null;
//               });
//             },
//             child: Text(
//               model.title,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : const Color(0xffcccccc),
//                 fontSize: isSelected ? 16 : 14,
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildEffectItems() {
//     return SizedBox(
//       height: 105,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: selectedModel.items.length,
//         itemBuilder: (context, index) {
//           final item = selectedModel.items[index];
//           final isSelected = item.type == selectedEffectType;
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedEffectType = item.type;
//               });
//               final ability = _beautyService.beautyAbilities[item.type]!;
//               ability.editor.enable(true);
//               ability.editor.apply(ability.currentValue);
//             },
//             child: Container(
//               width: 74,
//               margin: const EdgeInsets.symmetric(horizontal: 5),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       color: isSelected ? Colors.blue : Colors.grey[700],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(
//                       _getIconForType(item.type),
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     item.iconText,
//                     style: isSelected ? item.selectedTextStyle : item.textStyle,
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   IconData _getIconForType(ZegoBeautyType type) {
//     switch (type) {
//       case ZegoBeautyType.beautyBasicSmoothing:
//         return Icons.blur_on;
//       case ZegoBeautyType.beautyBasicWhiten:
//         return Icons.brightness_7;
//       case ZegoBeautyType.beautyBasicSkinTone:
//         return Icons.palette;
//       case ZegoBeautyType.beautyBasicRosy:
//         return Icons.favorite;
//       case ZegoBeautyType.beautyBasicSharpen:
//         return Icons.tune;
//       case ZegoBeautyType.beautyAdvancedFaceSlimming:
//         return Icons.face;
//       case ZegoBeautyType.beautyAdvancedEyesEnlarging:
//         return Icons.visibility;
//       case ZegoBeautyType.beautyAdvancedEyesBrightening:
//         return Icons.brightness_high;
//       case ZegoBeautyType.beautyAdvancedNoseSlimming:
//         return Icons.airline_seat_individual_suite;
//       case ZegoBeautyType.makeupLipstick:
//         return Icons.library_add;
//       case ZegoBeautyType.makeupBlusher:
//         return Icons.brush;
//       case ZegoBeautyType.makeupEyelash:
//         return Icons.remove_red_eye;
//       case ZegoBeautyType.makeupEyeliner:
//         return Icons.edit;
//       default:
//         return Icons.star;
//     }
//   }
// }
//
// // Usage example
// class Beutyfilter {
//   static Future<void> show(BuildContext context) async {
//     await showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => BeautyFilterWidget(
//         onEffectChanged: (type, value) {
//           print('Effect ${type.name} changed to $value');
//         },
//         onReset: () {
//           print('Reset all effects');
//         },
//       ),
//     );
//   }
// }
