import 'package:flutter/material.dart';

class LogViewOut extends StatelessWidget {
  const LogViewOut({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Log in to log your trail experiences!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )
            ),
          ],
        )
      ),
    );
  }
}