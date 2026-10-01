import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortie/custom/custom_image_picker.dart';
import 'package:shortie/pages/edit_profile_page/api/edit_profile_api.dart';
import 'package:shortie/pages/edit_profile_page/model/edit_profile_model.dart';
import 'package:shortie/pages/splash_screen_page/api/check_user_name_api.dart';
import 'package:shortie/pages/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:shortie/pages/splash_screen_page/api/upload_file_api.dart';
import 'package:shortie/pages/splash_screen_page/model/check_user_name_model.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/ui/image_picker_bottom_sheet_ui.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/internet_connection.dart';
import 'package:shortie/utils/utils.dart';

class FillProfileController extends GetxController {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController idCodeController = TextEditingController();
  TextEditingController bioDetailsController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  Map<String, String> selectedCountry = {"flag": "🇮🇳", "name": "India"};

  String selectedGender = "male";

  EditProfileModel? editProfileModel;

  String profileImage = "";

  String? pickImage;

  bool? isValidUserName;
  RxBool isCheckingUserName = false.obs;
  CheckUserNameModel? checkUserNameModel;

  int randomNumber = 00;

  /// Guard against double-tap on the Save button
  bool _isSaving = false;

  /// Debounce timer — cancels a pending username check when the user keeps typing
  Timer? _userNameDebounce;

  @override
  void onInit() {
    super.onInit();
    init(); // intentionally not awaited here; loading indicator on suffixIcon handles UX
  }

  Future<void> init() async {
    final profile = Database.fetchLoginUserProfileModel?.user;

    profileImage = profile?.image ?? "";
    fullNameController = TextEditingController(text: profile?.name ?? "");
    userNameController = TextEditingController(text: profile?.userName ?? "");
    idCodeController = TextEditingController(text: profile?.uniqueId ?? "");
    bioDetailsController = TextEditingController(text: profile?.bio ?? "");
    mobileController = TextEditingController(text: profile?.mobileNumber ?? "");
    selectedGender = profile?.gender?.toLowerCase() ?? "male";

    selectedCountry = {
      "flag": (profile?.countryFlagImage == null || profile?.countryFlagImage == "") ? "🇮🇳" : profile!.countryFlagImage!,
      "name": (profile?.country == null || profile?.country == "") ? "India" : profile!.country!,
    };

    // Verify the pre-filled username on page load
    await onChangeUserName();
  }

  Future<void> onPickImage(BuildContext context) async {
    await ImagePickerBottomSheetUi.show(
      context: context,
      onClickCamera: () async {
        final imagePath = await CustomImagePicker.pickImage(ImageSource.camera);

        if (imagePath != null) {
          pickImage = imagePath;
          update(["onPickImage"]);
        }
      },
      onClickGallery: () async {
        final imagePath = await CustomImagePicker.pickImage(ImageSource.gallery);

        if (imagePath != null) {
          pickImage = imagePath;
          update(["onPickImage"]);
        }
      },
    );
  }

  /// Called on every keystroke. Debounced so only the last call after 600 ms fires.
  Future<void> onChangeUserName() async {
    // Cancel any pending debounce timer
    _userNameDebounce?.cancel();

    if (userNameController.text.trim().isEmpty) {
      isValidUserName = false;
      isCheckingUserName.value = false;
      return;
    }

    // Capture the value at the time this call was made
    final String nameToCheck = userNameController.text.trim();

    // Debounce: wait 600 ms; if text changes again before that, this call is cancelled
    final completer = Completer<void>();
    _userNameDebounce = Timer(const Duration(milliseconds: 600), () => completer.complete());
    await completer.future;

    // After the debounce, make sure the field still contains the same text
    if (userNameController.text.trim() != nameToCheck) return;

    isCheckingUserName.value = true;
    checkUserNameModel = await CheckUserNameApi.callApi(
      loginUserId: Database.loginUserId,
      userName: nameToCheck,
    );
    isValidUserName = checkUserNameModel?.status ?? false;
    isCheckingUserName.value = false;
  }

  Future<void> onChangeGender(String gender) async {
    selectedGender = gender;
    update(["onChangeGender"]);
  }

  Future<void> onChangeCountry(Map<String, String> country) async {
    selectedCountry = country;
    update(["onChangeCountry"]);

    Utils.showLog("Selected Country => $selectedCountry");
  }

  Future<void> onSaveProfile() async {
    // ── Double-tap guard ──────────────────────────────────────────────────────
    if (_isSaving) return;

    FocusManager.instance.primaryFocus?.unfocus();

    // ── Basic field validation ────────────────────────────────────────────────
    if (fullNameController.text.trim().isEmpty) {
      Utils.showToast(EnumLocal.txtPleaseEnterFullName.name.tr);
      return;
    }
    if (userNameController.text.trim().isEmpty) {
      Utils.showToast(EnumLocal.txtPleaseEnterUserName.name.tr);
      return;
    }

    // ── Wait for any in-progress check to finish ──────────────────────────────
    if (isCheckingUserName.value) {
      Utils.showToast("Please wait while we verify your username…");
      return;
    }

    // ── Double-verify username right before submitting ────────────────────────
    Utils.showLog("FillProfile — double-verifying username before save");
    await onChangeUserName();

    if (isValidUserName == false) {
      Utils.showToast("This username is already taken by another user.");
      return;
    }

    // ── All checks passed — proceed with save ─────────────────────────────────
    if (!InternetConnection.isConnect.value) {
      Utils.showToast(EnumLocal.txtConnectionLost.name.tr);
      Utils.showLog("Internet Connection Lost !!");
      return;
    }

    _isSaving = true;
    try {
      Get.dialog(PopScope(canPop: false, child: const LoadingUi()), barrierDismissible: false);

      if (pickImage != null) {
        final imageUrl = await UploadFileApi.callApi(
          filePath: pickImage ?? "",
          fileType: 1,
          keyName: "${DateTime.now().millisecondsSinceEpoch}.jpg",
        );

        if (imageUrl != null) {
          Utils.showLog("Edit Image Url => $imageUrl");
          await callEditApi(image: imageUrl);
        } else {
          Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
        }
      } else {
        await callEditApi();
      }
    } finally {
      _isSaving = false;
    }
  }

  Future<void> callEditApi({String? image}) async {
    editProfileModel = await EditProfileApi.callApi(
      image: image,
      loginUserId: Database.loginUserId,
      name: fullNameController.text,
      userName: userNameController.text,
      country: Utils.countryController.text,
      bio: bioDetailsController.text,
      gender: selectedGender,
      countryFlagImage: Utils.flagController.text,
    );
    Get.back(); // Stop Loading...
    if (editProfileModel?.status == true && editProfileModel?.user?.name != null) {
      Utils.showToast(EnumLocal.txtProfileUpdateSuccessfully.name.tr);

      Get.offAllNamed(AppRoutes.bottomBarPage);

      Database.fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(loginUserId: Database.loginUserId);
    } else {
      Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
    }
  }
}
