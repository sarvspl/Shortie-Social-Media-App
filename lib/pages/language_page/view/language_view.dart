import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortie/pages/language_page/controller/language_controller.dart';
import 'package:shortie/ui/simple_app_bar_ui.dart';
import 'package:shortie/utils/asset.dart';
import 'package:shortie/utils/color.dart';
import 'package:shortie/pages/language_page/widget/language_widget.dart';
import 'package:shortie/utils/enums.dart';

class LanguageView extends StatelessWidget {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.white,
        shadowColor: AppColor.black.withValues(alpha: 0.4),
        surfaceTintColor: AppColor.transparent,
        flexibleSpace: SimpleAppBarUi(title: EnumLocal.txtLanguages.name.tr),
      ),
      body: Obx(() {
        final controller = Get.find<LanguageController>();

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColor.primary));
        }

        if (controller.languages.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.onRefresh,
            color: AppColor.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                const Center(child: Text("No languages found")),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          color: AppColor.primary,
          child: ListView.builder(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.languages.length + (controller.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.languages.length) {
                return Obx(() => controller.isMoreLoading.value
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator(color: AppColor.primary)),
                      )
                    : const SizedBox());
              }

              final language = controller.languages[index];
              return ItemsView(
                icon: language.icon.isNotEmpty ? language.icon : (controller.countryFlags.length > index ? controller.countryFlags[index] : AppAsset.icUnitedStates),
                title: language.nativeName,
                isSelected: language.code == controller.languageInfo?.code,
                callback: () => controller.onChangeLanguage(language),
              );
            },
          ),
        );
      }),
    );
  }
}
