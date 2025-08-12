<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->


## 📸 Photo Opener
A Flutter package to open and zoom images with smooth gestures and customizable UI.
Perfect for displaying images in full-screen mode with pinch-to-zoom functionality.

## ✨ Features
🖼 Open images in a full-screen viewer

🔍 Zoom in/out with smooth pinch gestures

🌈 Customizable colors, paddings, and styles

📜 Support for multiple images with swipe

🌐 Works with local assets or network images


## 📷 Preview

![Demo](https://raw.githubusercontent.com/ObidjonJoraboyev/photo_opener/main/gif/example.gif)



## 📖 Usage

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_opener/photo_opener.dart';

class PhotoOpenerExample extends StatefulWidget {
  const PhotoOpenerExample({super.key});

  @override
  State<PhotoOpenerExample> createState() => _PhotoOpenerExampleState();
}

class _PhotoOpenerExampleState extends State<PhotoOpenerExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Example Photo Opener"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              PageController pageController = PageController();
              onOpenPhoto(
                context: context,
                closeText: "Back",
                secondaryColor: Colors.black,
                backgroundColor: Colors.black,
                pageController: pageController,
                onPageChange: (newPage) {},
                minScale: 1,
                maxScale: 5,
                loaderColor: Colors.red,
                leftPadding: 20,
                isNetwork: false,
                initialIndex: 2,
                topTextStyle: const TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                ),
                images: [
                  "assets/images/example_1.png",
                  "assets/images/example_2.png",
                  "assets/images/example_3.png",
                ],
              );
            },
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  "assets/images/example_1.png",
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 📜 License
This package is licensed under the MIT License.
Feel free to use it in your projects.


