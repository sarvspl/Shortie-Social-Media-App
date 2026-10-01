import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shortie/localization/default_translations.dart';
import 'package:shortie/localization/models/language_info.dart';
import 'package:shortie/localization/models/language_model.dart';
import 'package:shortie/localization/models/localization_version.dart';
import 'package:shortie/pages/language_page/model/fetch_language_model.dart';
import 'package:shortie/utils/api.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/utils.dart';

class LocalizationService extends GetxService {
  final _storage = GetStorage();
  final String _versionKey = 'lang_version';
  final String _langDataPrefix = 'lang_data_';
  final String _langListKey = 'supported_langs_list';

  List<LanguageInfo> supportedLanguages = [];

  /// Returns the language code of the language marked as default (isDefault == true).
  /// Falls back to the first language in the list, or empty string if list is empty.
  String get defaultLanguageCode {
    if (supportedLanguages.isEmpty) return '';
    try {
      return supportedLanguages.firstWhere((l) => l.isDefault).code;
    } catch (_) {
      return supportedLanguages.first.code;
    }
  }

  Future<LocalizationService> init() async {
    log("message>>>>>>>LocalizationService>>>>");
    // 1. Load cached supported languages list so UI has them immediately
    _loadCachedLanguageList();

    // 2. Instantly load cached translations so UI doesn't delay
    _loadCachedTranslations();

    // 3. Detect first launch using the version key.
    //    _versionKey is only written after a successful full sync, so null = first launch.
    //    NOTE: init() runs before runApp(), so Get.updateLocale() here has no effect.
    //    fetchAndCacheLanguage() handles the locale refresh after translations are loaded.
    String currentLang = Get.locale?.languageCode ?? Database.selectedLanguage;
    final bool isFirstLaunch = _storage.read(_versionKey) == null || _storage.read(_langDataPrefix + currentLang) == null;
    if (isFirstLaunch) {
      // Await so translations are fetched & injected before runApp() is called
      await syncTranslations();
    } else {
      syncTranslations(); // background update on subsequent launches
    }

    return this;
  }

  /// Instantly load translations from GetStorage into GetX memory
  void _loadCachedTranslations() {
    Get.appendTranslations({
      'en_US': Map<String, String>.from(defaultEnglishTranslations),
      'en': Map<String, String>.from(defaultEnglishTranslations),
    });

    String langCode = Get.locale?.languageCode ?? Database.selectedLanguage;
    String countryCodeVal = Get.locale?.countryCode ?? Database.selectedCountryCode;
    String localeKey = "${langCode}_$countryCodeVal";

    var cachedData = _storage.read(_langDataPrefix + langCode);
    if (cachedData != null) {
      try {
        log("message>>>>> cached data$cachedData");
        // The cached data is expected to be the full JSON map of LanguageModel
        final languageModel = LanguageModel.fromJson(cachedData);

        // Inject dynamically into GetX
        Get.appendTranslations({localeKey: languageModel.translations});
        Utils.showLog("Loaded $langCode from GetStorage Cache");
      } catch (e) {
        Utils.showLog("Failed to parse cached translations for $langCode: $e");
      }
    }
  }

  void _loadCachedLanguageList() {
    log("supportedLanguages>>>>>>>_langListKey${_langListKey}");

    var cachedData = _storage.read(_langListKey);
    log("supportedLanguages>>>>>>>${cachedData}");

    if (cachedData != null && cachedData is List) {
      try {
        supportedLanguages = cachedData.map((e) => LanguageInfo.fromJson(e)).toList();
        log("supportedLanguages>>>>>>>${supportedLanguages}");
      } catch (e) {
        Utils.showLog("Failed to load cached language list: $e");
      }
    }
  }

  /// Check version and fetch new maps if necessary
  Future<void> syncTranslations() async {
    try {
      log("syncTranslations>>>>>${Api.fetchLatestLanguageVersion}");
      final versionRes = await http.get(Uri.parse(Api.fetchLatestLanguageVersion), headers: {"key": Api.secretKey});
      log("versionRes>>>>>${versionRes.body}");
      if (versionRes.statusCode == 200) {
        final versionData = LocalizationVersion.fromJson(jsonDecode(versionRes.body));
        log("Version Data> $versionData");
        final onlineVersion = versionData.version;
        final localVersion = _storage.read(_versionKey);
        log("Local Version> $localVersion");
        log("Online Version> $onlineVersion");

        /// Fetch supported languages list todo for this if version not update then uncomment below lines
        // await fetchSupportedLanguages();
        // String currentLang = Get.locale?.languageCode ?? 'en';
        // await fetchAndCacheLanguage(currentLang);
        // Even if versions match, if we have no supported languages in cache we must fetch them
        if (localVersion != onlineVersion || supportedLanguages.isEmpty) {
          Utils.showLog("New language data found or missing. Updating...");

          await fetchSupportedLanguages();

          // Fetch the default language first (isDefault == true) as the fallback locale
          final String defCode = defaultLanguageCode;
          if (defCode.isNotEmpty) {
            await fetchAndCacheLanguage(defCode);
          }

          // Also fetch the currently selected language if it differs from the default
          String currentLang = Get.locale?.languageCode ?? Database.selectedLanguage;
          if (currentLang.isNotEmpty && currentLang != defCode) {
            await fetchAndCacheLanguage(currentLang);
          }

          _storage.write(_versionKey, onlineVersion);
        } else {
          // Version matches — but check if default language cache is missing (edge case on first login)
          final String defCode = defaultLanguageCode;
          if (defCode.isNotEmpty && _storage.read(_langDataPrefix + defCode) == null) {
            await fetchAndCacheLanguage(defCode);
          }

          String currentLang = Get.locale?.languageCode ?? Database.selectedLanguage;
          if (currentLang.isNotEmpty && currentLang != defCode && _storage.read(_langDataPrefix + currentLang) == null) {
            await fetchAndCacheLanguage(currentLang);
          }
        }
      }
    } catch (e) {
      Utils.showLog("Translation sync failed: $e (Using fallbacks)");
    }
  }

  Future<void> fetchSupportedLanguages() async {
    try {
      final url = "${Api.fetchLanguages}?start=1&limit=20";
      final res = await http.get(Uri.parse(url), headers: {"key": Api.secretKey});

      if (res.statusCode == 200) {
        final fetchLanguageModel = FetchLanguageModel.fromJson(jsonDecode(res.body));

        if (fetchLanguageModel.data != null && (fetchLanguageModel.data?.isNotEmpty ?? false)) {
          supportedLanguages = fetchLanguageModel.data!;
          _storage.write(_langListKey, supportedLanguages.map((e) => e.toJson()).toList());
          Utils.showLog("Successfully downloaded first page of languages. Count: ${supportedLanguages.length}");
        }

        print("Translation debug: Successfully fetched active languages");
      } else {
        print("Translation debug: Failed to fetch active languages: ${res.statusCode}");
      }
    } catch (e) {
      Utils.showLog("Failed to fetch supported languages: $e");
      print("Translation debug: Exception fetching active languages: $e");
    }
  }

  /// Download specific language from API and inject into GetX
  Future<void> fetchAndCacheLanguage(String langCode) async {
    try {
      final res = await http.get(Uri.parse("${Api.fetchLanguageTranslations}?languageCode=$langCode&module=app"), headers: {"key": Api.secretKey});
      log("Fetched language translations>>>> request > ${res.request}");
      log("Fetched language translations>>> headers > ${res.headers}");
      if (res.statusCode == 200) {
        final rawJson = jsonDecode(res.body);
        final languageModel = LanguageModel.fromJson(rawJson);
        log("Fetched language translations> ${languageModel.toJson()}");
        // 1. Save to GetStorage for future app launches
        _storage.write(_langDataPrefix + langCode, languageModel.toJson());

        // 2. Inject into GetX memory
        String localeKey = "${langCode}_${Get.locale?.countryCode ?? Database.selectedCountryCode}";
        Get.appendTranslations({
          localeKey: languageModel.translations,
        });

        // 3. Update global version key if version is present in model
        if (languageModel.version.isNotEmpty) {
          _storage.write(_versionKey, languageModel.version);
        }

        // 4. Force UI refresh
        if (Get.locale?.languageCode == langCode) {
          Get.updateLocale(Get.locale!);
        }
        Utils.showLog("Successfully downloaded & applied $langCode");
        print("Translation debug: Successfully downloaded translations for $langCode");
      } else {
        print("Translation debug: Failed to fetch translation $langCode: ${res.statusCode}");
      }
    } catch (e) {
      Utils.showLog("Failed to fetch langCode $langCode: $e");
      print("Translation debug: Exception fetching translations $langCode: $e");
    }
  }

  /// Call this when the user manually changes the language in app settings
  Future<void> switchLanguage(String langCode, String countryCode) async {
    Locale newLocale = Locale(langCode, countryCode);

    // Check if we have this language cached
    var cachedData = _storage.read(_langDataPrefix + langCode);

    if (cachedData == null) {
      await fetchAndCacheLanguage(langCode);
    }

    Get.updateLocale(newLocale);
    _loadCachedTranslations();
  }
}
