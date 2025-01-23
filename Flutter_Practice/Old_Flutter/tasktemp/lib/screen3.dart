import 'package:flutter/material.dart';
import 'package:tasktemp/customWidget1.dart';

import 'route.dart' as route;

class Screen3 extends StatefulWidget {
  const Screen3({super.key});

  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading: ,),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, route.screen2);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(
                    width: 90.0,
                  ),
                  Text(
                    'Details',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.7),
                        fontSize: 17.0),
                  ),
                  const Expanded(
                    child: Text(''),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                child: Image.asset(
                  'assets/images/Bangalore-rustic-home-interiors-architecture.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 13.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Wooden Like House',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    '\$2600/month',
                    style: TextStyle(
                      color: Color.fromRGBO(46, 123, 170, 1),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    const WidgetSpan(
                      child: Icon(
                        Icons.location_on,
                        size: 15.0,
                        color: Colors.grey,
                      ),
                    ),
                    TextSpan(
                      text: '111/A,Street-4,Sydney,Australia',
                      style: TextStyle(
                          color: Colors.grey.withOpacity(0.8), fontSize: 11.0),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                'House information',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              SizedBox(
                height: 70,
                width: double.infinity,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Row(
                      children: [
                        cardIcon(
                          context,
                          iconData: Icons.bed_rounded,
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        cardIcon(
                          context,
                          iconData: Icons.bathtub_outlined,
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        cardIcon(
                          context,
                          iconData: Icons.coffee_maker_outlined,
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        cardIcon(
                          context,
                          iconData: Icons.table_bar_outlined,
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                'House Information',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          'Amat minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit.Exercitation veniam consequat sunt nostrud amet.',
                      style: TextStyle(
                          fontSize: 11.0,
                          height: 1.5,
                          color: Colors.grey.withOpacity(0.8),
                          fontWeight: FontWeight.bold),
                    ),
                    const WidgetSpan(
                      child: InkWell(
                        child: Text(
                          ' Read more',
                          style: TextStyle(
                            fontSize: 11.0,
                            color: Color(0xFF5076FB),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              InkWell(
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 13.0,
                  ),
                  padding: const EdgeInsets.all(15.0),
                  width: MediaQuery.of(context).size.height * 0.48,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(80, 118, 251, 1.0),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Center(
                    child: Text(
                      'Rent now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
