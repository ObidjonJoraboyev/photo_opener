import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Network images on IO platforms (disk cache via cached_network_image).
ImageProvider networkImageProvider(
  String url, {
  Map<String, String>? headers,
}) =>
    CachedNetworkImageProvider(url, headers: headers);

Widget buildNetworkThumbnail({
  required String url,
  Map<String, String>? headers,
  required double height,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, String, Object)? errorWidget,
}) {
  return CachedNetworkImage(
    imageUrl: url,
    httpHeaders: headers,
    height: height,
    fit: fit,
    errorWidget: (context, imageUrl, error) {
      if (errorWidget != null) {
        return errorWidget(context, imageUrl, error);
      }
      return const SizedBox.shrink();
    },
  );
}
