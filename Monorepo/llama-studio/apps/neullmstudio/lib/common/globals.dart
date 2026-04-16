import 'dart:io';
import 'package:get/get.dart';

Process? serverProcess;

/// True when running inside a web browser.
bool get isWeb => GetPlatform.isWeb;
