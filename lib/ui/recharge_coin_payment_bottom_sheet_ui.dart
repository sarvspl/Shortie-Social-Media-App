import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/payment_page/api/create_coin_plan_history_api.dart';
import 'package:shortie/pages/payment_page/payment/in_app_purchase/iap_callback.dart';
import 'package:shortie/pages/payment_page/payment/in_app_purchase/in_app_purchase_helper.dart';
import 'package:shortie/pages/payment_page/payment/razor_pay/razor_pay_view.dart';
import 'package:shortie/pages/payment_page/payment/stripe/stripe_service.dart';
import 'package:shortie/pages/payment_page/widget/payment_widget.dart';
import 'package:shortie/ui/app_button_ui.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/common_payment.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';
import 'package:shortie/utils/utils.dart';

class RechargeCoinPaymentBottomSheetUi implements IAPCallback {
  List paymentMethodList = [
    Platform.isIOS ? {"icon": AppAsset.icAppleLogo, "title": "In-App Purchase", "size": "27.0"} : {"icon": AppAsset.icGoogleLogo, "title": "Google Pay", "size": "27.0"},
    {"icon": AppAsset.icRazorPayLogo, "title": "Razor Pay", "size": "35.0"},
    {"icon": AppAsset.icStripeLogo, "title": "Stripe", "size": "35.0"},
    {"icon": AppAsset.icFlutterWaveLogo, "title": "Flutter Wave", "size": "30"},
    {"icon": AppAsset.payPalImage, "title": "Pay Pal", "size": "30"},
    {"icon": AppAsset.payStackImage, "title": "Pay Stack", "size": "30"},
    {"icon": AppAsset.cashFreeImage, "title": "Cash Free", "size": "30"},
  ];

  String coinPlanId = "";
  num coinAmount = 0;
  String productKey = "";
  Map<String, PurchaseDetails>? purchases;

  static RxInt selectedPaymentMethod = 0.obs;
  static void onChangePaymentMethod(int index) async => selectedPaymentMethod.value = index;

  Future<void> onClickPayNow() async {
    // >>>>> >>>>> >>>>> In App Purchase Payment <<<<< <<<<< <<<<<

    if (selectedPaymentMethod == 0) {
      // List<String> kProductIds = <String>[productKey];

      Utils.showLog("Starting IAP with product: $productKey");

      // await InAppPurchaseHelper().init(
      //   paymentType: "In App Purchase",
      //   userId: Database.loginUserId,
      //   productKey: kProductIds,
      //   rupee: coinAmount.toDouble(),
      //   callBack: () async {
      //     Utils.showLog("In App Purchase Payment Successfully");
      //     // This callback is called from InAppPurchaseHelper
      //     // The actual API call will be made in onSuccessPurchase method below
      //   },
      // );

      inAppPurchase(
        amount: coinAmount,
        onPaymentSuccess: () async {
          Utils.showLog("In App Purchase Payment Successfully");
          // This callback is called from InAppPurchaseHelper
          // The actual API call will be made in onSuccessPurchase method below
        },
      );

      // Add debug logging
      // await InAppPurchaseHelper().debugProductLoading();

      InAppPurchaseHelper().initStoreInfo();
      await Future.delayed(const Duration(seconds: 3)); // Increased delay

      ProductDetails? product = InAppPurchaseHelper().getProductDetail(productKey);

      if (product != null) {
        Utils.showLog("Product found: ${product.title} - ${product.price}");
        InAppPurchaseHelper().buySubscription(product, purchases!);
      } else {
        Utils.showToast("Product not found: $productKey");
        // Utils.showLog("Available products: ${InAppPurchaseHelper().getAvailableProducts()}");
      }
    }

    // >>>>> >>>>> >>>>> RazorPay Payment <<<<< <<<<< <<<<<

    if (selectedPaymentMethod == 1) {
      Utils.showLog("Razorpay Payment Working....");

      try {
        Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
        // RazorPayService().init(
        //   razorKey: Utils.razorpayTestKey,
        //   callback: () async {
        //     Utils.showLog("RazorPay Payment Successfully");
        //
        //     Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
        //     final isSuccess = await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "Razorpay");
        //     Get.back(); // Stop Loading...
        //     if (isSuccess) {
        //       Utils.showToast(EnumLocal.txtCoinRechargeSuccess.name.tr);
        //       Get.close(1);
        //     } else {
        //       Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
        //     }
        //   },
        // );

        razorPay(
          amount: coinAmount,
          onPaymentSuccess: () async {
            Utils.showLog("RazorPay Payment Successfully");

            Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
            final isSuccess = await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "Razorpay");
            Get.back(); // Stop Loading...
            if (isSuccess) {
              Utils.showToast(EnumLocal.txtCoinRechargeSuccess.name.tr);
              Get.close(1);
            } else {
              Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
            }
          },
        );
        await 1.seconds.delay();
        RazorPayService().razorPayCheckout((coinAmount * 100).toInt());
        Get.back(); // Stop Loading...
      } catch (e) {
        Get.back(); // Stop Loading...
        Utils.showLog("RazorPay Payment Failed => $e");
      }
    }

    // >>>>> >>>>> >>>>> Stripe Payment <<<<< <<<<< <<<<<

    if (selectedPaymentMethod == 2) {
      try {
        Utils.showLog("Stripe Payment Working...");
        Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
        await StripeService().init(isTest: true);
        await 1.seconds.delay();
        // StripeService()
        //     .stripePay(
        //   amount: (coinAmount * 100).toInt(),
        //   callback: () async {
        //     Utils.showLog("Stripe Payment Success Method Called....");
        //     Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
        //     final isSuccess = await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "Stripe");
        //     Get.back(); // Stop Loading...
        //     if (isSuccess) {
        //       Utils.showToast(EnumLocal.txtCoinRechargeSuccess.name.tr);
        //       Get.close(1);
        //     } else {
        //       Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
        //     }
        //   },
        // )

        stripe(
          amount: coinAmount,
          onPaymentSuccess: () async {
            Utils.showLog("Stripe Payment Success Method Called....");
            Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
            final isSuccess = await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "Stripe");
            Get.back(); // Stop Loading...
            if (isSuccess) {
              Utils.showToast(EnumLocal.txtCoinRechargeSuccess.name.tr);
              Get.close(1);
            } else {
              Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
            }
          },
        ).then((value) async {
          Utils.showLog("Stripe Payment Successfully");
        }).catchError((e) {
          Utils.showLog("Stripe Payment Error !!!");
        });
        Get.back(); // Stop Loading...
      } catch (e) {
        Get.back(); // Stop Loading...
        Utils.showLog("Stripe Payment Failed !! => $e");
      }
    }

    // >>>>> >>>>> >>>>> Flutter Wave Payment <<<<< <<<<< <<<<<

    if (selectedPaymentMethod == 3) {
      Utils.showLog("Flutter Wave Payment Working....");

      try {
        Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
        // FlutterWaveService.init(
        //   amount: coinAmount.toString(),
        //   onPaymentComplete: () async {
        //     Utils.showLog("Flutter Wave Payment Successfully");
        //
        //     Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...
        //
        //     final isSuccess = await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "Flutter Wave");
        //
        //     Get.back(); // Stop Loading...
        //
        //     if (isSuccess) {
        //       Utils.showToast(EnumLocal.txtCoinRechargeSuccess.name.tr);
        //       Get.close(1);
        //     } else {
        //       Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
        //     }
        //   },
        // );

        flutterWave(
          amount: coinAmount,
          onPaymentSuccess: () async {
            Utils.showLog("Flutter Wave Payment Successfully");

            Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

            final isSuccess = await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "Flutter Wave");

            Get.back(); // Stop Loading...

            if (isSuccess) {
              Utils.showToast(EnumLocal.txtCoinRechargeSuccess.name.tr);
              Get.close(1);
            } else {
              Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
            }
          },
        );

        Get.back(); // Stop Loading...
      } catch (e) {
        Get.back(); // Stop Loading...
        Utils.showLog("Flutter Wave Payment Failed => $e");
      }
    }

    // >>>>> >>>>> >>>>> pay pal Payment <<<<< <<<<< <<<<<

    if (selectedPaymentMethod == 4) {
      Utils.showLog("pay pal Payment Working....");

      try {
        Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

        payPal(
          amount: coinAmount,
          onPaymentSuccess: () async {
            Utils.showLog("pay pal Payment Successfully");

            Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

            final isSuccess = await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "Flutter Wave");

            Get.back(); // Stop Loading...

            if (isSuccess) {
              Utils.showToast(EnumLocal.txtCoinRechargeSuccess.name.tr);
              Get.close(1);
            } else {
              Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
            }
          },
        );

        Get.back(); // Stop Loading...
      } catch (e) {
        Get.back(); // Stop Loading...
        Utils.showLog("pay pal Payment Failed => $e");
      }
    }

    // >>>>> >>>>> >>>>> pay stack Payment <<<<< <<<<< <<<<<

    if (selectedPaymentMethod == 5) {
      Utils.showLog("pay stack Payment Working....");

      try {
        Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

        payStack(
          amount: coinAmount,
          onPaymentSuccess: () async {
            Utils.showLog("pay stack Payment Successfully");

            Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

            final isSuccess = await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "Flutter Wave");

            Get.back(); // Stop Loading...

            if (isSuccess) {
              Utils.showToast(EnumLocal.txtCoinRechargeSuccess.name.tr);
              Get.close(1);
            } else {
              Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
            }
          },
        );

        Get.back(); // Stop Loading...
      } catch (e) {
        Get.back(); // Stop Loading...
        Utils.showLog("pay stack Payment Failed => $e");
      }
    }

    // >>>>> >>>>> >>>>> cash free Payment <<<<< <<<<< <<<<<

    if (selectedPaymentMethod == 6) {
      Utils.showLog("cash free Payment Working....");

      try {
        Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

        cashFree(
          amount: coinAmount,
          onPaymentSuccess: () async {
            Utils.showLog("cash free Payment Successfully");

            Get.dialog(const LoadingUi(), barrierDismissible: false); // Start Loading...

            final isSuccess = await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "Flutter Wave");

            Get.back(); // Stop Loading...

            if (isSuccess) {
              Utils.showToast(EnumLocal.txtCoinRechargeSuccess.name.tr);
              Get.close(1);
            } else {
              Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
            }
          },
        );

        Get.back(); // Stop Loading...
      } catch (e) {
        Get.back(); // Stop Loading...
        Utils.showLog("cash free Payment Failed => $e");
      }
    }
  }

  Future<void> show({
    required BuildContext context,
    required String id,
    required num amount,
    required String key,
  }) async {
    coinPlanId = id;
    coinAmount = amount;
    productKey = key;

    InAppPurchaseHelper().getAlreadyPurchaseItems(this);
    purchases = InAppPurchaseHelper().getPurchases();
    InAppPurchaseHelper().clearTransactions();

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: AppColor.transparent,
      builder: (context) => Container(
        height: Get.height / 1.5,
        width: Get.width,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 65,
              color: AppColor.grey_100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 4,
                        width: 35,
                        decoration: BoxDecoration(
                          color: AppColor.colorTextDarkGrey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      10.height,
                      Text(
                        EnumLocal.txtPayment.name.tr,
                        style: AppFontStyle.styleW700(AppColor.black, 17),
                      ),
                    ],
                  ).paddingOnly(left: 50),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 30,
                      width: 30,
                      margin: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.transparent,
                        border: Border.all(color: AppColor.black),
                      ),
                      child: Center(
                        child: Image.asset(
                          width: 18,
                          AppAsset.icClose,
                          color: AppColor.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Visibility(visible: Utils.isShowInAppPurchasePaymentMethod, child: PaymentItemUi(0)),
                      // Visibility(visible: Utils.isShowRazorPayPaymentMethod, child: PaymentItemUi(1)),
                      // Visibility(visible: Utils.isShowStripePaymentMethod, child: PaymentItemUi(2)),
                      // Visibility(visible: Utils.isShowFlutterWavePaymentMethod, child: PaymentItemUi(3)),

                      if ((Platform.isAndroid && Utils.isShowInAppPurchasePaymentMethod == true) || (Platform.isIOS && Utils.isShowInAppPurchaseIosPaymentMethod == true)) PaymentItemUi(0),

                      if ((Platform.isAndroid && Utils.isShowRazorPayPaymentMethod == true) || (Platform.isIOS && Utils.isShowRazorPayIosPaymentMethod == true)) PaymentItemUi(1),

                      if ((Platform.isAndroid && Utils.isShowStripePaymentMethod == true) || (Platform.isIOS && Utils.isShowStripeIosPaymentMethod == true)) PaymentItemUi(2),

                      if ((Platform.isAndroid && Utils.isShowFlutterWavePaymentMethod == true) || (Platform.isIOS && Utils.isShowFlutterWaveIosPaymentMethod == true)) PaymentItemUi(3),

                      if ((Platform.isAndroid && Utils.isShowPayPalPaymentMethod == true) || (Platform.isIOS && Utils.isShowPayPalIosPaymentMethod == true)) PaymentItemUi(4),

                      if ((Platform.isAndroid && Utils.isShowPayStackPaymentMethod == true) || (Platform.isIOS && Utils.isShowPayStackIosPaymentMethod == true)) PaymentItemUi(5),

                      if ((Platform.isAndroid && Utils.isShowCashFreePaymentMethod == true) || (Platform.isIOS && Utils.isShowCashFreeIosPaymentMethod == true)) PaymentItemUi(6),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: AppButtonUi(
                height: 56,
                title: EnumLocal.txtPayNow.name.tr,
                gradient: AppColor.primaryLinearGradient,
                callback: onClickPayNow,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void onBillingError(error) {
    Utils.showLog("IAP Billing Error: $error");
    Utils.showToast("Payment failed: $error");
  }

  @override
  void onLoaded(bool initialized) {
    Utils.showLog("IAP Loaded: $initialized");
  }

  @override
  void onPending(PurchaseDetails product) {
    Utils.showLog("IAP Pending: ${product.productID}");
    Utils.showToast("Payment is pending...");
  }

  @override
  void onSuccessPurchase(PurchaseDetails product) async {
    Utils.showLog("IAP Success: ${product.productID}");

    try {
      // Show loading dialog
      Get.dialog(const LoadingUi(), barrierDismissible: false);

      // Call the API to record the purchase
      final isSuccess = await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "In App Purchase");

      // Hide loading dialog
      Get.back();

      if (isSuccess) {
        Utils.showToast(EnumLocal.txtCoinRechargeSuccess.name.tr);
        Get.close(2); // Close payment screens
      } else {
        Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
      }
    } catch (e) {
      // Hide loading dialog if there's an error
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Utils.showLog("API call failed: $e");
      Utils.showToast(EnumLocal.txtSomeThingWentWrong.name.tr);
    }
  }
}

class PaymentItemUi extends StatelessWidget {
  const PaymentItemUi(this.index, {super.key});

  final int index;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => RechargeCoinPaymentBottomSheetUi.onChangePaymentMethod(index),
      child: Container(
        height: 70,
        width: Get.width,
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColor.colorBorderGrey.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            10.width,
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.colorBorderGrey.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Image.asset(
                  RechargeCoinPaymentBottomSheetUi().paymentMethodList[index]["icon"]!,
                  width: double.parse(RechargeCoinPaymentBottomSheetUi().paymentMethodList[index]["size"]!),
                ),
              ),
            ),
            10.width,
            Text(
              RechargeCoinPaymentBottomSheetUi().paymentMethodList[index]["title"]!,
              style: AppFontStyle.styleW700(AppColor.black, 16),
            ),
            Spacer(),
            Obx(() => PaymentRadioButtonUi(isSelected: RechargeCoinPaymentBottomSheetUi.selectedPaymentMethod == index)),
            15.width,
          ],
        ),
      ),
    );
  }
}
