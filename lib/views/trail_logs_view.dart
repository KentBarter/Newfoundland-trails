import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'log_view_out.dart';
import 'log_view_in.dart';

class TrailLogsView extends StatelessWidget {
  const TrailLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // logged in
        if (snapshot.hasData) {
          return LogViewIn();
        }
        return LogViewOut();
      }
    );
  }
}