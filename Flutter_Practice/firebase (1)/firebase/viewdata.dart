import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photosaver/homepage.dart';

class FireBaseData extends StatefulWidget {
  const FireBaseData({Key? key}) : super(key: key);

  @override
  State<FireBaseData> createState() => _FireBaseDataState();
}

class _FireBaseDataState extends State<FireBaseData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProductDetails'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: fetchDataFromFirestore(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child:  Text('No data available'));
          }

          List<QueryDocumentSnapshot<Map<String, dynamic>>> documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              var thisItem = documents[index].data();
              return Dismissible(
                key: ValueKey(documents[index]),
                child: ListTile(
                  title: Text(thisItem['product'] ?? 'Name not available'),
                  subtitle: Text(thisItem['quantity']?.toString() ?? 'Quantity not available'),
                  leading: SizedBox(
                    height: 80,
                    width: 80,
                    child: thisItem.containsKey('imageUrl') ? Image.network(thisItem['imageUrl']!) : Container(),
                  ),
                  onTap: () {
                    setState(() {
                      Navigator.push(context,MaterialPageRoute(builder: (context) =>  HomePage(productname: thisItem),));
                    });
                  },
                ),
                onDismissed: (direction) {
                     setState(()async {
                       FirebaseFirestore.instance.collection('Products').doc(documents[index].id).delete();
                          if (thisItem.containsKey('imageUrl')) {
                    String imageUrl = thisItem['imageUrl'];
                    Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);
                    await ref.delete();
                  }
                     });
                },
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchDataFromFirestore() {
    return FirebaseFirestore.instance.collection('Products').snapshots();
  }
}

