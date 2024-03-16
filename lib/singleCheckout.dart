import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tespay/main.dart';

class CheckoutController extends GetxController {
  var dataLoaded = false.obs;
  var loading = false.obs;
  var hasNoErrors = true.obs;
  var successCall = true.obs;
  var data = {}.obs;

  toggleDataLoaded() {
    dataLoaded.value = !dataLoaded.value;
    loading.value = false;
  }

  toggleLoading() {
    loading.value = true;
  }

  toggleSuccessCall() {
    successCall.value = false;
  }
}

class SingleCheckout extends StatelessWidget {
  SingleCheckout({super.key});

  final CheckoutController checkoutController = Get.put(CheckoutController());
  final Controller chargily = Get.find();
  final TextEditingController idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Align(
            alignment: Alignment.center,
            child: Text(
              "Retrieve Checkout",
              style: TextStyle(fontSize: 22),
            )),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
              child: Text("Retrieve a single checkout.",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Text(
                  "Provide the id of the checkout to retrieve all the information about it.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300.withOpacity(0.4),
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 0.4,
                        blurRadius: 3,
                        color: Colors.grey.shade300.withOpacity(0.2),
                        offset: const Offset(1, 6))
                  ],
                  borderRadius: const BorderRadius.all(Radius.circular(8.0))),
              child: TextField(
                controller: idController,
                onChanged: (_) {},
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                    labelText: "Checkout ID",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                            color: Colors.grey.shade100.withOpacity(0.4))),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.orange.shade700),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                          color: Colors.grey.shade400.withOpacity(0.4)),
                    ),
                    filled: true,
                    fillColor: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    checkoutController.successCall.value = true;
                    if (idController.text.isEmpty) {
                      checkoutController.hasNoErrors.value = false;
                    } else {
                      checkoutController.hasNoErrors.value = true;
                    }
                    await checkoutController.toggleLoading();
                    final result = await chargily.payService
                        .retrieveCheckout(id: idController.text.toString())
                        .catchError((error) {
                      checkoutController.successCall.value = false;
                    });

                    /* if (result.statusCode == 200) {
                      checkoutController.successCall.value = true;
                    } else {
                      checkoutController.successCall.value = false;
                    } */

                    if (checkoutController.successCall.value == true) {
                      checkoutController.data.value =
                          jsonDecode(result.toString());
                    }
                    checkoutController.toggleDataLoaded();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade500,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: const Text('Retrieve a single checkout.',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ),
            Obx(() => checkoutController.loading.value
                ? const Center(child: CircularProgressIndicator())
                : (checkoutController.data.isNotEmpty &&
                        checkoutController.hasNoErrors.value &&
                        checkoutController.successCall.value)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(10.0),
                                  margin: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9E3D5),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    'Amount: ${checkoutController.data["amount"]} DA',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(10.0),
                                  margin: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9E3D5),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    'Fees: ${checkoutController.data["fees"]} DA',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(10.0),
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9E3D5),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'Status: ${checkoutController.data["status"]}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(10.0),
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9E3D5),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'Payment Method: ${checkoutController.data["payment_method"]}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(10.0),
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9E3D5),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'Created AT: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(checkoutController.data["created_at"] * 1000))}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Text(
                            "ERROR: Checkout ID incorrect or not provided!"),
                      ))
          ],
        ),
      ),
    );
  }
}
