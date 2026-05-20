import 'package:flutter/material.dart';
import 'package:photo_opener/extensions/screen_util.dart';
import 'package:photo_opener/photo_opener.dart';

void main() {
  runApp(MaterialApp(
    home: App(),
    debugShowCheckedModeBanner: false,
  ));
}

class App extends StatelessWidget {
  App({super.key});

  final imageList = [
    'https://picsum.photos/seed/mp03/800/800',
    'https://picsum.photos/seed/mp04/800/800',
    'https://picsum.photos/seed/mp05/800/800',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Photo Opener Example')),
      body: Center(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ...List.generate(3, (index) {
            return GestureDetector(
              onTap: () {
                onOpenPhoto(
                    context: context,
                    images: imageList,
                    type: PhotoType.network,
                    initialIndex: index);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    imageList[index],
                    width: 82,
                    fit: BoxFit.cover,
                    height: 85,
                  ),
                ),
              ),
            );
          })
        ]),
      ),
    );
  }
}
