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