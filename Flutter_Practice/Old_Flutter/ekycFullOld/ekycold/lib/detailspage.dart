import 'package:ekycold/widgets/background_animated_container.dart';
import 'package:ekycold/widgets/panwidget.dart';
import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  about({required String img, required String txt}) {
    return Row(
      children: [
        Image.asset(
          img,
          color: const Color.fromRGBO(8, 27, 60, 0.6),
          height: 23,
          width: 23,
        ),
        const SizedBox(width: 20.0),
        Expanded(
          child: Text(
            txt,
            style: const TextStyle(fontSize: 16.0),
          ),
        ),
      ],
    );
  }

  String text = 'male';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(15.0),
          children: [
            const BackgroundAnimatedContainer(image: 'details.png'),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              'Details',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 10,
            ),
            about(img: 'assets/images/id.png', txt: 'Selvam'),
            const SizedBox(
              height: 10,
            ),
            about(img: 'assets/images/dob.png', txt: '23/12/2001'),
            const SizedBox(
              height: 10,
            ),
            about(
              img: text == 'male'
                  ? 'assets/images/male.png'
                  : 'assets/images/female.png',
              txt: text == 'male' ? 'Male' : 'Female',
            ),
            const SizedBox(
              height: 10,
            ),
            about(img: 'assets/images/mail.png', txt: 'abcd123@gmail.com'),
            const SizedBox(
              height: 10,
            ),
            about(
              img: 'assets/images/home.png',
              txt:
                  '59 Vaisiyar Street Tiyagadurugam Kallakurichi Taluk Viluppuram Tamil Nadu 606206 India',
            ),
            const SizedBox(
              height: 15,
            ),
            PanWidget(
              onPressed: () {},
              isFinalPage: true,
            ),
          ],
        ),
      ),
    );
  }
}
