import 'package:flutter/material.dart';

class DropdownMenuExample extends StatelessWidget {
  const DropdownMenuExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        print(value);
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'profile',
            child: Text('profile'),
          ),
          const PopupMenuItem<String>(
            value: 'add',
            child: Text('add'),
          ),
          const PopupMenuItem<String>(
            value: 'refresh',
            child: Text('refresh'),
          ),
          const PopupMenuItem<String>(
            value: 'settings',
            child: Text('settings'),
          ),
        ];
      },
    );
  }
}
