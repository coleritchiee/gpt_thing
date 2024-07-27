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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Center(
              child: Text(
                'Deleting your account is permanent and will remove all your data. '
                    'If you wish to continue, please confirm below.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: (){
                  FirestoreService().deleteUserAccount(FirebaseAuth.instance.currentUser!.uid);
                  context.go("/");
                },
                child: const Text('Delete My Account'),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: (){
                  context.go("/");
                },
                child: const Text('Go Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}