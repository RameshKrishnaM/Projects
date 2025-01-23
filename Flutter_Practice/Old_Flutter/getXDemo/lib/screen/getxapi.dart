import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getxdemo/controller/product_controller.dart';

class ApiGetX extends StatelessWidget {
  final ProductController productController = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Obx(
          () {
            if (productController.isLoading.value) {
              return CircularProgressIndicator();
            } else {
              return ListView.builder(
                itemCount: productController.productList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: Image.network(
                                productController.productList[index].imageLink),
                          ),
                          Text(productController.productList[index].brand.name)
                        ],
                      ),
                      // SizedBox(
                      //   height: 15.0,
                      // ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
