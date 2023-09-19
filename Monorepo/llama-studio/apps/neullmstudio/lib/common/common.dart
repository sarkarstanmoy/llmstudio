import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../themes/custom_theme.dart';

class Common {
  PreferredSizeWidget CustomAppBar(){
    return AppBar(title: const Text('NeuLLMStudio'), elevation: 10, actions: [
      IconButton(onPressed: (){
        Get.changeTheme(Get.isDarkMode? CustomTheme().buildLightTheme() : CustomTheme().buildDarkTheme());
      }, icon: Get.isDarkMode ?  const Icon(Icons.light_mode) : const Icon(Icons.dark_mode) )
    ],);
  }
}