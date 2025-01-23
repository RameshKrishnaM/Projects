import 'package:flutter/material.dart';

class MyCustomScrollView extends StatefulWidget {
  const MyCustomScrollView({super.key});

  @override
  State<MyCustomScrollView> createState() => _MyCustomScrollViewState();
}

class _MyCustomScrollViewState extends State<MyCustomScrollView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          // reverse: true,
          shrinkWrap: true,
          anchor: 1.0,
          physics: ClampingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              stretch: true,
              snap: true,
              expandedHeight: 200,
              title: Text('Custom Scroll View'),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.search),
                ),
              ],
            ),
            SliverGrid.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Ramesh'),
                    ],
                  ),
                );
              },
            )
            // SliverList.builder(
            //   itemCount: 20,
            //   itemBuilder: (context, index) {
            //     return ListTile(title: Text("Item $index"));
            //   },
            // )
          ],
        ),
      ),
    );
  }
}
