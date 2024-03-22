import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../constant.dart';

class RazorPayIntegration{
  // Instance of razor pay
  final Razorpay _razorpay = Razorpay();
  var msg;


  initiateRazorPay() {
    // To handle different event
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }


  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log("Payment success");
    msg = "SUCCESS: ${response.paymentId}";
    showToast(msg);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    msg = "ERROR:  ${response.code.toString()}  - ${jsonDecode(response.message.toString())['error']['description']}";
    showToast(msg);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    msg = "EXTERNAL_WALLET: ${response.walletName}";
    showToast(msg);
  }

  showToast(msg){
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.withOpacity(0.1),
      textColor: Colors.black54,
    );
  }

  void createOrderId({required String amt, required String mobile, required String email, String orderId = "TCW_01",String id = "orderId_1",  String userId = "uid1", String description = "PJ Payments"}) async{
    final int amount = int.parse(amt) * 100;
    var dio = Dio();
    Response response = await dio.post(
      "https://api.razorpay.com/v1/orders",
      data: {
        "amount": amount,
        "currency": "INR",
        "receipt": "OrderId_$orderId",
        "notes": {
          "userId": userId,
          "packageId": id,
          "description": description
        },
      },
      options: Options(
        contentType: "application/json",
        headers: {
          // Update the Authorization header with correct credentials
          "Authorization": 'Basic ${base64Encode(utf8.encode('${Constant.key_id}:${Constant.key_id}'))}',
        },
      ),
    );

    if(response.statusCode == 200){
      openCheckout(amount: amt, mobile: mobile, email: email);
    }
  }

  void openCheckout({required String amount, required String mobile, required String email, String description = "First Order", String orderId = "TCW_01"}) async {
    var options = {
      'key': Constant.key_id,
      'amount': amount,
      'name': 'ECharge Tech',
      'order_id': orderId, // Generate order_id using Orders API
      'description': description,
      'retry': {'enabled': true, 'max_count': 2},
      'send_sms_hash': true,
      'prefill': {
        'contact': mobile,
        'email': email
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

}