import 'package:flutter/material.dart';

/// Stub for web platform where dart:io is not available.
bool get isAndroid => false;

/// Throws on web - File paths are not supported. Use network URLs or assets.
ImageProvider getFileImageProvider(String path) =>
    throw UnsupportedError('File paths are not supported on web. Use network URLs or assets instead.');

/// Placeholder for file thumbnails on web (file paths not supported).
Widget buildFileThumbnail(String path, double height, BoxFit fit) =>
    Container(
      height: height,
      color: Colors.grey.shade800,
      child: const Icon(Icons.insert_drive_file, color: Colors.white54),
    );
