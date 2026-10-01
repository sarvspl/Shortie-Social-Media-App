import 'package:get/get.dart';
import 'package:shortie/pages/splash_screen_page/api/admin_setting_api.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/utils.dart';

/// razor pay payment
Future<void> razorPay({
  required num amount,
  required Function() onPaymentSuccess,
}) async {
  Utils.showLog("Razorpay Payment (Incodes) starting...");
  Utils.showLog("Razorpay Payment (Incodes) starting...$amount");

  try {
    final razorKey = AdminSettingsApi.adminSettingModel?.data?.razorSecretKey ?? '';
    final email = Database.fetchLoginUserProfileModel?.user?.email;
    // Utils.showLog("customerName>>>>>>>>>>>>>>>>>>>>>>$customerName");
    Utils.showLog("email>>>>>>>>>>>>>>>>>>>>>>$email");
    Utils.showLog("Database.email>>>>>>>>>>>>>>>>>>>>>>${email}");
    final currency = AdminSettingsApi.adminSettingModel?.data?.currency?.currencyCode ?? "USD";

    // final contact = (Database.getUserProfileResponseModel?.user?.phoneNumber ??
    //     Database.getUserProfileResponseModel?.user?.phoneNumber ??
    //     "+91-0000000000");

    String toHex6(int argb) {
      final hex8 = argb.toRadixString(16).padLeft(8, '0');
      return '#${hex8.substring(2)}';
    }

    Utils.showLog("amount.toDouble()${amount.toDouble()}");
    final appName = EnumLocal.txtAppName.name.tr;
    final hexColor = toHex6(AppColor.primary.hashCode);
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("RazorPay Payment Failed => $e");
  }
}

/// stripe payment
Future<void> stripe({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  try {
    Utils.showLog("Stripe Payment (Incodes) starting...");

    final publishableKey = AdminSettingsApi.adminSettingModel?.data?.stripePublishableKey ?? "";

    final secretKey = AdminSettingsApi.adminSettingModel?.data?.stripeSecretKey ?? "";

    final currency = AdminSettingsApi.adminSettingModel?.data?.currency?.currencyCode ?? "INR";

    final merchantDisplayName = EnumLocal.txtAppName.name.tr;

    final merchantCountryCode = "IN";
    // final merchantCountryCode1 = AdminSettingsApi.adminSettingModel?.data?.currency?.currencyCode ?? "IN";

    final int minorAmount = (amount * 100).toInt();

    Utils.showLog("Stripe payment flow finished (returned).");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("Stripe Payment Failed !! => $e");
  }
}

/// flutter wave payment
Future<void> flutterWave({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("Flutterwave Payment (Incodes) starting...");
  try {
    Get.dialog(LoadingUi(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final settingsKey = AdminSettingsApi.adminSettingModel?.data?.flutterWaveId;
    final publicKey = (settingsKey != null && settingsKey.isNotEmpty) ? settingsKey : "";

    // final currency =  "NGN";
    final currency = AdminSettingsApi.adminSettingModel?.data?.currency?.currencyCode ?? "NGN";
    final customerName = Database.fetchLoginUserProfileModel?.user?.name ?? "User";
    final customerEmail = Database.fetchLoginUserProfileModel?.user?.email ?? "email";

    Utils.showLog("customerName>>>>>>>>>>>>>>>>>>>>>>$customerName");
    Utils.showLog("customerEmail>>>>>>>>>>>>>>>>>>>>>>$customerEmail");
    Utils.showLog("currency>>>>>>>>>>>>>>>>>>>>>>$currency");
    Utils.showLog("publicKey>>>>>>>>>>>>>>>>>>>>>>$publicKey");

    Utils.showLog("Flutterwave payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("Flutterwave Payment Failed => $e");
  }
}

String getValidEmail(String? customerEmail) {
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$');

  if (customerEmail != null && emailRegex.hasMatch(customerEmail)) {
    return customerEmail;
  } else {
    return "test@gmail.com";
  }
}

///pay stack payment
Future<void> payStack({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("Paystack Payment (Incodes) starting...");

  try {
    Get.dialog(const LoadingUi(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    // final settingsSecret =
    //     GetSettingApi.getSettingModel?.data?.flutterwaveId;
    // final secretKey = (settingsSecret != null && settingsSecret.isNotEmpty)
    //     ? settingsSecret
    //     : "";
    final settingsSecret = AdminSettingsApi.adminSettingModel?.data?.paystackSecretKey;

    final customerEmail = Database.fetchLoginUserProfileModel?.user?.email ?? "test@gmail.com";

    final currency = AdminSettingsApi.adminSettingModel?.data?.currency?.currencyCode ?? "NGN";

    final int majorAmount = amount.toInt();
    String email = getValidEmail(customerEmail);

    Utils.showLog("Paystack payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("Paystack Payment Failed => $e");
  }
}

///pay pal payment
Future<void> payPal({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("PayPal Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingUi(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final currency = AdminSettingsApi.adminSettingModel?.data?.currency?.currencyCode ?? "USD";
    // final currency = "USD";

    final paypalClientId = AdminSettingsApi.adminSettingModel?.data?.paypalClientId;
    final secretKey = AdminSettingsApi.adminSettingModel?.data?.paypalSecretKey;

    Utils.showLog("PayPal payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("PayPal Payment Failed => $e");
  }
}

///in app purchase payment
Future<void> inAppPurchase({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("InAppPurchase Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingUi(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final productId = "com.android.coin100";
    final userId = Database.fetchLoginUserProfileModel?.user?.id.toString() ?? "123456";

    Utils.showLog("InAppPurchase payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("InAppPurchase Payment Failed => $e");
  }
}

///cash free payment
Future<void> cashFree({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("CashFree Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingUi(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final customerName = Database.fetchLoginUserProfileModel?.user?.name ?? "John";
    final customerEmail = Database.fetchLoginUserProfileModel?.user?.email ?? "test@gmail.com";
    // final customerPhone =
    //     Database.fetchLoginUserProfileModel?.user?.phoneNumber ?? "9876543210";

    Utils.showLog("Database.getUserProfileResponseModel?.user?.phoneNumber${9876543210}");

    final cashfreeClientId = AdminSettingsApi.adminSettingModel?.data?.cashfreeClientId;
    final cashfreeSecretKey = AdminSettingsApi.adminSettingModel?.data?.cashfreeClientSecret;

// final currency ="INR";
    final currency = AdminSettingsApi.adminSettingModel?.data?.currency?.currencyCode ?? "INR";

    Utils.showLog("CashFree payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("CashFree Payment Failed => $e");
  }
}
