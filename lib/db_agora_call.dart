library db_agora_call;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

part 'src/http_requests.dart';
part 'src/utils.dart';
part 'src/call_page.dart';
part 'src/wait_for_report_page.dart';

/// A Calculator.
class BdAgoraCall {
  BdAgoraCall(this.context, this.defaultBackPage);
  final dynamic defaultBackPage;
  final BuildContext context;

  /// Returns [value] plus 1.
  Future<void> initCall(String mobile, String token) async {

    setToken(token);

    var value = await post(
        "https://micro-purno-api.purnohealth.com/api/v1/doctor-call/init-call-regular",
        body: {"mobile": mobile});
    print("init call regular value: $value");
    if (value == null) {
      return;
    }
    if (((value ?? {})['status'] ?? false) == false) {
      showErrorSnackBar(
          context,
          message: "${value['message']}",
          background: Colors.red
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CallPage(
      channelName: "${value['data']['room_id']}",
      token: "${value['data']['token']}",
      bearerToken: '',
      isMBBSCall: true,
      defaultBackPage: defaultBackPage,
    )));
  }
}
