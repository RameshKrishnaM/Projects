import 'package:flutter/material.dart';
import 'package:tasktemp/customWidget1.dart';

import 'route.dart' as route;

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(
            bottom: 15.0,
            right: 15.0,
            left: 15.0,
            top: 40.0,
          ),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: const Icon(
                      Icons.grid_view_outlined,
                      color: Color(0xFF989496),
                    ),
                    onTap: () {
                      Navigator.popAndPushNamed(context, route.screen1);
                      // Navigator.pushNamed(context, route.screen1);
                    },
                  ),
                  const Icon(
                    Icons.notification_add_outlined,
                    color: Color(0xFF989496),
                  ),
                ],
              ),
              const Text(
                'Good Evening!',
                style: TextStyle(
                  height: 2.0,
                  color: Color(0xFF535353),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                'Hridoy',
                style: TextStyle(
                  color: Color(0xFF465981),
                ),
              ),
              const SizedBox(
                height: 25.0,
              ),
              Material(
                elevation: 2,
                borderRadius: const BorderRadius.all(
                  Radius.circular(30),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(2.0),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        borderSide: const BorderSide(
                          color: Colors.white,
                        )),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.grey.withOpacity(0.6),
                    ),
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
                    suffixIcon: Icon(Icons.filter_alt_outlined,
                        color: Colors.grey.withOpacity(0.6)),
                  ),
                ),
              ),
              const SizedBox(
                height: 15.0,
              ),
              const Text(
                'Recently uploaded',
                style: TextStyle(
                    color: Color(0xFF575455),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                height: 15.0,
              ),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, route.screen3);
                          },
                          child: mycard(
                            context,
                            img:
                                'assets/images/Bangalore-rustic-home-interiors-architecture.jpg',
                            bname: 'Wooden Like House',
                            prize: '\$1200/month',
                          ),
                        ),
                        mycard(
                          context,
                          img: 'assets/images/download-23.jpg',
                          bname: 'Duplex House',
                          prize: '\$1600/month',
                        ),
                        mycard(
                          context,
                          img:
                              'assets/images/photo-1564013799919-ab600027ffc6.jpeg',
                          bname: 'Luxuary House',
                          prize: '\$2000/month',
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                'Most popular',
                style: TextStyle(
                    color: Color(0xFF575455),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 80.0,
                width: double.infinity,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    mycard1(context,
                        img:
                            'assets/images/white-modern-house-curved-patio.jpg'),
                    mycard1(context,
                        img:
                            'assets/images/blue-house-with-blue-roof-sky-background_1340-25953.jpg'),
                    mycard1(context,
                        img: 'assets/images/pexels-mark-neal-2859249.jpg'),
                    mycard1(context,
                        img:
                            'assets/images/photo-1568605114967-8130f3a36994.jpeg'),
                    mycard1(context,
                        img:
                            'assets/images/SiteImage-Landing-modern-house-plans-1.jpg'),
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
