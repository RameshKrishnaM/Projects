
import 'package:ekycold/util/colors.dart';
import 'package:ekycold/widgets/custom_button_small.dart';
import 'package:flutter/material.dart';

class PanWidget extends StatefulWidget {
  final Null Function()? onPressed;
  final onPressedBack;
  final bool isFinalPage;
  const PanWidget({
    super.key,
    this.onPressed,
    this.isFinalPage = false,
    this.onPressedBack,
  });

  @override
  State<PanWidget> createState() => _PanWidgetState();
}

class _PanWidgetState extends State<PanWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your PAN',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'LVZPS1234L',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: highlightcolor,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(
                text:
                    '* This PAN should belongs to you,the applicant.If it does not , ',
              ),
              WidgetSpan(
                child: InkWell(
                  onTap: () {},
                  child: Text(
                    'start over',
                    style: TextStyle(
                      color: highlightcolor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15.0,
        ),
        Visibility(
          visible: !widget.isFinalPage,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButtonSmall(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Back',
                ),
              ),
              CustomButtonSmall(
                onPressed: widget.onPressed,
                child: Text('Continue'),
              )
            ],
          ),
        )
      ],
    );
  }
}
