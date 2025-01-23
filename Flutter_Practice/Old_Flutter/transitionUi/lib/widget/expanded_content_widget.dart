import 'package:flutter/material.dart';
import 'package:transitionui/model/location.dart';
import 'package:transitionui/widget/stars_widget.dart';

class ExpandedContentWidget extends StatefulWidget {
  final Location location;

  const ExpandedContentWidget({
    super.key,
    required this.location,
  });

  @override
  State<ExpandedContentWidget> createState() => _ExpandedContentWidgetState();
}

class _ExpandedContentWidgetState extends State<ExpandedContentWidget> {
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(widget.location.addressLine1),
            const SizedBox(height: 8),
            buildAddressRating(location: widget.location),
            const SizedBox(height: 12),
            buildReview(location: widget.location)
          ],
        ),
      );

  Widget buildAddressRating({
    required Location location,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            location.addressLine2,
            style: const TextStyle(color: Colors.black45),
          ),
          StarsWidget(stars: location.starRating),
        ],
      );

  Widget buildReview({
    required Location location,
  }) =>
      Row(
        children: location.reviews
            .map(
              (review) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.black12,
                  backgroundImage: AssetImage(review.urlImage),
                ),
              ),
            )
            .toList(),
      );
}
