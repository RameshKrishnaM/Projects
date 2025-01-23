import 'package:flutter/material.dart';

class CartAnimation extends StatefulWidget {
  const CartAnimation({super.key});

  @override
  State<CartAnimation> createState() => _CartAnimationState();
}

class _CartAnimationState extends State<CartAnimation> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: AnimatedContainer(
              height: 50,
              width: isExpanded ? 200 : 70,
              decoration: BoxDecoration(
                color: isExpanded ? Colors.green : Colors.blue,
                borderRadius: BorderRadius.circular(
                  isExpanded ? 30.0 : 10.0,
                ),
              ),
              duration: const Duration(milliseconds: 1000),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    isExpanded ? Icons.check : Icons.shopping_cart,
                  ),
                  if (isExpanded)
                    const Flexible(
                      child: Text(
                        'Added to Cart',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
