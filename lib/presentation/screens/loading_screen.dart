import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/everylife_logo.png',
              width: 260,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 32,
            ),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
