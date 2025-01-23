import 'package:flutter/material.dart';

class SecondPage extends StatefulWidget {
  final String thumbnail;
  final String brand;
  final String name;
  final String description;
  final int price;
  final double rating;
  final double disprize;
  final int stock;
  final List images;
  const SecondPage({
    super.key,
    required this.thumbnail,
    required this.images,
    required this.brand,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.disprize,
    required this.stock,
  });
  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String select = '';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 30.0,
              bottom: 10.0,
              left: 10.0,
              right: 10.0,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.grey.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(
                      width: 120.0,
                    ),
                    Text(
                      'Details',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 17.0),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
                Expanded(
                  child: Hero(
                    tag: 'images_${widget.name}',
                    child: ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: Image.network(
                            select.isEmpty ? widget.thumbnail : select,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.images.length,
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        select = widget.images[index];
                                      });
                                    },
                                    child: Image.network(
                                      widget.images[index],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          widget.brand,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          widget.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Price : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '\$ ${widget.price} ',
                                      style: const TextStyle(
                                          height: 1.5,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Ratings : ${widget.rating}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Discount Percentage : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '\$ ${widget.disprize} ',
                                style: const TextStyle(
                                    height: 1.5,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          'Stock : ${widget.stock}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Add to Cart'),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
