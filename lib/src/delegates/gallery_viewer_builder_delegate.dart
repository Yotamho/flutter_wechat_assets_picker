import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_picker_library/wechat_picker_library.dart';
import 'dart:async';
import 'dart:math' as math;
import '../constants/custom_scroll_physics.dart';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';
import 'package:wechat_picker_library/wechat_picker_library.dart';

class GalleryViewerBuilderDelegate
    extends DefaultAssetPickerViewerBuilderDelegate {
  GalleryViewerBuilderDelegate(
      {required super.currentIndex,
      required super.previewAssets,
      required super.themeData,
      this.bottomDetailWidgetBuilder});

  @override
  final bottomPreviewHeight =
      0.0; // no selection hence no selected preview thumbnails

  // widget builder to show in the bottom detail bar.
  // builder arguments are context, currentIndex and assetEntity
  final Widget Function(BuildContext, int, AssetEntity)?
      bottomDetailWidgetBuilder;

  @override
  Widget selectButton(BuildContext context) {
    return const SizedBox.shrink();
  }

  /// AppBar widget.
  /// 顶栏部件
  Widget appBar(BuildContext context) {
    final bar = AssetPickerAppBar(
      leading: Semantics(
        sortKey: ordinalSortKey(0),
        child: IconButton(
          onPressed: () {
            Navigator.maybeOf(context)?.maybePop();
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: Icon(
            Icons.arrow_back_ios_new,
            semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
          ),
        ),
      ),
    );
    return ValueListenableBuilder(
      valueListenable: isDisplayingDetail,
      builder: (_, v, child) => AnimatedPositionedDirectional(
        duration: kThemeAnimationDuration,
        curve: Curves.easeInOut,
        top: v ? 0.0 : -(context.topPadding + bar.preferredSize.height),
        start: 0.0,
        end: 0.0,
        child: child!,
      ),
      child: bar,
    );
  }

  @override
  Widget bottomDetailBuilder(BuildContext context) {
    assert(bottomDetailWidgetBuilder != null,
        "method shouldn't be called if there is no widget to show");
    final backgroundColor = themeData.bottomAppBarTheme.color?.withOpacity(
      themeData.bottomAppBarTheme.color!.opacity *
          (isAppleOS(context) ? .9 : 1),
    );
    return ValueListenableBuilder(
      valueListenable: isDisplayingDetail,
      builder: (_, v, child) => AnimatedPositionedDirectional(
        duration: kThemeAnimationDuration,
        curve: Curves.easeInOut,
        bottom: v ? 0.0 : -(context.bottomPadding + bottomDetailHeight),
        start: 0.0,
        end: 0.0,
        height: context.bottomPadding + bottomDetailHeight,
        child: child!,
      ),
      child: CNP<AssetPickerViewerProvider<AssetEntity>?>.value(
          value: provider,
          child: Container(
            height: bottomBarHeight + context.bottomPadding,
            padding: const EdgeInsets.symmetric(horizontal: 20.0)
                .copyWith(bottom: context.bottomPadding),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: themeData.canvasColor)),
              color: backgroundColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                bottomDetailWidgetBuilder!(context, currentIndex, currentAsset)
              ],
            ),
          )),
    );
  }

  Widget _pageViewBuilder(BuildContext context) {
    return Semantics(
      sortKey: ordinalSortKey(1),
      child: ExtendedImageGesturePageView.builder(
        physics: previewAssets.length == 1
            ? const CustomClampingScrollPhysics()
            : const CustomBouncingScrollPhysics(),
        controller: pageController,
        itemCount: previewAssets.length,
        itemBuilder: assetPageBuilder,
        onPageChanged: (int index) {
          currentIndex = index;
          pageStreamController.add(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: themeData.appBarTheme.systemOverlayStyle ??
            (themeData.effectiveBrightness.isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: <Widget>[
              Positioned.fill(child: _pageViewBuilder(context)),
              if (isWeChatMoment && hasVideo) ...<Widget>[
                momentVideoBackButton(context),
                PositionedDirectional(
                  end: 16,
                  bottom: context.bottomPadding + 16,
                  child: confirmButton(context),
                ),
              ] else ...<Widget>[
                appBar(context),
                if (bottomDetailWidgetBuilder != null)
                  bottomDetailBuilder(context),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
