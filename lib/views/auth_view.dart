import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'user_profile_view.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // logged in
        if (snapshot.hasData) {
          return const UserProfileView();
        }

        // else show the firebase ui for login
        return SignInScreen(
          showPasswordVisibilityToggle: true,
          providers: [
            EmailAuthProvider(),
          ],
          actions: [
            AuthStateChangeAction<SignedIn>((context, state){
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const UserProfileView())
              );
            }),
            ForgotPasswordAction((context, email){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ForgotPasswordScreen(email: email),
                )
              );
            })
          ],
        );
      },
    ); 
  }
}
