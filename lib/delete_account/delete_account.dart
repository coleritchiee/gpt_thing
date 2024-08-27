import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_thing/services/firestore.dart';

class DeleteAccountPage extends StatelessWidget {
  const DeleteAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      context.go("/login-delete-account");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatKeyPT"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Deleting your account is permanent and will remove all your data.',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const DeleteDialog();
                        },
                      );
                    },
                    child: const Text('Delete My Account'),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      context.go("/");
                    },
                    child: const Text('Go Back'),
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

class DeleteDialog extends StatefulWidget {
  const DeleteDialog({super.key});

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  bool switch1 = false;
  bool switch2 = false;
  bool switch3 = false;

  bool isReady() {
    return switch1 && switch2 && switch3;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Deletion'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Are you sure you want to delete your account?'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RotatedBox(
                  quarterTurns: 3,
                  child: Switch(
                    value: switch1,
                    onChanged: (val) {
                      setState(() {
                        switch1 = val;
                      });
                    },
                  )),
              RotatedBox(
                  quarterTurns: 3,
                  child: Switch(
                    value: switch2,
                    onChanged: (val) {
                      setState(() {
                        switch2 = val;
                      });
                    },
                  )),
              RotatedBox(
                  quarterTurns: 3,
                  child: Switch(
                    value: switch3,
                    onChanged: (val) {
                      setState(() {
                        switch3 = val;
                      });
                    },
                  )),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Flip the 3 switches to confirm.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: !isReady() ? null : () async {
            await FirestoreService()
                .deleteUserAccount(FirebaseAuth.instance.currentUser!.uid);
            context.go("/");
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
