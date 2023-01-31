import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? paymentIntentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stripe Payment'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              await makePayment();
            },
            child: Container(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Center(
                child: Text('Pay'),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> makePayment() async {
    print('running');
    try {
      paymentIntentData = await createPaymentIntent('20', 'INR');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
            setupIntentClientSecret:
                'sk_test_51MUWEGSEYF9k5zImRqxAHWnjrNThqfqCsEHN3SuW3ixe3jv0UfYvK2GAQukhpBdLTysbnpuKwn1d5sdH7MN5fJUw004T3lXREm',
            paymentIntentClientSecret: paymentIntentData!['client_secret'],
            style: ThemeMode.dark,
            merchantDisplayName: 'Saswata'),
      );

      displayPaymentSheet();
    } catch (e) {
      print(e.toString());
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      setState(() {
        paymentIntentData = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paid Successfully!'),
        ),
      );
    } on StripeException catch (e) {
      print(e.toString());
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text('Cancelled'),
        ),
      );
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
                'Bearer sk_test_51MUWEGSEYF9k5zImRqxAHWnjrNThqfqCsEHN3SuW3ixe3jv0UfYvK2GAQukhpBdLTysbnpuKwn1d5sdH7MN5fJUw004T3lXREm',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      return jsonDecode(response.body.toString());
    } catch (e) {
      print(e.toString());
    }
  }

  calculateAmount(String amount) {
    final price = int.parse(amount) * 100;
    return price.toString();
  }
}
