import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projectdemo2/widgets/mycolor.dart';

class PanWidget extends StatefulWidget {
  final Null Function()? onPressed;
  const PanWidget({
    super.key,
    this.onPressed,
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
        const Text(
          'Your PAN',
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
            children: [
              TextSpan(
                text:
                    '* This PAN should belongs to you,the applicant.If it does not , ',
                style: GoogleFonts.aBeeZee(
                  textStyle: TextStyle(color: textcolor2),
                ),
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
          height: 10.0,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              style: ButtonStyle(
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0))),
                backgroundColor: MaterialStatePropertyAll(
                  // Color(0XFFF8A2AD).withOpacity(0.7),
                  btcolor,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                '    Back    ',
                style: TextStyle(color: textcolor1),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0))),
                backgroundColor: MaterialStatePropertyAll(btcolor),
              ),
              onPressed: widget.onPressed,
              child: Text(
                'Continue',
                style: TextStyle(color: textcolor1),
              ),
            ),
          ],
        )
      ],
    );
  }
}
