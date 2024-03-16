import 'dart:convert';

import 'package:chargily_pay/chargily_pay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tespay/cart.dart';
import 'package:tespay/product.dart';
import 'package:tespay/singleCheckout.dart';

import 'cartItem.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Payment Gateway Test',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: Home(),
    );
  }
}

class Controller extends GetxController {
  @override
  void onInit() async {
    super.onInit();
    result = await payService.getBalance();
    data = jsonDecode(result.toString());
    wallets.value = data["wallets"];

    productsInCart.add(ShoppingCartItem(
      product: Product(
          name: "First Product",
          description: "First Product in our product list",
          price: "2500"),
      quantity: 2,
    ));

    productsInCart.add(ShoppingCartItem(
      product: Product(
          name: "Second Product",
          description: "Second Product in our product list",
          price: "800"),
      quantity: 3,
    ));

    productsInCart.add(ShoppingCartItem(
      product: Product(
          name: "Third Product",
          description: "Third Product in our product list",
          price: "3600"),
      quantity: 1,
    ));

    productsInCart.add(ShoppingCartItem(
      product: Product(
          name: "Fourth Product",
          description: "Fourth Product in our product list",
          price: "1700"),
      quantity: 2,
    ));
  }

  ChargilyPayService payService = ChargilyPayService(
    apiKey: "test_pk_hltuu4RLw2vBLtfFxFvq5gMDzN5OwfHWEFm30LWc",
    secret: "test_sk_zK5Qo73qY3dIQJrfFN98yVMlPXBOyUHKUMmCYl8R",
    baseUrl: "https://pay.chargily.net/test/api/v2",
  );

  late var result;
  var data;
  var wallets = [].obs;

  final firstProduct = Product(
      name: "First Product",
      description: "First Product in our product list",
      price: "2500");
  final secondProduct = Product(
      name: "Second Product",
      description: "Second Product in our product list",
      price: "800");
  final thirdProduct = Product(
      name: "Third Product",
      description: "Third Product in our product list",
      price: "3600");
  final fourthProduct = Product(
      name: "Fourth Product",
      description: "Fourth Product in our product list",
      price: "1700");

  List<ShoppingCartItem> productsInCart = [];
}

class Home extends StatelessWidget {
  Home({super.key, title});
  final Controller chargily = Get.put(Controller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Align(
            alignment: Alignment.center,
            child: Text(
              "Chargily Pay Integration",
              style: TextStyle(fontSize: 22),
            )),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Your Wallets",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("We are always using test mode and not live mode.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
            ),
            GetX<Controller>(
                init: Controller(),
                builder: (chargily) {
                  return chargily.wallets.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children:
                                List.generate(chargily.wallets.length, (index) {
                              var currency =
                                  chargily.wallets[index]["currency"];
                              var balance = chargily.wallets[index]["balance"];
                              var readyForPayout =
                                  chargily.wallets[index]["ready_for_payout"];
                              return Container(
                                width: context.width / 2 - 25,
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFFFE7Ab),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(40.0))),
                                      child: Text(
                                          currency.toString().toUpperCase()),
                                    ),
                                    const SizedBox(
                                      height: 25.0,
                                    ),
                                    Text(
                                        '${currency.toString().toUpperCase()} ${balance.toString()}',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(
                                      height: 8.0,
                                    ),
                                    Text(
                                        'Ready: ${readyForPayout.toString()} ${currency.toString().toUpperCase()}',
                                        style: const TextStyle(
                                            color: Colors.black)),
                                  ],
                                ),
                              );
                            }),
                          ),
                        );
                }),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Get.to(ShoppingCart()),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: const Text('Go to shopping cart.',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Get.to(SingleCheckout()),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: const Text('Retrieve a single checkout.',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Get.to(ShoppingCart()),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: const Text('List all checkouts.',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
