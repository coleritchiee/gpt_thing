import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeySetDialog extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          const Text("Enter API key"),
          const TextField(),
          const TextField(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Set'),
                onPressed: () {
                  print("key set");
                  Navigator.pop(context);
                },
              ),
            ]
          )
        ]
      ),
    );
  }
}