import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'src/io_stub.dart' if (dart.library.io) 'src/io_io.dart' as io;

import 'extensions/screen_util.dart';

enum PhotoType { network, asset, file }

void onOpenPhoto({
  required BuildContext context,
  required List<String> images,
  required PhotoType type,
  Widget? closeButton,
  Widget Function(BuildContext, String, Object)? errorWidget,
  String? closeText,
  Color? backgroundColor,
  Color? secondaryColor,
  Color? loaderColor,
  double? maxScale,
  double? minScale,
  PageController? pageController,
  ValueChanged<int>? onPageChange,
  TextStyle? topTextStyle,
  double? leftPadding,
  Map<String, String>? httpHeaders,
  int initialIndex = 0,
  VoidCallback? onClose,
}) {
  if (images.isEmpty) return;
  showDialog(
    useSafeArea: false,
    barrierColor: Colors.transparent,
    context: context,
    builder: (context) {
      return _PhotoOpenerDialog(
        images: images,
        type: type,
        closeButton: closeButton,
        errorWidget: errorWidget,
        closeText: closeText,
        backgroundColor: backgroundColor,
        secondaryColor: secondaryColor,
        loaderColor: loaderColor,
        maxScale: maxScale,
        minScale: minScale,
        pageController: pageController,
        onPageChange: onPageChange,
        topTextStyle: topTextStyle,
        leftPadding: leftPadding,
        httpHeaders: httpHeaders,
        initialIndex: initialIndex,
        onClose: onClose,
      );
    },
  );
}

class _PhotoOpenerDialog extends StatefulWidget {
  const _PhotoOpenerDialog({
    required this.images,
    required this.type,
    required this.closeButton,
    required this.errorWidget,
    required this.closeText,
    required this.backgroundColor,
    required this.secondaryColor,
    required this.loaderColor,
    required this.maxScale,
    required this.minScale,
    required this.pageController,
    required this.onPageChange,
    required this.topTextStyle,
    required this.leftPadding,
    required this.httpHeaders,
    required this.initialIndex,
    required this.onClose,
  });

  final List<String> images;
  final PhotoType type;
  final Widget? closeButton;
  final Widget Function(BuildContext, String, Object)? errorWidget;
  final String? closeText;
  final Color? backgroundColor;
  final Color? secondaryColor;
  final Color? loaderColor;
  final double? maxScale;
  final double? minScale;
  final PageController? pageController;
  final ValueChanged<int>? onPageChange;
  final TextStyle? topTextStyle;
  final double? leftPadding;
  final Map<String, String>? httpHeaders;
  final int initialIndex;
  final VoidCallback? onClose;

  @override
  State<_PhotoOpenerDialog> createState() => _PhotoOpenerDialogState();
}

class _PhotoOpenerDialogState extends State<_PhotoOpenerDialog> {
  final PhotoViewScaleStateController _photoController =
      PhotoViewScaleStateController();

  late final PageController _pageCtrl;
  bool _ownsPageController = true;

  final ScrollController _scrollController = ScrollController();

  SystemUiMode _lastMode = SystemUiMode.edgeToEdge;
  double _barrierColor = 1;
  bool _isOpen = true;

  PhotoViewScaleState _scaleState = PhotoViewScaleState.initial;

  late int _currentIndex;
  late int _currentPage;

  bool _didInit = false;

  double get _fullHeight => MediaQuery.sizeOf(context).height;
  double get _fullWidth => MediaQuery.sizeOf(context).width;

  _PhotoOpenerDialogState();

  @override
  void initState() {
    super.initState();

    final maxIndex = widget.images.isEmpty ? 0 : widget.images.length - 1;
    _currentIndex = widget.initialIndex.clamp(0, maxIndex);
    _currentPage = _currentIndex + 1;

    if (widget.pageController == null) {
      _pageCtrl = PageController(initialPage: _currentIndex);
      _ownsPageController = true;
    } else {
      _pageCtrl = widget.pageController!;
      _ownsPageController = false;
    }

    _photoController.reset();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_didInit) return;
      _didInit = true;

      // Ensure the desired starting page is selected.
      _pageCtrl.jumpToPage(_currentIndex);

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _thumbOffsetForPage(_currentIndex),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_ownsPageController) {
      _pageCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _setUIMode(SystemUiMode mode) async {
    if (_lastMode == mode) return;
    _lastMode = mode;
    await SystemChrome.setEnabledSystemUIMode(mode);
  }

  double _thumbOffsetForPage(int page) {
    final length = widget.images.length;
    if (length <= 0) return 0;
    return page * (38.sp + (12.w / length));
  }

  ImageProvider _imageProviderForIndex(int index) {
    final urlOrPath = widget.images[index];
    if (widget.type == PhotoType.asset) {
      return AssetImage(urlOrPath);
    }
    if (widget.type == PhotoType.network) {
      return CachedNetworkImageProvider(
        urlOrPath,
        headers: widget.httpHeaders,
      );
    }

    // PhotoType.file
    if (kIsWeb) {
      // Transparent placeholder (file paths are not supported on web).
      return MemoryImage(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
        ),
      );
    }
    return io.getFileImageProvider(urlOrPath);
  }

  Widget _buildGalleryError(BuildContext context, int index, Object error) {
    final callback = widget.errorWidget;
    if (callback != null) {
      return Center(child: callback(context, widget.images[index], error));
    }
    return const Center(
      child: Icon(
        Icons.broken_image,
        size: 64,
        color: Colors.white70,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.sizeOf(context).width;
    height = MediaQuery.sizeOf(context).height;

    return Container(
      height: _fullHeight,
      decoration: BoxDecoration(
        color: widget.backgroundColor != null
            ? widget.backgroundColor!.withAlpha((_barrierColor * 255).toInt())
            : Colors.black.withAlpha((_barrierColor * 255).toInt()),
      ),
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: GestureDetector(
          onTap: () async {
            _isOpen = !_isOpen;
            setState(() {});
            await _setUIMode(
              _isOpen ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
            );
            await Future.delayed(const Duration(milliseconds: 20));
            if (_scrollController.positions.isNotEmpty && _isOpen) {
              _scrollController.jumpTo(_thumbOffsetForPage(_currentIndex));
            }
          },
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Dismissible(
                onUpdate: (v) {
                  _barrierColor = (1 - v.progress * 4).clamp(0.0, 1.0);
                  setState(() {});
                },
                movementDuration: const Duration(milliseconds: 500),
                resizeDuration: const Duration(milliseconds: 1),
                onDismissed: (_) async {
                  await _setUIMode(SystemUiMode.edgeToEdge);
                  if (!context.mounted) return;
                  _barrierColor = 1;
                  widget.onClose?.call();
                  Navigator.pop(context);
                },
                direction: _scaleState == PhotoViewScaleState.initial ||
                        _scaleState ==
                            PhotoViewScaleState.originalSize ||
                        _scaleState == PhotoViewScaleState.covering
                    ? DismissDirection.vertical
                    : DismissDirection.none,
                key: const Key('photo_opener_dismiss'),
                child: SizedBox(
                  height: _fullHeight,
                  child: PhotoViewGallery.builder(
                    pageController: _pageCtrl,
                    onPageChanged: (v) async {
                      if (_scrollController.positions.isNotEmpty) {
                        if (_currentIndex < v) {
                          final target = _thumbOffsetForPage(v);
                          final maxExtent = _scrollController.position.maxScrollExtent;
                          if (target < maxExtent) {
                            await _scrollController.animateTo(
                              target,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            await _scrollController.animateTo(
                              maxExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        } else if (_currentIndex > v) {
                          final target = _thumbOffsetForPage(v);
                          final minExtent = _scrollController.position.minScrollExtent;
                          if (target > minExtent) {
                            await _scrollController.animateTo(
                              target,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            await _scrollController.animateTo(
                              minExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        }

                        if (v == _currentIndex) {
                          await _scrollController.animateTo(
                            _scrollController.position.minScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      }

                      _currentPage = v + 1;
                      _currentIndex = v;
                      setState(() {});
                      _photoController.reset();
                      widget.onPageChange?.call(v);
                    },
                    scaleStateChangedCallback: (v) {
                      _scaleState = v;
                      setState(() {});
                    },
                    scrollPhysics: const BouncingScrollPhysics(),
                    builder: (BuildContext context, int index) {
                      final imageProvider = _imageProviderForIndex(index);
                      return PhotoViewGalleryPageOptions(
                        scaleStateController: _photoController,
                        imageProvider: imageProvider,
                        maxScale: PhotoViewComputedScale.contained *
                            (widget.maxScale ?? 5),
                        initialScale: PhotoViewComputedScale.contained * 1,
                        minScale: PhotoViewComputedScale.contained *
                            (widget.minScale ?? 1),
                        errorBuilder: (ctx, error, _) =>
                            _buildGalleryError(ctx, index, error),
                      );
                    },
                    itemCount: widget.images.length,
                    loadingBuilder: (context, event) => Center(
                      child: SizedBox(
                        width: 20.sp,
                        height: 20.sp,
                        child: CircularProgressIndicator(
                          color: widget.loaderColor ?? Colors.grey,
                          value: event == null
                              ? 0
                              : event.cumulativeBytesLoaded /
                                  event.expectedTotalBytes!.toInt(),
                        ),
                      ),
                    ),
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _isOpen
                    ? Opacity(
                        opacity: _barrierColor,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            color: (widget.secondaryColor ?? Colors.black)
                                .withAlpha(
                              ((_barrierColor > 0.99 ? 0.5 : _barrierColor / 2) *
                                      255)
                                  .toInt(),
                            ),
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top +
                                  (io.isAndroid ? 10.h : 0),
                              left: widget.leftPadding ?? 21.w,
                              right: 21.w,
                              bottom: 5.h,
                            ),
                            child: widget.closeButton ??
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        widget.onClose?.call();
                                        Navigator.pop(context);
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(
                                            CupertinoIcons.back,
                                            color: CupertinoColors.white,
                                          ),
                                          Text(
                                            widget.closeText ?? "Back",
                                            style: TextStyle(
                                              color: CupertinoColors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _isOpen
                    ? Opacity(
                        opacity: _barrierColor,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top +
                                  (io.isAndroid ? 10.h : 0),
                              left: 21.w,
                              right: 21.w,
                              bottom: 5.h,
                            ),
                            child: Text(
                              "$_currentPage/${widget.images.length}",
                              style: widget.topTextStyle ??
                                  TextStyle(
                                    color: CupertinoColors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                  ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
              Positioned(
                bottom: 0,
                child: AnimatedSwitcher(
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  duration: const Duration(milliseconds: 200),
                  child: _isOpen
                      ? Opacity(
                          opacity: _barrierColor,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              width: _fullWidth,
                              color: (widget.secondaryColor ?? Colors.black)
                                  .withAlpha(
                                ((_barrierColor > 0.99 ? 0.5 : _barrierColor / 2) *
                                        255)
                                    .toInt(),
                              ),
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).padding.bottom +
                                    (io.isAndroid ? 10.h : 0),
                                left: 0.w,
                                right: 0.w,
                                top: 8.h,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _scrollController,
                                physics: const NeverScrollableScrollPhysics(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: _fullWidth / 2 - 23.5.w,
                                    ),
                                    ...List.generate(widget.images.length, (index) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2.w,
                                        ),
                                        child: GestureDetector(
                                          onTap: () async {
                                            await Future.delayed(
                                              const Duration(milliseconds: 20),
                                            );
                                            _pageCtrl.jumpToPage(index);
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              width: 35.sp +
                                                  (index == _currentPage - 1
                                                      ? 12.w
                                                      : 0),
                                              child: _buildThumbnailChild(index),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                    SizedBox(
                                      width: _fullWidth / 2 - 23.5.w,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailChild(int index) {
    if (widget.type == PhotoType.network) {
      return CachedNetworkImage(
        imageUrl: widget.images[index],
        httpHeaders: widget.httpHeaders,
        height: 45.sp,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) {
          final callback = widget.errorWidget;
          if (callback != null) {
            return callback(context, url, error);
          }
          return const SizedBox.shrink();
        },
      );
    }

    if (widget.type == PhotoType.asset) {
      return Image.asset(
        widget.images[index],
        height: 45.sp,
        fit: BoxFit.cover,
      );
    }

    // File thumbnails (supported on non-web).
    return io.buildFileThumbnail(
      widget.images[index],
      45.sp,
      BoxFit.cover,
    );
  }
}
