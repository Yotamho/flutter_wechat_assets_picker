
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_picker_library/wechat_picker_library.dart';

class GalleryViewerBuilderDelegate extends DefaultAssetPickerViewerBuilderDelegate {
  GalleryViewerBuilderDelegate({required super.currentIndex, required super.previewAssets, required super.themeData});
  
  @override
  Widget selectButton(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  Widget confirmButton(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  Widget bottomDetailBuilder(BuildContext context) {
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
        child:             Container(
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
                  if (provider != null || isWeChatMoment)
                    confirmButton(context),
                ],
              ),
            )     ),
    );
  }
}