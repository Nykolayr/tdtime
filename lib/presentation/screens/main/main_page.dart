import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tdtime/presentation/screens/main/main_scan_page.dart';
import 'package:tdtime/presentation/screens/main/setting_page.dart';
import 'package:tdtime/presentation/screens/main/widget.dart';
import 'package:tdtime/presentation/theme/theme.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  List<Widget> pages = const [
    MainScanPage(),
    SettingsPage(),
  ];

  final PageController pageController =
      PageController(); // Контроллер для PageView

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index; // Обновляем индекс выбранного таба
    });
    pageController.animateToPage(index, // Используем animateToPage для анимации
        duration: const Duration(milliseconds: 200), // Длительность анимации
        curve: Curves.easeInOut); // Кривая анимации
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColor.blueFon,
        bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          color: AppColor.blueFon,
          height: 110,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.all(Radius.circular(35)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (int i = 0; i < pages.length; i++)
                        ButtonTab(
                          current: selectedIndex, // Текущий индекс
                          index: i, // Индекс текущей кнопки
                          onTap: onItemTapped, // Обработчик нажатия
                        ),
                    ],
                  )),
              const Gap(10),
              Center(
                  child: Text('Версия ${Get.find<PackageInfo>().version}',
                      style: AppText.text14.copyWith(
                        fontWeight: FontWeight.w400,
                      ))),
            ],
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          onPageChanged: (index) {
            setState(() {
              selectedIndex = index; // Обновляем индекс при смене страницы
            });
          },
          children: pages,
        ),
      ),
    );
  }
}
