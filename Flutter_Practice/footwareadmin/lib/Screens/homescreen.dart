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
          body: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Product ${index + 1}'),
                subtitle: Text('Price ${index + 1}'),
                trailing: IconButton(
                  onPressed: () {},
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
