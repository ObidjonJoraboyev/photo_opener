import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'extensions/screen_util.dart';

onOpenPhoto({
  required BuildContext context,
  required List<String> images,
  Widget? closeButton,
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
  bool isNetwork = true,
  int initialIndex = 0,
  VoidCallback? onClose,
}) {
  double barrierColor = 1;
  bool isOpen = true;
  double fullHeight = MediaQuery.sizeOf(context).height;
  double fullWidth = MediaQuery.sizeOf(context).width;
  PhotoViewScaleState state = PhotoViewScaleState.initial;
  final PageController pageCtrl = pageController ?? PageController();
  int currentPage = 1;
  int currentIndex = 0;
  PhotoViewScaleStateController photoController =
      PhotoViewScaleStateController();
  ScrollController scrollController = ScrollController();

  isOpen = true;
  currentPage = 1;
  photoController.reset();
  showDialog(
      useSafeArea: false,
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        Future.microtask(() async {
          pageCtrl.jumpToPage(initialIndex);
          scrollController.animateTo(
              initialIndex * (38.sp + (12.w / images.length)),
              duration: const Duration(microseconds: 300),
              curve: Curves.easeInOut);
        });
        return StatefulBuilder(builder: (context, setState) {
          width = MediaQuery.sizeOf(context).width;
          height = MediaQuery.sizeOf(context).height;
          return Container(
            height: MediaQuery.sizeOf(context).height,
            decoration: BoxDecoration(
              color: backgroundColor != null
                  ? backgroundColor.withAlpha((barrierColor * 255).toInt())
                  : Colors.black.withAlpha((barrierColor * 255).toInt()),
            ),
            child: GestureDetector(
              onTap: () async {
                isOpen = !isOpen;
                setState(() {});
                !isOpen
                    ? SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.immersiveSticky)
                    : SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.edgeToEdge);

                await Future.delayed(const Duration(milliseconds: 20));
                if (scrollController.positions.isNotEmpty && isOpen) {
                  scrollController
                      .jumpTo(currentIndex * (38.sp + (12.w / images.length)));
                }
              },
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Dismissible(
                    onUpdate: (v) async {
                      barrierColor =
                          (1 - v.progress * 4) >= 0 ? (1 - v.progress * 4) : 0;
                      if (barrierColor > 0.5) {
                        await SystemChrome.setEnabledSystemUIMode(
                            SystemUiMode.edgeToEdge);
                        setState(() {});
                      }
                      if (barrierColor == 1 && !isOpen) {
                        await SystemChrome.setEnabledSystemUIMode(
                            SystemUiMode.immersive);
                        setState(() {});
                      }
                      setState(() {});
                    },
                    movementDuration: const Duration(milliseconds: 500),
                    resizeDuration: const Duration(milliseconds: 1),
                    onDismissed: (v) async {
                      barrierColor = 1;
                      scrollController.dispose();
                      pageCtrl.dispose();
                      if (!context.mounted) return;
                      onClose?.call();
                      Navigator.pop(context);
                    },
                    direction: state == PhotoViewScaleState.initial ||
                            state == PhotoViewScaleState.originalSize ||
                            state == PhotoViewScaleState.covering
                        ? DismissDirection.vertical
                        : DismissDirection.none,
                    key: const Key("value"),
                    child: SizedBox(
                      height: fullHeight,
                      child: PhotoViewGallery.builder(
                        pageController: pageCtrl,
                        onPageChanged: (v) async {
                          if (scrollController.positions.isNotEmpty) {
                            if (currentIndex < v) {
                              v * (38.sp + (12.w / images.length)) <
                                      scrollController.position.maxScrollExtent
                                  ? scrollController.animateTo(
                                      v * (38.sp + (12.w / images.length)),
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    )
                                  : scrollController.animateTo(
                                      scrollController.position.maxScrollExtent,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                            } else if (currentIndex > v) {
                              v * (38.sp + (12.w / images.length)) >
                                      scrollController.position.minScrollExtent
                                  ? scrollController.animateTo(
                                      v * (38.sp + (12.w / images.length)),
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    )
                                  : scrollController.animateTo(
                                      scrollController.position.minScrollExtent,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                            }
                            if (v == currentIndex) {
                              scrollController.animateTo(
                                scrollController.position.minScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          }
                          currentPage = v + 1;
                          currentIndex = v;
                          setState(() {});
                          photoController.reset();
                          onPageChange?.call(v);
                        },
                        scaleStateChangedCallback: (v) {
                          state = v;
                          setState(() {});
                        },
                        scrollPhysics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        builder: (BuildContext context, int index) {
                          return PhotoViewGalleryPageOptions(
                            scaleStateController: photoController,
                            imageProvider: !isNetwork
                                ? AssetImage(images[index])
                                : NetworkImage(images[index],),
                            maxScale: PhotoViewComputedScale.contained *
                                (maxScale ?? 5),
                            initialScale: PhotoViewComputedScale.contained * 1,
                            minScale: PhotoViewComputedScale.contained *
                                (minScale ?? 1),
                          );
                        },
                        itemCount: images.length,
                        loadingBuilder: (context, event) => Center(
                          child: SizedBox(
                            width: 20.sp,
                            height: 20.sp,
                            child: CircularProgressIndicator(
                              color: loaderColor ?? Colors.grey,
                              value: event == null
                                  ? 0
                                  : event.cumulativeBytesLoaded /
                                      event.expectedTotalBytes!.toInt(),
                            ),
                          ),
                        ),
                        backgroundDecoration:
                            const BoxDecoration(color: Colors.transparent),
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: isOpen
                        ? Opacity(
                            opacity: barrierColor,
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                color: (secondaryColor ?? Colors.black)
                                    .withAlpha(((barrierColor == 1
                                                ? 0.5
                                                : barrierColor / 2) *
                                            255)
                                        .toInt()),
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).padding.top +
                                        (Platform.isAndroid ? 10.h : 0),
                                    left: leftPadding ?? 21.w,
                                    right: 21.w,
                                    bottom: 5.h),
                                child: closeButton ??
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            onClose?.call();

                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            children: [
                                              const Icon(CupertinoIcons.back,
                                                  color: CupertinoColors.white),
                                              Text(
                                                closeText ?? "Back",
                                                style: TextStyle(
                                                    color:
                                                        CupertinoColors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14.sp),
                                              )
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
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: isOpen
                        ? Opacity(
                            opacity: barrierColor,
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).padding.top +
                                        (Platform.isAndroid ? 10.h : 0),
                                    left: 21.w,
                                    right: 21.w,
                                    bottom: 5.h),
                                child: Text(
                                  "$currentPage/${images.length}",
                                  style: topTextStyle ??
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
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      duration: const Duration(milliseconds: 200),
                      child: isOpen
                          ? Opacity(
                              opacity: barrierColor,
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  width: fullWidth,
                                  color: (secondaryColor ?? Colors.black)
                                      .withAlpha(((barrierColor == 1
                                                  ? 0.5
                                                  : barrierColor / 2) *
                                              255)
                                          .toInt()),
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                              .padding
                                              .bottom +
                                          (Platform.isAndroid ? 10.h : 0),
                                      left: 0.w,
                                      right: 0.w,
                                      top: 8.h),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    controller: scrollController,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: fullWidth / 2 - 23.5.w,
                                        ),
                                        ...List.generate(images.length,
                                            (index) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2.w,
                                            ),
                                            child: GestureDetector(
                                              onTap: () async {
                                                await Future.delayed(
                                                  const Duration(
                                                    milliseconds: 20,
                                                  ),
                                                );
                                                pageCtrl.jumpToPage(
                                                  index,
                                                );
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  width: 35.sp +
                                                      (index == currentPage - 1
                                                          ? 12.w
                                                          : 0),
                                                  child: isNetwork
                                                      ? CachedNetworkImage(
                                                          imageUrl:
                                                              images[index],
                                                          height: 45.sp,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Image.asset(
                                                          images[index],
                                                          height: 45.sp,
                                                          fit: BoxFit.cover,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                        SizedBox(width: fullWidth / 2 - 23.5.w)
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
          );
        });
      });
}
