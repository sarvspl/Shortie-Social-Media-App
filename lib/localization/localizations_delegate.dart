import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shortie/localization/default_translations.dart';
import 'package:shortie/localization/models/language_info.dart';
import 'package:shortie/localization/models/language_model.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/utils.dart';

class AppLanguages extends Translations {
  final box = GetStorage();
  final String _langDataPrefix = 'lang_data_';
  final String _langListKey = 'supported_langs_list';

  /// Returns the code of the language marked as default (isDefault == true).
  String get _defaultLangCode {
    final cachedList = box.read(_langListKey);
    if (cachedList != null && cachedList is List) {
      try {
        final langs = cachedList.map((e) => LanguageInfo.fromJson(e)).toList();
        final def = langs.cast<LanguageInfo?>().firstWhere(
          (l) => l?.isDefault == true,
          orElse: () => langs.isNotEmpty ? langs.first : null,
        );
        return def?.code ?? 'en';
      } catch (_) {}
    }
    return 'en';
  }

  @override
  Map<String, Map<String, String>> get keys {
    Map<String, Map<String, String>> translationsMap = {
      'en_US': Map<String, String>.from(defaultEnglishTranslations),
      'en': Map<String, String>.from(defaultEnglishTranslations),
    };

    // 1. Load Default Language (isDefault == true) as fallback
    final String defCode = _defaultLangCode;
    if (defCode.isNotEmpty) {
      var defData = box.read(_langDataPrefix + defCode);
      if (defData != null) {
        try {
          final languageModel = LanguageModel.fromJson(defData);
          // Use the default language as the fallback locale key
          translationsMap['${defCode}_US'] = {
            ...translationsMap['en_US'] ?? {},
            ...languageModel.translations,
          };
        } catch (e) {
          Utils.showLog("Failed to parse cached translations for default ($defCode): $e");
        }
      }
    }

    // 2. Load Current Selected Language
    String currentLang = Get.locale?.languageCode ?? Database.selectedLanguage;
    String currentCountry = Get.locale?.countryCode ?? Database.selectedCountryCode;
    String localeKey = "${currentLang}_$currentCountry";

    if (currentLang.isNotEmpty) {
      var langData = box.read(_langDataPrefix + currentLang);
      if (langData != null) {
        try {
          final languageModel = LanguageModel.fromJson(langData);
          translationsMap[localeKey] = {
            ...translationsMap['en_US'] ?? {},
            ...languageModel.translations,
          };
        } catch (e) {
          Utils.showLog("Failed to parse cached translations for $localeKey: $e");
        }
      }
    }

    return translationsMap;
  }
}

