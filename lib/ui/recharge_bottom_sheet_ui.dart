import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/main.dart';
import 'package:shortie/pages/recharge_page/api/fetch_coin_plan_api.dart';
import 'package:shortie/pages/recharge_page/model/fetch_coin_plan_model.dart';
import 'package:shortie/pages/recharge_page/view/recharge_view.dart';
import 'package:shortie/ui/loading_ui.dart';
import 'package:shortie/ui/no_data_found_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/utils/enums.dart';
import 'package:shortie/utils/font_style.dart';

import 'recharge_coin_payment_bottom_sheet_ui.dart';

class RechargeBottomSheetUi {
  static RxBool isLoading = false.obs;
  static List<Data> coinPlanCollection = [];
  static FetchCoinPlanModel? fetchCoinPlanModel;

  static Future<void> onGetCoinPlan() async {
    isLoading.value = true;
    fetchCoinPlanModel = await FetchCoinPlanApi.callApi();
    coinPlanCollection = fetchCoinPlanModel?.data ?? [];
    isLoading.value = false;
  }

  static Future<void> show({required BuildContext context}) async {
    onGetCoinPlan();
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
                        EnumLocal.txtRecharge.name.tr,
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
            5.height,
            Expanded(
              child: Obx(
                () => isLoading.value
                    ? LoadingUi()
                    : coinPlanCollection.isEmpty
                        ? NoDataFoundUi(iconSize: 160, fontSize: 19)
                        : SingleChildScrollView(
                            child: GridView.builder(
                              itemCount: coinPlanCollection.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.all(15),
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15,
                                mainAxisExtent: 210,
                              ),
                              itemBuilder: (context, index) {
                                final planIndex = coinPlanCollection[index];
                                return CoinPlanItemUi(
                                  coin: planIndex.coin ?? 0,
                                  amount: (planIndex.amount ?? 0).toDouble(),
                                  isPopular: planIndex.isPopular ?? false,
                                  callback: () {
                                    Get.back();
                                    RechargeCoinPaymentBottomSheetUi().show(
                                      context: context,
                                      id: planIndex.id ?? "",
                                      amount: planIndex.amount ?? 0,
                                      key: planIndex.productKey ?? "",
                                    );
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
