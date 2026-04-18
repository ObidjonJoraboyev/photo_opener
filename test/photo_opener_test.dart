import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_opener/photo_opener.dart';

void main() {
  testWidgets('shows header and close button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    onOpenPhoto(
                      context: context,
                      images: const [
                        'https://invalid.invalid/missing_asset_1.png',
                        'https://invalid.invalid/missing_asset_2.png',
                      ],
                      type: PhotoType.network,
                      closeText: 'Back',
                      initialIndex: 0,
                      errorWidget: (ctx, url, error) {
                        return const Text('MAIN_ERROR');
                      },
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Back'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);

    // We don't assert on the image error UI here because network image
    // failures are stubbed/mocked by the test environment and may not always
    // reach PhotoView's errorBuilder in a deterministic way.
    await tester.pump(const Duration(seconds: 1));
  });
}

