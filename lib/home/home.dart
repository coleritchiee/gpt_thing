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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const ListTile(
                title: Text('GPT Thing'),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: const Text('ChatGPT'),
                  titleTextStyle: Theme.of(context).textTheme.bodySmall,
                  leading: const Icon(Icons.chat_rounded),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
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
              ),
              const Spacer(), // so the rest of the column shows up at the bottom
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
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
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
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
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
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
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
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
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding (
          padding: const EdgeInsets.all(36.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 768,
            ),
            child: Column(
              children: [
                const Expanded(
                  child: Text("chat goes here"),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 215,
                  ),
                  child: TextField(
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: null,
                    autocorrect: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      hintText: 'Message ChatGPT',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                      ),
                    )
                  ), 
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
