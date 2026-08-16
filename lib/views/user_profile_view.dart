import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Logged In"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
            "Welcome ${user?.email ?? "User"} \n You're signed in! \n You can now log your entrires.",
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            child: Text("Sign out"),
          )
          ],
        )

      )
    );
  }
}