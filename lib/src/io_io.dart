import 'dart:io';

import 'package:flutter/material.dart';

/// Platform and File utilities for mobile/desktop (when dart:io is available).
bool get isAndroid => Platform.isAndroid;

/// Returns an ImageProvider for a file path. Only use when dart:io is available.
ImageProvider getFileImageProvider(String path) => FileImage(File(path));

/// Returns a widget that displays a file image for thumbnails.
Widget buildFileThumbnail(String path, double height, BoxFit fit) =>
    Image.file(File(path), height: height, fit: fit);
