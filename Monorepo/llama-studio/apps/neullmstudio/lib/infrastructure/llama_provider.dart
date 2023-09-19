import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
class Data {
  late String response;
  Data({required this.response});
  factory Data.fromJson(Map<String,dynamic> data){
    final response = data['response'] as String;
    return Data(response: response);
  }
}

class LlamaProvider  {

  Future<Data> getResponse(String prompt) async {
    var url = "http://127.0.0.1:8000/prompt/$prompt";
    if(GetPlatform.isMobile){
      url = "http://10.0.2.2:8000/prompt/$prompt";
    }
    var response = await Dio().get(url);
    return Data(response: response.data);
  }



}