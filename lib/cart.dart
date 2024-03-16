import 'dart:convert';

import 'package:chargily_pay/chargily_pay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tespay/cartItem.dart';
import 'package:tespay/main.dart';
import 'package:chargily_pay/src/models/checkout.dart';
import 'package:chargily_pay/src/models/checkoutitem.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ShoppingCart extends StatelessWidget {
  final Controller chargily = Get.find();

  ShoppingCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Align(
            alignment: Alignment.center,
            child: Text(
              "Shopping Cart",
              style: TextStyle(fontSize: 22),
            )),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("List of your porducts",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Text("Here you can find 3 example items to checkout.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
          ),
          ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: chargily.productsInCart.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return ProductList(chargily.productsInCart[index], index);
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9E3D5),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Text(
                      'Total to pay: ${chargily.productsInCart.map<int>((item) => int.parse(item.product.price) * item.quantity).reduce((value, element) => value + element)} DA',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade700,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        List<CheckoutItem> checkoutItems = [];
                        for (var item in chargily.productsInCart) {
                          checkoutItems.add(CheckoutItem(
                              price: item.product.price,
                              quantity: item.quantity));
                        }

                        final result = await chargily.payService.createCheckout(
                            checkout: Checkout(
                          successUrl: "https://chargily.com/",
                          amount: 14400,
                          currency: "dzd",
                        ));
                        var data = jsonDecode(result.toString());
                        var url = data["checkout_url"];
                        print(url);

                        if (await canLaunchUrlString(url)) {
                          await launchUrlString(url,
                              mode: LaunchMode.inAppBrowserView);
                        } else {
                          throw 'could not launch the url';
                        }
                      },
                      child: const Text('PAY NOW!',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  final ShoppingCartItem model;

  ProductList(this.model, int pos, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          color: const Color(0xFFF9E3D5),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                offset: const Offset(0.0, 0.0))
          ],
          border: Border.all(color: Colors.transparent)),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      model.product.name,
                      style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text(
                  model.product.description,
                  style: const TextStyle(fontWeight: FontWeight.w300),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          '${model.product.price} DA',
                          style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Icon(Icons.remove_circle,
                            color: Theme.of(context).colorScheme.inversePrimary,
                            size: 20),
                        const SizedBox(width: 4),
                        Text(
                          model.quantity.toString(),
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 18.0),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.add_circle,
                            color: Theme.of(context).colorScheme.inversePrimary,
                            size: 20)
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
