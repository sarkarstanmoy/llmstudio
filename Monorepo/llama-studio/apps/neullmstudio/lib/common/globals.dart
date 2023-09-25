 import 'dart:io';

import 'package:get/get_utils/src/platform/platform.dart';

Process? serverProcess;
 bool IsWeb = GetPlatform.isWindows && GetPlatform.isWeb;

