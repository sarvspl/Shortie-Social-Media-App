import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/localization/localization_service.dart';
import 'package:shortie/localization/models/language_info.dart';
import 'package:shortie/pages/language_page/api/fetch_language_api.dart';
import 'package:shortie/pages/language_page/model/fetch_language_model.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/database.dart';

class LanguageController extends GetxController {
  LanguageInfo? languageInfo;
  String? languageCode;
  String? countryCode;

  // Pagination state
  RxList<LanguageInfo> languages = <LanguageInfo>[].obs;
  RxBool isLoading = false.obs;
  RxBool isMoreLoading = false.obs;
  
  int start = 1;
  int limit = 20;
  bool hasMore = true;

  FetchLanguageModel? fetchLanguageModel;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    init();
    scrollController.addListener(_onScroll);
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100) {
      loadMoreLanguages();
    }
  }

  final List countryFlags = [
    AppAsset.icArabia,
    AppAsset.icBangladesh,
    AppAsset.icChinese,
    AppAsset.icUnitedStates,
    AppAsset.icFrance,
    AppAsset.icGermany,
    AppAsset.icIndia,
    AppAsset.icItalian,
    AppAsset.icIndonesia,
    AppAsset.icJapan,
    AppAsset.icKorean,
    AppAsset.icIndia,
    AppAsset.icBrazil,
    AppAsset.icRussian,
    AppAsset.icSpain,
    AppAsset.icSwahili,
    AppAsset.icTurkey,
    AppAsset.icIndia,
    AppAsset.icIndia,
    AppAsset.icPakistan,
  ];

  void init() async {
    languageCode = Database.selectedLanguage;
    countryCode = Database.selectedCountryCode;

    await fetchInitialLanguages();

    if (languages.isNotEmpty) {
      try {
        languageInfo = languages.firstWhere((element) => element.code == languageCode, orElse: () => languages.first);
      } catch (e) {
        languageInfo = languages.first;
      }
    }
    update(["onChangeLanguage"]);
  }

  Future<void> fetchInitialLanguages() async {
    try {
      isLoading.value = true;
      start = 1;
      hasMore = true;
      languages.clear();

      fetchLanguageModel = await FetchLanguageApi.callApi(start: start, limit: limit);

      if (fetchLanguageModel?.data != null && (fetchLanguageModel?.data?.isNotEmpty ?? false)) {
        languages.addAll(fetchLanguageModel!.data!);
        
        if (fetchLanguageModel!.data!.length < limit) {
          hasMore = false;
        }
      } else {
        hasMore = false;
      }
    } catch (e) {
      print("Fetch Initial Languages Failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreLanguages() async {
    if (isMoreLoading.value || !hasMore || isLoading.value) return;

    try {
      isMoreLoading.value = true;
      start += limit;

      fetchLanguageModel = await FetchLanguageApi.callApi(start: start, limit: limit);

      if (fetchLanguageModel?.data != null && (fetchLanguageModel?.data?.isNotEmpty ?? false)) {
        languages.addAll(fetchLanguageModel!.data!);
        
        if (fetchLanguageModel!.data!.length < limit) {
          hasMore = false;
        }
      } else {
        hasMore = false;
      }
    } catch (e) {
      print("Load More Languages Failed: $e");
      start -= limit;
    } finally {
      isMoreLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    await fetchInitialLanguages();
  }

  void onChangeLanguage(LanguageInfo value) async {
    languageInfo = value;

    // Fallback country code if not available in LanguageInfo
    final targetCountryCode = "US"; // Assuming US/EN default for now, can be improved

    Database.onSetSelectedLanguage(languageInfo!.code);
    Database.onSetSelectedCountryCode(targetCountryCode);

    final localizationService = Get.find<LocalizationService>();
    await localizationService.switchLanguage(languageInfo!.code, targetCountryCode);

    update(["onChangeLanguage"]);
  }
}

