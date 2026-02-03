## 0.2.4 - 2026-02-03
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