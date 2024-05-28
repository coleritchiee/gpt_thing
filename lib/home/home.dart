import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPT Thing'),
      ),

      drawer: Drawer(
        shape: const LinearBorder(),
        child: ListView(
          children: [
            ListTile(
              title: const Text('GPT Thing'),
            ),
            ListTile(
              title: const Text('ChatGPT'),
              titleTextStyle: Theme.of(context).textTheme.bodySmall,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('DALL·E'),
              titleTextStyle: Theme.of(context).textTheme.bodySmall,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Login'),
              titleTextStyle: Theme.of(context).textTheme.bodySmall,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}