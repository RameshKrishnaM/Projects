import 'package:ekyc/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../Model/route_model.dart';
import '../Nodifier/nodifierclass.dart';
import '../Route/route.dart' as route;

class CustomStyledContainer extends StatelessWidget {
  final Widget child;

  const CustomStyledContainer({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 1),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1.0,
              blurRadius: 5.0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: child,
        ),
      ),
    );
  }
}

class CustomHeading extends StatelessWidget {
  final String title;

  const CustomHeading({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(child: Text('')),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromRGBO(34, 147, 52, 1)),
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: const Color.fromRGBO(50, 169, 220, 1), fontSize: 17.0),
          ),
        ),
        const Expanded(child: Text('')),
        Container(
          margin: const EdgeInsets.only(bottom: 35.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: SvgPicture.asset(
                  'assets/images/ellipse .svg',
                  width: 23.0,
                  height: 23.0,
                ),
              ),
              Positioned(
                child: SvgPicture.asset(
                  'assets/images/cornericon.svg',
                  width: 15.65,
                  height: 15.65,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DottedLine extends StatelessWidget {
  final bool isHorizontal;
  const DottedLine({super.key, this.isHorizontal = true});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          direction: Axis.horizontal,
          children: List.generate(
              ((constraints.constrainWidth()) / 10).floor(),
              (index) => const SizedBox(
                    width: 6.5,
                    height: 1,
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(102, 98, 98, 1))),
                  )),
        );
      },
    );
  }
}

class ImagesWithText extends StatelessWidget {
  final BuildContext context;
  final List<String> imageUrls;
  final String text;

  const ImagesWithText({
    super.key,
    required this.context,
    required this.imageUrls,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  imageUrls[index],
                  width: 100.0, // Adjust the width of each image
                  height: 100.0, // Adjust the height of each image
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class CustomParagraph extends StatelessWidget {
  final String text;

  const CustomParagraph({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      style: Theme.of(context).textTheme.bodySmall!,
    );
  }
}

class CustomParagraph1 extends StatelessWidget {
  final String text;

  const CustomParagraph1({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(fontWeight: FontWeight.w500),
    );
  }
}

class CustomDataRow extends StatelessWidget {
  final String title1;
  final String value1;
  final String title2;
  final String value2;

  const CustomDataRow({
    super.key,
    required this.title1,
    required this.value1,
    required this.title2,
    required this.value2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomColumnWidget(title: title1, value: value1),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: CustomColumnWidget(title: title2, value: value2),
        ),
      ],
    );
  }
}

class CustomColumnWidget extends StatelessWidget {
  final String title;
  final String value;

  const CustomColumnWidget({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTitleText(
          title: title,
        ),
        const SizedBox(
          height: 3,
        ),
        CustomParagraph1(text: value)
      ],
    );
  }
}

class CustomTitleText extends StatelessWidget {
  final String title;

  const CustomTitleText({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.displayMedium!.copyWith(
            color: const Color.fromRGBO(195, 195, 195, 1),
            fontSize: 15.0,
          ),
    );
  }
}

class CustomExpansionTile extends StatefulWidget {
  final String leadingSvgAsset;
  final String title;
  final String trailingSvgAsset;
  final List<Widget> children;
  final ApplicationStage currentStatus;
  final RouteModel routeDetails;
  final String text;
  final bool? notShowEditButton;
  final onChageExpand;
  final bankData;
  final stageName;
  const CustomExpansionTile({
    Key? key,
    this.leadingSvgAsset = 'assets/images/greeny.svg',
    required this.title,
    this.trailingSvgAsset = 'assets/images/VectorEdit.svg',
    required this.children,
    required this.currentStatus,
    required this.routeDetails,
    required this.text,
    this.onChageExpand,
    this.notShowEditButton,
    this.stageName,
    this.bankData,
  }) : super(key: key);

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  late Span span;
  bool showChildren = true;
  bool showErr = false;

  @override
  void initState() {
    super.initState();
    span = Span()..setExpanded(false);
  }

  @override
  Widget build(BuildContext context) {
    Color dividerColor;
    String roundedContainerSvgAsset;

    switch (widget.currentStatus) {
      case ApplicationStage.completed:
        dividerColor = const Color.fromRGBO(50, 186, 124, 1);
        roundedContainerSvgAsset = 'assets/images/greeny.svg';
        break;
      case ApplicationStage.rejected:
        dividerColor = const Color.fromRGBO(255, 18, 18, 1);
        roundedContainerSvgAsset = 'assets/images/RedSvg.svg';
        break;
      case ApplicationStage.inProgress:
        dividerColor = const Color.fromRGBO(195, 195, 195, 1);
        roundedContainerSvgAsset = 'assets/images/GreySvg.svg';
        break;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            showChildren = !showChildren;
            if (widget.onChageExpand != null) {
              widget.onChageExpand(showChildren);
            }
            setState(() {});
          },
          child: Row(
            children: [
              CustomRoundedContainerWithSvg(
                svgAsset: widget.routeDetails.message != null
                    // roundedContainerSvgAsset
                    ? 'assets/images/RedSvg.svg'
                    : 'assets/images/greeny.svg',
                text: widget.text,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).textTheme.displayMedium!.color,
                      fontWeight: FontWeight.w500),
                ),
              ),
              (widget.notShowEditButton ?? false) ||
                      widget.routeDetails.usereditable.toUpperCase() != "Y"
                  ? SizedBox()
                  : GestureDetector(
                      onTap: () {
                        ProviderClass provider =
                            Provider.of<ProviderClass>(context, listen: false);
                        provider.changeErrMsg(widget.routeDetails.message);
                        provider.changeIsEditPage(true);
                        widget.stageName == "Aggregator"
                            ? Navigator.pushNamedAndRemoveUntil(
                                context,
                                route.aggregator,
                                arguments: {
                                  "mobileno": widget.bankData["mobileno"] ?? "",
                                  "bankname": widget.bankData["bankname"] ?? "",
                                  "maskaccount":
                                      widget.bankData["maskaccount"] ?? "",
                                  "demantdata": {},
                                },
                                (route) => route.isFirst)
                            : Navigator.pushNamedAndRemoveUntil(
                                context,
                                widget.routeDetails.routerendpoint,
                                (route) => route.isFirst);
                      },
                      child: SvgPicture.asset(
                        widget.trailingSvgAsset,
                        width: 14.06,
                        height: 14.06,
                      ),
                    ),
              const SizedBox(width: 12.0),
              showChildren
                  ? RotatedBox(
                      quarterTurns: 90,
                      child: SvgPicture.asset(
                        'assets/images/arrowdown.svg',
                        width: 7.0,
                        height: 7.0,
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/images/arrowdown.svg',
                      width: 7.0,
                      height: 7.0,
                    ),
              const SizedBox(width: 12.0),
            ],
          ),
        ),
        Divider(
          color: widget.routeDetails.message != null
              ? const Color.fromRGBO(255, 18, 18, 1)
              : const Color.fromRGBO(50, 186, 124, 1),
          thickness: 1.4,
        ),
        if (showChildren) ...[
          ...widget.children,
        ] else ...[
          const SizedBox(
            height: 10.0,
          )
        ]
      ],
    );
  }
}

class CustomRoundedContainerWithSvg extends StatelessWidget {
  final String svgAsset;
  final String text;

  const CustomRoundedContainerWithSvg({
    super.key,
    required this.svgAsset,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.0,
      height: 20.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            svgAsset,
            width: 16.0,
            height: 16.0,
            fit: BoxFit.cover,
          ),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  height: 1.1,
                  color: const Color.fromRGBO(255, 255, 255, 1),
                ),
          ),
        ],
      ),
    );
  }
}
