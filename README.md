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


If you are looking for a package to open and zoom in or out images, this package is for you

## Features

This package allows you to open your images on a large screen and zoom in or out.


## Usage

```dart
const onTap = (){
onOpenPhoto(
    context: context,
    closeText: "back".tr(),
    secondaryColor: Colors.black,
    backgroundColor: Colors.black,
    pageController: pageController,
    onPageChange: (newPage) {
      print(newPage);
    },
    minScale: 1,
    maxScale: 5,
    loaderColor: Colors.red,
    topTextStyle: const TextStyle(
        color: CupertinoColors.white, fontWeight: FontWeight.w600),
    images: [
      "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Big_Ben_2007-1.jpg/1200px-Big_Ben_2007-1.jpg",
      "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Big_Ben_2007-1.jpg/1200px-Big_Ben_2007-1.jpg",
      "https://media.istockphoto.com/id/510469242/photo/business-towers.jpg?b=1&s=612x612&w=0&k=20&c=4rJMUURzWnASVu2HTg6C25_jz0ktq3NzAcq5NKuIExE="
    ],
);
```
