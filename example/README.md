# Photo Opener — Example App

Demo app for the [`photo_opener`](../) package. Shows a row of network image previews; tap one to open the full-screen viewer at that index.

## Run

From this directory:

```bash
flutter pub get
flutter run
```

Or from the repo root:

```bash
cd example && flutter run
```

## What it demonstrates

- **`onOpenPhoto`** with `PhotoType.network` and a list of Picsum URLs
- **`initialIndex`** — each preview opens the gallery on the tapped image
- Thumbnail strip, pinch-to-zoom, swipe between images, swipe-down to dismiss

See [`lib/main.dart`](lib/main.dart) for the full source (~60 lines).

## Package docs

API reference, customization options, and asset/file examples: [main README](../README.md).
