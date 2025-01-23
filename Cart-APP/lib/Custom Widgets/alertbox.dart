import 'package:flutter/material.dart';

openAlertBox(
    {required BuildContext context,
    String? title,
    required String content,
    required onpressedButton1,
    onpressedButton2,
    String? button1Content,
    String? button2Content,
    Color? button1color,
    Color? button2color,
    bool needButton2 = true,
    barrierDismissible = true,
    canPop = true}) {
  showDialog(
    barrierDismissible: barrierDismissible,
    context: context,
    builder: (context) {
      return PopScope(
        canPop: canPop,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10.0),
              ],
              Text(
                content,
                style: Theme.of(context).textTheme.displayMedium,
              )
            ],
          ),
          actions: [
            SizedBox(
              height: 30.0,
              child: ElevatedButton(
                  style: ButtonStyle(
                    elevation: const MaterialStatePropertyAll(0),
                    backgroundColor: MaterialStatePropertyAll(
                        button1color ?? Theme.of(context).colorScheme.primary),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6))),
                  ),
                  onPressed: onpressedButton1,
                  child: Text(button1Content ?? "Yes")),
            ),
            if (needButton2) ...[
              SizedBox(
                height: 30.0,
                child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(0),
                      backgroundColor: MaterialStatePropertyAll(button2color ??
                          Theme.of(context).colorScheme.primary),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6))),
                    ),
                    onPressed: () {
                      onpressedButton2 != null
                          ? onpressedButton2()
                          : Navigator.pop(context);
                    },
                    child: Text(button2Content ?? "No")),
              )
            ]
          ],
        ),
      );
    },
  );
}
