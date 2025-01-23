import 'package:ekycold/util/colors.dart';
import 'package:ekycold/widgets/background_animated_container.dart';
import 'package:flutter/material.dart';

class Equity extends StatefulWidget {
  const Equity({super.key});

  @override
  State<Equity> createState() => _EquityState();
}

class _EquityState extends State<Equity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(15.0),
          children: [
            Text(
              'Equity',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'This will be your account to buy and sell shares, mutual funds, and derivatives on NSE and BSE.',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 10),
            Text.rich(
              textAlign: TextAlign.justify,
              TextSpan(
                children: [
                  const TextSpan(
                    text:
                        "Don't have Aadhar and mobile linked to eSign? Download ",
                  ),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Equity form',
                        style: TextStyle(
                          color: highlightcolor,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(
                    text: ' and courier it to us. ',
                  ),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Learn more',
                        style: TextStyle(
                          color: highlightcolor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const BackgroundAnimatedContainer(image: 'equity.png'),
            const SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Enable commodity account',
                style: TextStyle(
                  color: highlightcolor,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
