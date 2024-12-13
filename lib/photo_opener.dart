import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

onOpenPhoto(
    {required BuildContext context,
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
      bool isNetwork = true}) {
  double barrierColor = 1;
  bool isOpen = true;
  double height = MediaQuery.sizeOf(context).height;
  double width = MediaQuery.sizeOf(context).width;
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
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            height: MediaQuery.sizeOf(context).height,
            decoration: BoxDecoration(
              color: backgroundColor != null
                  ? backgroundColor.withOpacity(barrierColor)
                  : Colors.black.withOpacity(barrierColor),
            ),
            child: GestureDetector(
              onTap: () async {
                isOpen = !isOpen;
                setState(() {});

                !isOpen
                    ? SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.immersive)
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
                    onUpdate: (v) {
                      barrierColor =
                      (1 - v.progress * 4) >= 0 ? (1 - v.progress * 4) : 0;
                      setState(() {});
                    },
                    movementDuration: const Duration(milliseconds: 500),
                    resizeDuration: const Duration(milliseconds: 1),
                    onDismissed: (v) async {
                      barrierColor = 1;
                      await SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.edgeToEdge);
                      scrollController.dispose();
                      pageCtrl.dispose();
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    direction: state == PhotoViewScaleState.initial ||
                        state == PhotoViewScaleState.originalSize ||
                        state == PhotoViewScaleState.covering
                        ? DismissDirection.vertical
                        : DismissDirection.none,
                    key: const Key("value"),
                    child: SizedBox(
                      height: height,
                      child: PhotoViewGallery.builder(
                        pageController: pageCtrl,
                        onPageChanged: (v) async {
                          if (scrollController.positions.isNotEmpty) {
                            if (currentIndex < v) {
                              (scrollController.offset +
                                  38.sp +
                                  (12.w / (images.length - 1))) <
                                  scrollController.position.maxScrollExtent
                                  ? scrollController.animateTo(
                                scrollController.offset +
                                    (38.sp +
                                        (12.w / (images.length - 1))),
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
                              scrollController.offset -
                                  38.sp -
                                  (12.w / images.length) >
                                  scrollController.position.minScrollExtent
                                  ? scrollController.animateTo(
                                scrollController.offset -
                                    38.sp -
                                    (12.w / images.length),
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
                        allowImplicitScrolling: true,
                        scrollPhysics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        builder: (BuildContext context, int index) {
                          return PhotoViewGalleryPageOptions(
                            scaleStateController: photoController,
                            imageProvider: isNetwork
                                ? NetworkImage(images[index])
                                : AssetImage(images[index]),
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
                    duration: const Duration(milliseconds: 100),
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
                              .withOpacity(barrierColor == 1
                              ? 0.5
                              : barrierColor / 2),
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
                                      Navigator.pop(context);
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(CupertinoIcons.back),
                                        Text(
                                          closeText ?? "Back",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
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
                    duration: const Duration(milliseconds: 100),
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
                      duration: const Duration(milliseconds: 100),
                      child: isOpen
                          ? Opacity(
                        opacity: barrierColor,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: width,
                            color: (secondaryColor ?? Colors.black)
                                .withOpacity(barrierColor == 1
                                ? 0.5
                                : barrierColor / 2),
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
                                    width:
                                    MediaQuery.sizeOf(context).width /
                                        2 -
                                        23.5.w,
                                  ),
                                  ...List.generate(images.length,
                                          (index) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 2.w,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {},
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
                                  SizedBox(
                                      width: MediaQuery.sizeOf(context)
                                          .width /
                                          2 -
                                          23.5.w),
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
