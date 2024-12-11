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
    Color? loaderColor}) {
  double barrierColor = 1;
  bool isOpen = true;
  double height = MediaQuery.sizeOf(context).height;
  double width = MediaQuery.sizeOf(context).width;
  PhotoViewScaleState state = PhotoViewScaleState.initial;
  final PageController pageController = PageController();
  int currentPage = 1;
  PhotoViewScaleStateController photoController =
      PhotoViewScaleStateController();
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
              onTap: () {
                isOpen = !isOpen;
                setState(() {});
                !isOpen
                    ? SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.immersive)
                    : SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.edgeToEdge);
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
                    onDismissed: (v) {
                      barrierColor = 1;
                      SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.edgeToEdge);
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
                        pageController: pageController,
                        onPageChanged: (v) {
                          currentPage = v + 1;
                          setState(() {});
                          photoController.reset();
                        },
                        scaleStateChangedCallback: (v) {
                          state = v;
                          setState(() {});
                        },
                        allowImplicitScrolling: true,
                        scrollPhysics: const BouncingScrollPhysics(),
                        builder: (BuildContext context, int index) {
                          return PhotoViewGalleryPageOptions(
                            scaleStateController: photoController,
                            imageProvider: NetworkImage(images[index]),
                            maxScale: PhotoViewComputedScale.contained * 5,
                            initialScale: PhotoViewComputedScale.contained * 1,
                            minScale: PhotoViewComputedScale.contained * 1,
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
                                color: Colors.black.withOpacity(
                                    barrierColor == 1 ? 0.5 : barrierColor / 2),
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).padding.top +
                                        (Platform.isAndroid ? 10.h : 0),
                                    left: 21.w,
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
                                                closeText!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              )
                                            ],
                                          ),
                                        ),
                                        const Spacer(flex: 1),
                                        Text("$currentPage/3"),
                                        const Spacer(flex: 2),
                                      ],
                                    ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                  Positioned(
                    bottom: 0,
                    child: AnimatedSwitcher(
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
                                  width: width,
                                  color: Colors.black.withOpacity(
                                      barrierColor == 1
                                          ? 0.5
                                          : barrierColor / 2),
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                              .padding
                                              .bottom +
                                          (Platform.isAndroid ? 10.h : 0),
                                      left: 21.w,
                                      right: 21.w,
                                      top: 8.h),
                                  child: SingleChildScrollView(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ...List.generate(images.length,
                                            (index) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2.w,
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                pageController.animateToPage(
                                                    index,
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeInOut);
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
                                                  child: CachedNetworkImage(
                                                    imageUrl: images[index],
                                                    height: 45.sp,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        })
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
