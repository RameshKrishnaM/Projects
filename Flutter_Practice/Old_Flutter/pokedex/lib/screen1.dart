import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/popup.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

//with TickerProviderStateMixin
class _Screen1State extends State<Screen1> {
  bool isLoading = true;

  List pokeList = [];
  String? selectedOption;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Map pokeData = {};
  fetchData() async {
    try {
      var response = await http.get(Uri.parse(
          'https://raw.githubusercontent.com/Biuni/PokemonGO-Pokedex/master/pokedex.json'));
      if (response.statusCode == 200) {
        pokeData = jsonDecode(response.body);
        pokeList = pokeData['pokemon'];
        isLoading = false;
        setState(() {});
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: const TextStyle(fontSize: 14.0, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            // automaticallyImplyLeading: true,
            title: const Text('PokeDex'),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.home),
                ),
                Tab(
                  icon: Icon(Icons.search),
                ),
                Tab(
                  child: DropdownMenuExample(),
                ),
              ],
              // mouseCursor: SystemMouseCursors.grab,
              // controller: TabController(length: 2, vsync: this),
            ),
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : TabBarView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: Column(
                          children: [
                            const Text(
                              'Poke Dex...!!!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Expanded(
                              child: pokeList.isEmpty
                                  ? const Text('No Data Found')
                                  : ListView.builder(
                                      itemCount: pokeList.length,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            ListTile(
                                              leading: SizedBox(
                                                height: 60,
                                                width: 60,
                                                child: Image(
                                                  image: NetworkImage(
                                                      pokeList[index]['img'],
                                                      scale: 1.0),
                                                ),
                                              ),
                                              title: Text(
                                                pokeList[index]['name'],
                                              ),
                                              subtitle: Text(
                                                pokeList[index]['candy'],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const TextField(
                      decoration: InputDecoration(
                        suffixIcon: InkWell(
                          splashColor: Colors.transparent,
                          child: Icon(Icons.search),
                        ),
                      ),
                    ),

                    // const Text(''),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      // child: AgeCalc(),
                      // child: PhysicsCardDragDemo(),
                      child: Column(
                        children: [
                          InkWell(
                              onTap: () {
                                // const AgeCalc();
                              },
                              child: Text('Options')),
                          // LoadingAnimatedButton(
                          //   child: Text('Age Calculator...!!!'),
                          //   onTap: () {},
                          //   color: Colors.teal,
                          // ),
                          DropdownButton(
                            hint: Text('More'),
                            items: [
                              'profile',
                              'add',
                              'refresh',
                              'settings',
                            ].map<DropdownMenuItem<String>>((item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                            value: selectedOption,
                            onChanged: (newValue) {
                              setState(
                                () {
                                  selectedOption = newValue;
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
