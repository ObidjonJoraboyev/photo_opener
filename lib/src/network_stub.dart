import 'package:flutter/material.dart';

/// Network images on web / WASM (no cached_network_image / dart:io).
ImageProvider networkImageProvider(
  String url, {
  Map<String, String>? headers,
}) =>
    NetworkImage(url, headers: headers);

Widget buildNetworkThumbnail({
  required String url,
  Map<String, String>? headers,
  required double height,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, String, Object)? errorWidget,
}) {
  return Image.network(
    url,
    headers: headers,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) {
      if (errorWidget != null) {
        return errorWidget(context, url, error);
      }
      return const SizedBox.shrink();
    },
  );
}
