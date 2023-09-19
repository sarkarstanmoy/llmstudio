import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:neu_llm_studio/common/common.dart';
import 'package:neu_llm_studio/screens/offline/offline.dart';
import 'package:neu_llm_studio/screens/test/test.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      useDrawer: false,
        appBar: Common().CustomAppBar(),
        appBarBreakpoint: Breakpoints.small,
        selectedIndex: _selectedTab,
        onSelectedIndexChange: (int index) {
          setState(() {
            _selectedTab = index;
          });
        },

        leadingExtendedNavRail: Text("NeuLLMStudio"),
        leadingUnextendedNavRail: Text("NeuLLM"),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.electric_bolt_outlined,),
            selectedIcon: InkWell(child: const Icon(Icons.electric_bolt),onTap: (){ Get.to(const Test());},),
            label: 'Test',
          ),
          NavigationDestination(
            icon: const Icon(Icons.offline_share_outlined),
            selectedIcon: InkWell(child: const Icon(Icons.offline_share,),onTap: (){Get.to(const Offline());},),
            label: 'Offline',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: InkWell(child: const Icon(Icons.settings,),onTap: (){Get.to(const Offline());},),
            label: 'Settings',
          ),
        ],

      body: (context) {
        if(_selectedTab ==0){
          return const Test();
        } else if (_selectedTab ==1){
          return const Offline();
        } else {
          return Container();
        }
      },
    );
  }
}
