import 'package:flutter/material.dart';
import 'package:footwareadmin/Screens/add_products.dart';
import 'package:footwareadmin/controller/home_controller.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (ctrl) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Product List'),
            centerTitle: true,
          ),
          body: ctrl.fetchProduct.length == 0
              ? Center(
                  child: Text('There is no product'),
                )
              : ListView.builder(
                  itemCount: ctrl.fetchProduct.length,
                  itemBuilder: (context, index) {
                    print('object ${ctrl.fetchProduct.length}');
                    return ListTile(
                      title: Text("Name :${ctrl.fetchProduct[index].name}"),
                      subtitle:
                          Text('Price : ${ctrl.fetchProduct[index].price}'),
                      trailing: IconButton(
                        onPressed: () {
                          ctrl.deleteProduct(index);
                        },
                        icon: Icon(Icons.delete_outlined),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.to(() => AddProducts());
            },
            child: Icon(
              Icons.add,
            ),
          ),
        );
      },
    );
  }
}
