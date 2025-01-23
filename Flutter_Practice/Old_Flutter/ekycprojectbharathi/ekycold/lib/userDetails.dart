import 'package:ekycold/style.dart';
import 'package:flutter/material.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 15,
          ),
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'Email Id : ',
                style: AppFont.body(
                        textColor: AppColors.secondary,
                        fontWeight: FontWeight.w600)
                    .primary),
            TextSpan(
                text: 'abc@gmail.com',
                style: AppFont.body(
                        textColor: AppColors.darkSecondary,
                        fontWeight: FontWeight.w600)
                    .secondary),
          ])),
          const SizedBox(
            height: 15,
          ),
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'Mobile No : ',
                style: AppFont.body(
                        textColor: AppColors.secondary,
                        fontWeight: FontWeight.w600)
                    .primary),
            TextSpan(
                text: '9876543210',
                style: AppFont.body(
                        textColor: AppColors.darkSecondary,
                        fontWeight: FontWeight.w600)
                    .secondary),
          ])),
          const SizedBox(
            height: 15,
          ),
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'Application No : ',
                style: AppFont.body(
                        textColor: AppColors.secondary,
                        fontWeight: FontWeight.w600)
                    .primary),
            TextSpan(
                text: 'ABC11111',
                style: AppFont.body(
                        textColor: AppColors.darkSecondary,
                        fontWeight: FontWeight.w600)
                    .secondary),
          ])),
          const SizedBox(
            height: 15,
          ),
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: 'Application Status : ',
                style: AppFont.body(
                        textColor: AppColors.secondary,
                        fontWeight: FontWeight.w600)
                    .primary),
            TextSpan(
                text: 'Pending',
                style: AppFont.body(
                        textColor: AppColors.darkSecondary,
                        fontWeight: FontWeight.w600)
                    .secondary),
          ])),
        ],
      ),
    );
  }
}
