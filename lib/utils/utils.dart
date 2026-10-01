import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/splash_screen_page/api/admin_setting_api.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/internet_connection.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

abstract class Utils {
  static RxBool isAppOpen = false.obs;

  static void showLog(String text) => print(text);
  // static void showLog(String text) => log(text);

  static RxBool isCurrentlyVideoPage = true.obs;

  static void showToast(String text, [Color? color]) {
    Fluttertoast.showToast(
      msg: text,
      backgroundColor: color ?? AppColor.primary,
      textColor: AppColor.white,
      gravity: ToastGravity.BOTTOM,
    );
  }

  static void onChangeStatusBar({required Brightness brightness, int? delay}) {
    showLog("Change Status Bar => Brightness => $brightness => $delay");
    Future.delayed(
      Duration(milliseconds: delay ?? 0),
      () => SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColor.transparent,
          statusBarIconBrightness: brightness,
          systemNavigationBarColor: AppColor.white,
          systemNavigationBarDividerColor: AppColor.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
    );
  }

  // >>>>> >>>>> Edit Profile Page <<<<< <<<<<

  static final int isShowPkEndTime = AdminSettingsApi.adminSettingModel?.data?.pkEndTime ?? 0;
  static final int isShowActionSecond = AdminSettingsApi.adminSettingModel?.data?.actionMinute ?? 0;
  static final int isShowEndActionSecond = AdminSettingsApi.adminSettingModel?.data?.actionEndMinute ?? 0;
  static final int isShowAdminFeeRate = AdminSettingsApi.adminSettingModel?.data?.adminFeeRate ?? 0;
  static final int isShowMultiplier = AdminSettingsApi.adminSettingModel?.data?.multiplier ?? 0;

  static int waterMarkSize = 25;
  static bool isShowWaterMark = AdminSettingsApi.adminSettingModel?.data?.isWatermarkOn ?? false;
  static String waterMarkIcon = AdminSettingsApi.adminSettingModel?.data?.watermarkIcon ?? "";

  static TextEditingController countryController = TextEditingController(text: "India");
  static TextEditingController flagController = TextEditingController(text: "🇮🇳");

  // >>>>> >>>>> Show Reels Effect <<<<< <<<<<

  static final bool isShowReelsEffect = AdminSettingsApi.adminSettingModel?.data?.isEffectActive ?? false;

  // >>>>> >>>>> Upload Shorts Limit <<<<< <<<<<

  static final int shortsDuration = AdminSettingsApi.adminSettingModel?.data?.durationOfShorts ?? 0;

  static final String effectAndroidLicenseKey = AdminSettingsApi.adminSettingModel?.data?.androidLicenseKey ?? "";
  static final String effectIosLicenseKey = AdminSettingsApi.adminSettingModel?.data?.iosLicenseKey ?? "";

  // >>>>> >>>>> Web View Url <<<<< <<<<<

  static final String privacyPolicyLink = AdminSettingsApi.adminSettingModel?.data?.privacyPolicyLink ?? "";
  static final String termsOfUseLink = AdminSettingsApi.adminSettingModel?.data?.termsOfUsePolicyLink ?? "";

  // >>>>> >>>>> Show Payment Method <<<<< <<<<<

  static final bool isShowStripePaymentMethod = AdminSettingsApi.adminSettingModel?.data?.stripeSwitch ?? false;
  static final bool isShowRazorPayPaymentMethod = AdminSettingsApi.adminSettingModel?.data?.razorPaySwitch ?? false;
  static final bool isShowFlutterWavePaymentMethod = AdminSettingsApi.adminSettingModel?.data?.flutterWaveSwitch ?? false;
  static final bool isShowInAppPurchasePaymentMethod = AdminSettingsApi.adminSettingModel?.data?.googlePlaySwitch ?? false;

  static final bool isShowStripeIosPaymentMethod = AdminSettingsApi.adminSettingModel?.data?.stripeIosEnabled ?? false;
  static final bool isShowRazorPayIosPaymentMethod = AdminSettingsApi.adminSettingModel?.data?.razorpayIosEnabled ?? false;
  static final bool isShowFlutterWaveIosPaymentMethod = AdminSettingsApi.adminSettingModel?.data?.flutterwaveIosEnabled ?? false;
  static final bool isShowInAppPurchaseIosPaymentMethod = AdminSettingsApi.adminSettingModel?.data?.googlePayIosEnabled ?? false;

  static final bool isShowCashFreeIosPaymentMethod = AdminSettingsApi.adminSettingModel?.data?.cashfreeIosEnabled ?? false;
  static final bool isShowCashFreePaymentMethod = AdminSettingsApi.adminSettingModel?.data?.cashfreeAndroidEnabled ?? false;

  static final bool isShowPayPalIosPaymentMethod = AdminSettingsApi.adminSettingModel?.data?.paypalIosEnabled ?? false;
  static final bool isShowPayPalPaymentMethod = AdminSettingsApi.adminSettingModel?.data?.paypalAndroidEnabled ?? false;

  static final bool isShowPayStackIosPaymentMethod = AdminSettingsApi.adminSettingModel?.data?.paystackIosEnabled ?? false;
  static final bool isShowPayStackPaymentMethod = AdminSettingsApi.adminSettingModel?.data?.paystackAndroidEnabled ?? false;

  // >>>>> >>>>> Live Streaming Credential <<<<< <<<<<

  static final String serverSecret = "";

  static final String liveAppSign = AdminSettingsApi.adminSettingModel?.data?.zegoAppSignIn ?? "";
  static final int liveAppId = int.parse(AdminSettingsApi.adminSettingModel?.data?.zegoAppId?.toString() ?? "00");

  // >>>>> >>>>> RazorPay Payment Credential <<<<< <<<<<

  static String razorpayTestKey = AdminSettingsApi.adminSettingModel?.data?.razorSecretKey ?? "";
  static String razorpayCurrencyCode = AdminSettingsApi.adminSettingModel?.data?.currency?.currencyCode ?? "";

  static String currencySymbol = AdminSettingsApi.adminSettingModel?.data?.currency?.symbol ?? "\$";

  // >>>>> >>>>> Stripe Payment Credential <<<<< <<<<<

  static const String stripeUrl = "https://api.stripe.com/v1/payment_intents";

  static String stripeMerchantCountryCode = AdminSettingsApi.adminSettingModel?.data?.currency?.countryCode ?? "";
  static String stripeCurrencyCode = AdminSettingsApi.adminSettingModel?.data?.currency?.currencyCode ?? "";
  static String stripeTestSecretKey = AdminSettingsApi.adminSettingModel?.data?.stripeSecretKey ?? "";
  static String stripeTestPublicKey = AdminSettingsApi.adminSettingModel?.data?.stripePublishableKey ?? "";

  // >>>>> >>>>> Flutter Wave Credential <<<<< <<<<<

  static String flutterWaveId = AdminSettingsApi.adminSettingModel?.data?.flutterWaveId ?? "";
  static String flutterWaveCurrencyCode = AdminSettingsApi.adminSettingModel?.data?.currency?.currencyCode ?? "";

  // >>>>>> >>>>>> Initialize Live Steaming <<<<<< <<<<<<

  static Future<void> onInitCreateEngine() async {
    try {
      await ZegoExpressEngine.createEngineWithProfile(
        ZegoEngineProfile(
          Utils.liveAppId,
          ZegoScenario.Broadcast,
          appSign: kIsWeb ? null : Utils.liveAppSign,
        ),
      );
      ZegoVideoConfig config = ZegoVideoConfig.preset(ZegoVideoConfigPreset.Preset360P);

      ZegoExpressEngine.instance.setVideoConfig(config);
      Utils.showLog("********** Create Engine Success");
    } catch (e) {
      Utils.showLog("********** Create Engine Failed => $e");
    }
  }

  // >>>>>> >>>>>> Initialize Payment <<<<<< <<<<<<

  static Future<void> onInitPayment() async {
    if (InternetConnection.isConnect.value && Utils.stripeTestPublicKey.trim().isNotEmpty) {
      try {
        Stripe.publishableKey = Utils.stripeTestPublicKey;
        await Stripe.instance.applySettings();
        // InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
      } catch (e) {
        Utils.showLog("********** Stripe Init Failed => $e");
      }
    }
  }
}
