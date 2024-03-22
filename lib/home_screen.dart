import 'package:flutter/material.dart';
import 'package:payment_gateway_razorpay/constant.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'service/razorpay_integration.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // RazorPayIntegration razorPayIntegration = RazorPayIntegration();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  late Razorpay razorpay;
  @override
  void initState() {
    // Initialize Razorpay instance
    razorpay = Razorpay();
    // Set up event handlers
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, errorHandler);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, successHandler);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, externalWalletHandler);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    mobileController.clear();
    emailController.clear();
    amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Gateway"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: mobileController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter Mobile Number",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter Email Address",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: amountController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "00.00",
                suffixText: "INR",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                if(amountController.text.isNotEmpty && mobileController.text.isNotEmpty && emailController.text.isNotEmpty){
                openCheckout();
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please enter the details"),
                    backgroundColor: Colors.green,
                  ));
                }
              },
              child: const Text("Pay"),
            ),
          ),
        ],
      ),
    );
  }

  void errorHandler(PaymentFailureResponse response) {
    // Display a red-colored SnackBar with the error message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response.message!),
      backgroundColor: Colors.red,
    ));
  }
  void successHandler(PaymentSuccessResponse response) {
    // Display a green-colored SnackBar with the payment ID
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response.paymentId!),
      backgroundColor: Colors.green,
    ));
  }
  void externalWalletHandler(ExternalWalletResponse response) {
    // Display a green-colored SnackBar with the name of the external wallet used
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response.walletName!),
      backgroundColor: Colors.green,
    ));
  }


  void openCheckout() {
    var options = {
      "key": Constant.key_id,
      "amount": num.parse(amountController.text),
      "name": "test",
      "description": " this is the test payment",
      "timeout": "180",
      "currency": "INR",
      "prefill": {
        "contact": mobileController.text,
        "email": emailController.text,
      },
      'external': {
        'wallets': ['paytm']
      }
    };
    razorpay.open(options);
  }

}
