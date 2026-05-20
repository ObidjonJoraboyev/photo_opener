## 0.3.0 - 2026-05-20

### Added
- `initialIndex` support: open the gallery on any image with the correct page, counter, and thumbnail strip position
- Default gallery error UI (broken-image icon) when `errorWidget` is not provided
- Full Flutter example app (Android and iOS) with tap-to-open previews that pass `initialIndex`

### Fixed
- Refactored the viewer into a `StatefulWidget` so `PageController` and `ScrollController` are disposed reliably
- Thumbnail strip scroll respects min/max scroll extents when swiping between pages
- Custom `errorWidget` is used for both the main gallery and network thumbnails
- No-op when `images` is empty
- Opening at `initialIndex` > 0: thumbnail strip starts at the right offset without a visible scroll animation

### Changed
- Chrome UI (back button, page counter, thumbnails) fades with swipe/dismiss progress via `AnimatedOpacity`
- Back button icon changed from `CupertinoIcons.back` to `Icons.arrow_back_ios`
- `PhotoType` checks use enum comparison instead of string `.name` comparison

## 0.2.9 - 2026-03-22
### Added
- Web platform support with conditional imports (no dart:io on web)
- Installation and Quick Start sections in README
- Platform support table and improved pub.dev documentation

### Fixed
- Web compatibility: use `io_stub`/`io_io` for Platform and File
- Screen util fallback when width/height not yet initialized
- Example app structure (proper pubspec, lib/main.dart)
- README examples (type: PhotoType, remove debug print, fix MaterialApp)

### Changed
- Exclude gif/ from published package via .pubignore (reduces package size)

## 0.2.8 - 2026-02-18
### Added
Introduce `PhotoType` and support local file images

- Add `PhotoType` enum with `network`, `asset`, and `file` options for better type safety.
- Replace `isNetwork` boolean with `type` parameter in `onOpenPhoto`.
- Implement support for `FileImage` and `Image.file` to allow viewing local device images.
- Update `imageProvider` logic in `PhotoViewGalleryPageOptions` to handle all supported photo types.
- Refactor image loading in the thumbnail preview list to support `PhotoType`.





## 0.2.7 - 2026-02-03
### Added
- Support for an optional **httpHeaders** parameter to pass headers for network images downloading.
- Support for an optional onErrorWidget parameter to show a custom widget when image loading fails.

### Improved
- Showing hints in the documentation on how to use **Bearer Token** for authorization.
- Replace NetworkImageProvider with CachedNetworkImageProvider to improve network images loading.
- Use Picsum images in the example for network images.

### Fixed
- Fix the issue with **No MaterialLocalizations found.** with example/example.dart

## 0.2.3 - 2025-08-12
### Added
- Support for opening images from both **assets** and **network URLs**.
- Smooth zoom and pan gestures similar to **Telegram**.
- Swipe down to close feature for a natural user experience.

### Improved
- Performance optimizations for large image loading.
- Better caching with `cached_network_image` package.

### Fixed
- Minor bug fixes and UI improvements.