import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortie/custom/custom_image_picker.dart';
import 'package:shortie/custom/custom_multi_image_picker.dart';
import 'package:shortie/pages/preview_hash_tag_page/api/create_hash_tag_api.dart';
import 'package:shortie/pages/preview_hash_tag_page/api/fetch_hash_tag_api.dart';
import 'package:shortie/pages/preview_hash_tag_page/model/create_hash_tag_model.dart';
import 'package:shortie/pages/preview_hash_tag_page/model/fetch_hash_tag_model.dart';
import 'package:shortie/pages/profile_page/api/delete_content_api.dart';
import 'package:shortie/pages/splash_screen_page/api/upload_multiple_file_api.dart';
import 'package:shortie/pages/upload_post_page/api/upload_post_api.dart';
import 'package:shortie/pages/upload_post_page/model/upload_post_model.dart';
import 'package:shortie/pages/upload_reels_page/api/fetch_ai_caption_api.dart';
import 'package:shortie/pages/upload_reels_page/model/fetch_ai_caption_model.dart';
import 'package:shortie/ui/image_picker_bottom_sheet_ui.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/internet_connection.dart';
import 'package:shortie/utils/utils.dart';

class UploadPostController extends GetxController {
  List<String> selectedImages = [];
  UploadPostModel? uploadPostModel;

  bool isLoadingHashTag = false;
  List<HashTagData> hastTagCollection = [];
  List<HashTagData> filterHashtag = [];

  RxBool isShowHashTag = false.obs;
  List<String> userInputHashtag = [];

  FetchHashTagModel? fetchHashTagModel;
  CreateHashTagModel? createHashTagModel;

  TextEditingController captionController = TextEditingController();
  TextEditingController hashTagController = TextEditingController();

  String selectedAutoCaptionImagePath = "";
  String autoCaptionImageUrl = "";
  bool isPostUploadSuccess = false;

  FetchAiCaptionModel? fetchAiCaptionModel;
  bool isLoadingAiCaption = false;
  bool isAiCaptionSwitchOn = false;

  @override
  void onInit() {
    init();
    super.onInit();

    Utils.showLog("Upload Post Controller Initialized...");
  }

  @override
  void onClose() {
    onDeleteCancelContent();
    super.onClose();
  }

  Future<void> init() async {
    Utils.showLog("Selected Images Length => ${Get.arguments["images"].length}");

    if (Get.arguments["images"] != null) {
      selectedImages.addAll(Get.arguments["images"]);
    }
    onGetHashTag();
    createHashTagModel = null;

    if (selectedImages.isNotEmpty) {
      onConvertFirstImage(selectedImages[0]);
    }
  }

  void onSelectHashtag(int index) {
    String text = captionController.text;
    List<String> words = text.split(' ');
    words.removeLast();
    captionController.text = words.join(' ');
    captionController.text = captionController.text + ' ' + ("#${filterHashtag[index].hashTag} ");
    captionController.selection = TextSelection.fromPosition(TextPosition(offset: captionController.text.length));
    isShowHashTag.value = false;
    update(["onChangeHashtag"]);
  }

  void onChangeHashtag() async {
    String text = captionController.text;

    List<String> words = text.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].length > 1 && // condition 1: word length not 1
          words[i].indexOf('#') == words[i].lastIndexOf('#')) {
        // condition 2: word uses # only one time
        if (words[i].endsWith('#')) {
          words[i] = words[i].replaceFirst('#', ' #');
        }
      }
    }
    captionController.text = words.join(' ');
    captionController.selection = TextSelection.fromPosition(
      TextPosition(offset: captionController.text.length),
    );

    String updatedText = captionController.text;
    List<String> parts = updatedText.split(' ');

    // if (words.last[words.last.length - 1] == "#") {
    //   words.last[words.last.length - 1]
    // }

    // List<String> words = text.split(RegExp(r'(\s|(?=#))'));

    await 10.milliseconds.delay();

    final caption = parts.where((element) => !element.startsWith('#')).join(' ');
    userInputHashtag = parts.where((element) => element.startsWith('#')).toList();

    final lastWord = parts.last;

    Utils.showLog("Caption => ${caption}");
    Utils.showLog("Last Word => ${lastWord}");

    if (lastWord.startsWith("#")) {
      Utils.showLog("----------------------");

      final searchHashtag = lastWord.substring(1);
      filterHashtag = hastTagCollection.where((element) => (element.hashTag?.toLowerCase() ?? "").contains(searchHashtag.toLowerCase())).toList();
      isShowHashTag.value = true;
      update(["onGetHashTag"]);
    } else {
      filterHashtag.clear();
      isShowHashTag.value = false;
    }
    update(["onChangeHashtag"]);
  }

  void onToggleHashTag(bool value) {
    isShowHashTag.value = value;
  }

  Future<void> onGetHashTag() async {
    isLoadingHashTag = true;
    update(["onGetHashTag"]);
    fetchHashTagModel = await FetchHashTagApi.callApi(hashTag: "");

    if (fetchHashTagModel?.data != null) {
      hastTagCollection.clear();

      hastTagCollection.addAll(fetchHashTagModel?.data ?? []);

      Utils.showLog("Hast Tag Collection Length => ${hastTagCollection.length}");
    }
    isLoadingHashTag = false;
    update(["onGetHashTag"]);
  }

  void onSelectNewImage(BuildContext context) async {
    await ImagePickerBottomSheetUi.show(
      context: context,
      onClickGallery: () async {
        final List<String> images = await CustomMultiImagePicker.pickImage();

        if (images.isNotEmpty) {
          for (int i = 0; i < images.length; i++) {
            if (selectedImages.length < 5) {
              selectedImages.add(images[i]);
            } else {
              break;
            }
          }

          update(["onChangeImages", "onChangeAiSwitch"]);

          if (selectedImages.isNotEmpty) {
            onConvertFirstImage(selectedImages[0]);
          }
        }
      },
      onClickCamera: () async {
        final String? imagePath = await CustomImagePicker.pickImage(ImageSource.camera);
        if (imagePath != null) {
          selectedImages.add(imagePath);
          update(["onChangeImages"]);

          if (selectedImages.isNotEmpty) {
            onConvertFirstImage(selectedImages[0]);
          }
        }
      },
    );
  }

  void onConvertFirstImage(String path) async {
    if (selectedAutoCaptionImagePath != path) {
      selectedAutoCaptionImagePath = path;

      final images = await UploadMultipleFileApi.callApi(images: [path]);

      if (images?.isNotEmpty == true) {
        autoCaptionImageUrl = images?[0];
        if (isAiCaptionSwitchOn) onFetchAiCaption();
      }
    }
  }

  void onDeleteCancelContent() async {
    if (isPostUploadSuccess == false && autoCaptionImageUrl.trim().isNotEmpty == true) {
      await DeleteContentApi.callApi(fileUrl: autoCaptionImageUrl);

      Utils.showLog("Delete Content Url => $autoCaptionImageUrl");

      if (DeleteContentApi.deleteContentModel?.status == true) {
        selectedAutoCaptionImagePath = "";
        autoCaptionImageUrl = "";
      }
    }
  }

  void onChangeAiSwitch({bool? value}) async {
    isAiCaptionSwitchOn = value ?? !isAiCaptionSwitchOn;
    update(["onChangeAiSwitch"]);

    if (isAiCaptionSwitchOn) {
      onFetchAiCaption();
    } else {
      captionController.clear();
      update(["onGenerateAiCaption"]);
    }
  }

  void onFetchAiCaption() async {
    if (autoCaptionImageUrl.trim().isNotEmpty == true) {
      isLoadingAiCaption = true;
      update(["onGenerateAiCaption"]);

      fetchAiCaptionModel = await FetchAiCaptionApi.callApi(contentUrl: autoCaptionImageUrl);

      captionController.clear();

      captionController.text = ((fetchAiCaptionModel?.caption ?? "") + (fetchAiCaptionModel?.hashtags?.join(" ") ?? ""));

      isLoadingAiCaption = false;
      update(["onGenerateAiCaption"]);
    }
  }

  void onCancelImage(int index) {
    selectedImages.removeAt(index);
    update(["onChangeImages"]);
    if (index == 0) onDeleteCancelContent(); // REMOVE FIRST CONVERT URL

    if (selectedImages.isNotEmpty) {
      onConvertFirstImage(selectedImages[0]);
    } else {
      if (isAiCaptionSwitchOn) captionController.clear();
      isAiCaptionSwitchOn = false;

      update(["onChangeAiSwitch", "onChangeHashtag"]);
    }
  }

  Future<void> onUploadPost() async {
    if (selectedImages.isEmpty) {
      Utils.showToast(EnumLocal.txtPleaseSelectPost.name.tr);
    } else {
      Utils.showLog(EnumLocal.txtPostUploading.name.tr);
      if (InternetConnection.isConnect.value) {
        Get.dialog(PopScope(canPop: false, child: const LoadingUi()), barrierDismissible: false); // Start Loading...

        List<String> hashTagIds = [];

        for (int index = 0; index < userInputHashtag.length; index++) {
          final hashTag = userInputHashtag[index];

          Utils.showLog("----------${hashTag}");

          if (hashTag != "" && hashTag.startsWith("#")) {
            final searchHashtag = userInputHashtag[index].substring(1);
            createHashTagModel = null;

            final List<HashTagData> selectedHashTag = hastTagCollection.where((element) => (element.hashTag?.toLowerCase() ?? "") == searchHashtag.toLowerCase()).toList();

            Utils.showLog("**** ${selectedHashTag}");

            if (selectedHashTag.isNotEmpty) {
              hashTagIds.add(selectedHashTag[0].id ?? "");
              Utils.showLog("Already Available HashTag => ${selectedHashTag[0].hashTag} ");
            } else {
              Utils.showLog("New Create HashTag => ${userInputHashtag[index].substring(1)} ");
              createHashTagModel = await CreateHashTagApi.callApi(hashTag: userInputHashtag[index].substring(1));

              if (createHashTagModel?.data?.id != null) {
                hashTagIds.add(createHashTagModel?.data?.id ?? "");
              }
            }
          }
        }

        List<dynamic> imagesToUpload = List.from(selectedImages);

        if (autoCaptionImageUrl.trim().isNotEmpty && imagesToUpload.isNotEmpty) {
          imagesToUpload.removeAt(0);
        }

        await 200.milliseconds.delay();

        List<String> images = [];
        if (imagesToUpload.isNotEmpty) {
          final uploaded = await UploadMultipleFileApi.callApi(images: imagesToUpload);
          if (uploaded != null) {
            images.addAll(uploaded.map((e) => e.toString()));
          }
        }

        if (autoCaptionImageUrl.trim().isNotEmpty) {
          images.insert(0, autoCaptionImageUrl);
        }

        if (images.isNotEmpty) {
          uploadPostModel = await UploadPostApi.callApi(
            loginUserId: Database.loginUserId,
            hashTag: hashTagIds.map((e) => "$e").join(',').toString(),
            caption: captionController.text.trim(),
            postImages: images,
          );

          if (uploadPostModel?.status == true && uploadPostModel?.post?.id != null) {
            isPostUploadSuccess = true;
            Utils.showToast(EnumLocal.txtPostUploadSuccessfully.name.tr);
            Get.close(2);
          } else {
            Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
          }
        }

        Get.back(); // Stop Loading...
      } else {
        Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
        Utils.showLog("Internet Connection Lost !!");
      }
    }
  }
}

// >>>>>>>>>>>>>>>>>>>>>>>> Old Hashtag Function <<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//   if (selectedHashTag[index].id == null && selectedHashTag[index].hashTag != null && selectedHashTag[index].hashTag != "") {
//     createHashTagModel = await CreateHashTagApi.callApi(hashTag: selectedHashTag[index].hashTag ?? "");
//     if (createHashTagModel?.data?.id != null) {
//       hashTagIds.add(createHashTagModel?.data?.id ?? "");
//     }
//   } else {
//     hashTagIds.add(selectedHashTag[index].id ?? "");
//   }
// }
//
// Future<void> onChangeHashTag() async {
//   Utils.showLog("Typing => ${hashTagController.text}");
//
//   if (hashTagController.text.trim().isNotEmpty) {
//     Utils.showLog("Typing => ${Get.currentRoute}");
//
//     if (Get.currentRoute == "/upload_post_page") {
//       Get.to(PreviewHashTagListUi());
//     }
//
//     if (hashTagController.text.endsWith(" ")) {
//       if (hastTagCollection.isNotEmpty) {
//         final userHashTag = hashTagController.text.trim().toLowerCase();
//         final apiHashTag = hastTagCollection[0].hashTag?.toLowerCase();
//         if (userHashTag == apiHashTag) {
//           onSelectHastTag(0);
//         } else {
//           selectedHashTag.add(HashTagData(hashTag: hashTagController.text.trim()));
//           update(["onSelectHastTag"]);
//           onCloseHashTagPage();
//           Utils.showLog("Create New HashTag Success");
//         }
//       } else {
//         selectedHashTag.add(HashTagData(hashTag: hashTagController.text.trim()));
//         update(["onSelectHastTag"]);
//         onCloseHashTagPage();
//         Utils.showLog("Create New HashTag Success");
//       }
//     } else {
//       await onGetHashTag();
//     }
//   } else if (hashTagController.text.isEmpty) {
//     await onGetHashTag();
//   }
// }
//
// void onSelectHastTag(int index) {
//   selectedHashTag.add(hastTagCollection[index]);
//   update(["onSelectHastTag"]);
//   // onCloseHashTagPage();
// }
//
// void onCloseHashTagPage() async {
//   hashTagController.clear();
//   FocusManager.instance.primaryFocus?.unfocus();
//   if (Get.currentRoute == "/PreviewHashTagListUi") {
//     Get.back();
//     await 200.milliseconds.delay();
//     FocusManager.instance.primaryFocus?.unfocus();
//   }
// }
//
// void onCancelHashTag(int index) {
//   selectedHashTag.removeAt(index);
//   update(["onSelectHastTag"]);
// }
//

//
// void onSubmitHashTag() {
//   if (hashTagController.text.trim().isNotEmpty && hastTagCollection.isNotEmpty) {
//     final userHashTag = hashTagController.text.trim().toLowerCase();
//     final apiHashTag = hastTagCollection[0].hashTag?.toLowerCase();
//     if (userHashTag == apiHashTag) {
//       onSelectHastTag(0);
//     } else {
//       selectedHashTag.add(HashTagData(hashTag: hashTagController.text.trim()));
//       update(["onSelectHastTag"]);
//       onCloseHashTagPage();
//       Utils.showLog("Create New HashTag Success");
//     }
//   } else if (hashTagController.text.trim().isNotEmpty && hastTagCollection.isEmpty) {
//     selectedHashTag.add(HashTagData(hashTag: hashTagController.text.trim()));
//     update(["onSelectHastTag"]);
//     onCloseHashTagPage();
//     Utils.showLog("Create New HashTag Success");
//   }
// }

//---------------------------------------------------------
// if (selectedHashTag.contains(hastTagCollection[index])) {
//   selectedHashTag.remove(hastTagCollection[index]);
//   update(["onSelectHastTag"]);
// } else {
//
// }

//  Future<void> onToggleHashTag(bool value) async {
//     isShowHashTag = value;
//     update(["onToggleHashTag"]);
//
//     if (value) {
//       onGetHashTag();
//       FocusManager.instance.primaryFocus?.unfocus();
//       Get.to(PreviewHashTagListUi());
//     }
//   }

// Future<void> onCreateHashTag() async {
//   FocusManager.instance.primaryFocus?.unfocus();
//
//   Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
//
//   createHashTagModel = await CreateHashTagApi.callApi(hashTag: hashTagController.text.trim());
//   if (createHashTagModel?.data?.id != null) {
//     Utils.showLog("Create Hast Tag Success ${createHashTagModel?.data?.id}");
//
//     selectedHashTag.add(
//       HashTagData(
//         id: createHashTagModel?.data?.id,
//         hashTag: createHashTagModel?.data?.hashTag,
//       ),
//     );
//     update(["onSelectHastTag"]);
//
//     hashTagController.clear();
//   }
//   Get.back(); // Stop Loading...
// }
