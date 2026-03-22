import 'package:flutter/material.dart';
import 'package:photo_opener/photo_opener.dart';

void main() {
  runApp(const MaterialApp(home: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Opener Example')),
      body: Center(
        child: GestureDetector(
          onTap: () {
            onOpenPhoto(
              context: context,
              images: [
                'https://picsum.photos/id/1/1024/768',
                'https://picsum.photos/id/2/1024/768',
                'https://picsum.photos/id/3/1024/768',
              ],
              type: PhotoType.network,
            );
          },
          child: const Text('Open Images'),
        ),
      ),
    );
  }
}
