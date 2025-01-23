import 'package:flutter/material.dart';

class StarsWidget extends StatefulWidget {
  final int stars;

  const StarsWidget({
    super.key,
    required this.stars,
  });

  @override
  State<StarsWidget> createState() => _StarsWidgetState();
}

class _StarsWidgetState extends State<StarsWidget> {
  @override
  Widget build(BuildContext context) {
    final allStars = List.generate(widget.stars, (index) => index);

    return Row(
      children: allStars
          .map((star) => Container(
                margin: EdgeInsets.only(right: 4),
                child: Icon(Icons.star_rate, size: 18, color: Colors.blueGrey),
              ))
          .toList(),
    );
  }
}
