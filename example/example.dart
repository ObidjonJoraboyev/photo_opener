import 'package:flutter/material.dart';
import 'package:photo_opener/photo_opener.dart';

export "../lib/photo_opener.dart";

void main() {
  runApp(MaterialApp(
    home: App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: GestureDetector(
            onTap: () {
              print('Photo opened successfully!');
              onOpenPhoto(
                context: context,
                images: [
                  "asset/image1.png",
                  "asset/image2.png",
                  "asset/image3.png",
                ],
                isNetwork: false,
              );
            },
            child: const Text("OpenImage"),
          ),
        ),
      ),
    );
  }
}
