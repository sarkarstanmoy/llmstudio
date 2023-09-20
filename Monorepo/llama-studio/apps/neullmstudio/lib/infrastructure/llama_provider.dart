import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

class Data {
  late String response;
  Data({required this.response});
  factory Data.fromJson(Map<String, dynamic> data) {
    final response = data['response'] as String;
    return Data(response: response);
  }
}

class SystemStat {
  late String ram_available;
  late String ram_total;
  late String ram_used;
  late String cpu_percentage;
  late String disk_available;
  late String disk_percentage;
  late String disk_used;


  SystemStat({required this.ram_available,required this.ram_total,required this.ram_used,
    required this.cpu_percentage,required this.disk_available,required this.disk_percentage,
    required this.disk_used});
  factory SystemStat.fromJson(Map<String, dynamic> data) {
    final ramAvailable = data['ram_available'] as String;
    final ramTotal = data['ram_total'] as String;
    final ramUsed = data['ram_used'] as String;
    final cpuPercentage = data['cpu_percentage'] as String;
    final diskAvailable = data['disk_available'] as String;
    final diskPercentage = data['disk_percentage'] as String;
    final diskUsed = data['disk_used'] as String;

    return SystemStat(ram_available: ramAvailable,ram_total:ramTotal,ram_used:ramUsed,
        cpu_percentage:cpuPercentage,disk_available:diskAvailable,disk_percentage:diskPercentage,
        disk_used:diskUsed);
  }
}

class LlamaProvider {
  Future<Data> getResponse(String prompt) async {
    var request = {"request": prompt};
    var url = "http://127.0.0.1:8000/prompt";
    if (GetPlatform.isMobile) {
      url = "http://10.0.2.2:8000/prompt";
    }
    var response = await Dio().post(url, data: jsonEncode(request));
    return Data(response: response.data);
  }

  Future<SystemStat> getSystemData() async {
    var url = "http://127.0.0.1:8000/systemstats";
    var response = await Dio().get(url);
    return SystemStat.fromJson(response.data);
  }


}
