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
        child: Column(
          children: [
            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8.0),
              children: [
                const ListTile(
                  title: Text('GPT Thing'),
                ),
                ListTile(
                  title: const Text('ChatGPT'),
                  titleTextStyle: Theme.of(context).textTheme.bodySmall,
                  leading: const Icon(Icons.chat_bubble_rounded),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('DALL·E'),
                  titleTextStyle: Theme.of(context).textTheme.bodySmall,
                  leading: const Icon(Icons.design_services_rounded),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView(
                reverse: true,
                padding: const EdgeInsets.all(8.0),
                children: [
                  ListTile(
                    title: const Text('About'),
                    titleTextStyle: Theme.of(context).textTheme.bodySmall,
                    leading: const Icon(Icons.info_rounded),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Login'),
                    titleTextStyle: Theme.of(context).textTheme.bodySmall,
                    leading: const Icon(Icons.login_rounded),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Sign Up'),
                    titleTextStyle: Theme.of(context).textTheme.bodySmall,
                    leading: const Icon(Icons.person_add_rounded),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    tileColor: Colors.green[600],
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Enter API Key'),
                    titleTextStyle: Theme.of(context).textTheme.bodySmall,
                    leading: const Icon(Icons.key_rounded),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    tileColor: Colors.blue[800],
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
