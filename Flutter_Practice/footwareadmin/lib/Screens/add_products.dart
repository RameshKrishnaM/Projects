import 'package:flutter/material.dart';
import 'package:footwareadmin/controller/home_controller.dart';
import 'package:footwareadmin/widgets/dropdown_button.dart';
import 'package:get/get.dart';

class AddProducts extends StatelessWidget {
  const AddProducts({super.key});

  @override
  Widget build(BuildContext context) {
    // String? selectedValue;
    return GetBuilder<HomeController>(
      builder: (ctrl) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Add Product'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Add New Product',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 30,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: ctrl.nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your Product Name',
                    label: Text('Product Name'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: ctrl.descController,
                  decoration: InputDecoration(
                    hintText: 'Enter your Product Description',
                    label: Text('Product Description'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  maxLines: 5,
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: ctrl.urlController,
                  decoration: InputDecoration(
                    hintText: 'Enter Your Image Url',
                    label: Text('Image Url'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: ctrl.priceController,
                  decoration: InputDecoration(
                    hintText: 'Enter your Product Price',
                    label: Text('Product Price'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: DropDownButton(
                        items: [
                          'Sneakers',
                          'Loafer',
                          'Athletic Shoes',
                          'Slippers',
                          'Boots'
                        ],
                        hintTxt: ctrl.category,
                        onSelected: (selectedValue) {
                          print(selectedValue);
                          ctrl.category = selectedValue ?? 'Category';
                          ctrl.update();
                        },
                        // selectedValue: ctrl.category ?? 'Cate1',
                      ),
                    ),
                    Flexible(
                      child: DropDownButton(
                        items: ['Nike', 'Puma', 'Adidas', 'RoadSter', 'Reebok'],
                        hintTxt: ctrl.brand,
                        onSelected: (selectedValue) {
                          ctrl.brand = selectedValue ?? 'Brand';
                          ctrl.update();
                        },
                        // selectedValue: ctrl.brand ?? 'Brand1',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Text('offer Product ?'),
                SizedBox(
                  height: 10,
                ),
                // CustomDropDown(
                //   controller: ctrl.offerController,
                //   values: ['True', 'False'],
                // ),
                DropDownButton(
                  items: ['true', 'false'],
                  hintTxt: ctrl.offer.toString(),
                  onSelected: (selectedValue) {
                    print(selectedValue);
                    ctrl.offer =
                        bool.tryParse(selectedValue ?? 'false') ?? false;
                    ctrl.update();
                  },
                  // selectedValue: ctrl.offer.toString(),
                  // selectedValue: '',
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.indigo),
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                  ),
                  onPressed: () {
                    ctrl.addProduct();
                  },
                  child: Text('Add Product'),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
