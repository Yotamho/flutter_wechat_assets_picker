import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/src/delegates/gallery_viewer_builder_delegate.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_picker_library/wechat_picker_library.dart';

class GalleryBuilderDelegate extends DefaultAssetPickerBuilderDelegate {
  GalleryBuilderDelegate({
    required super.provider,
    required super.initialPermission,
    super.locale,
    super.pickerTheme,
    super.contextActions,
    super.keepScrollOffset,
    this.customGridItemWidgetBuilder,
    this.viewerBottomDetailWidgetBuilder,
    this.disablePathSwitching = false,
    this.viewAssetWithRootNavigator = false,
  });

  final Widget Function(BuildContext, int, AssetEntity)?
      customGridItemWidgetBuilder;
  final Widget Function(BuildContext, int, AssetEntity)?
      viewerBottomDetailWidgetBuilder;

  final bool disablePathSwitching;
  final bool viewAssetWithRootNavigator;

  @override
  Future<void> viewAsset(
      BuildContext context, int? index, AssetEntity currentAsset) async {
    if (index == null) {
      throw StateError('asset index should not be null in gallery view');
    }
    await AssetPickerViewer.pushToViewerWithDelegate(
      context,
      delegate: GalleryViewerBuilderDelegate(
        currentIndex: index,
        previewAssets: provider.currentAssets,
        themeData: theme,
        bottomDetailWidgetBuilder: viewerBottomDetailWidgetBuilder,
      ),
      useRootNavigator: viewAssetWithRootNavigator,
    );
  }

  @override
  Widget bottomActionBar(BuildContext context) => const SizedBox.shrink();

  @override
  Widget selectIndicator(BuildContext context, int index, AssetEntity asset) {
    if (customGridItemWidgetBuilder != null) {
      return customGridItemWidgetBuilder!(context, index, asset);
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget pathEntitySelector(BuildContext context) {
    Widget pathText(
      BuildContext context,
      String text,
      String semanticsText,
    ) {
      return Flexible(
        child: ScaleText(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.fade,
          maxScaleFactor: 1.2,
          semanticsLabel: semanticsText,
        ),
      );
    }

    if (disablePathSwitching) {
      return Selector<DefaultAssetPickerProvider,
          PathWrapper<AssetPathEntity>?>(
        selector: (_, DefaultAssetPickerProvider p) => p.currentPath,
        builder: (_, p, ___) {
          if (p == null) {
            throw StateError(
                'if path switching is disabled, asset picker must be called when path is not null');
          }
          return pathText(context, p.path.name, p.path.name);
        },
      );
    }
    return UnconstrainedBox(
      child: GestureDetector(
        onTap: () {
          if (isPermissionLimited && provider.isAssetsEmpty) {
            PhotoManager.presentLimited();
            return;
          }
          if (provider.currentPath == null) {
            return;
          }
          isSwitchingPath.value = !isSwitchingPath.value;
        },
        child: Container(
          height: appBarItemHeight,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.5,
          ),
          padding: const EdgeInsetsDirectional.only(start: 12, end: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: theme.focusColor,
          ),
          child: Selector<DefaultAssetPickerProvider,
              PathWrapper<AssetPathEntity>?>(
            selector: (_, DefaultAssetPickerProvider p) => p.currentPath,
            builder: (_, PathWrapper<AssetPathEntity>? p, Widget? w) {
              final AssetPathEntity? path = p?.path;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (path == null && isPermissionLimited)
                    pathText(
                      context,
                      textDelegate.changeAccessibleLimitedAssets,
                      semanticsTextDelegate.changeAccessibleLimitedAssets,
                    ),
                  if (path != null)
                    pathText(
                      context,
                      isPermissionLimited && path.isAll
                          ? textDelegate.accessiblePathName
                          : pathNameBuilder?.call(path) ?? path.name,
                      isPermissionLimited && path.isAll
                          ? semanticsTextDelegate.accessiblePathName
                          : pathNameBuilder?.call(path) ?? path.name,
                    ),
                  w!,
                ],
              );
            },
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.iconTheme.color!.withOpacity(0.5),
                ),
                child: ValueListenableBuilder<bool>(
                  valueListenable: isSwitchingPath,
                  builder: (_, bool isSwitchingPath, Widget? w) {
                    return Transform.rotate(
                      angle: isSwitchingPath ? math.pi : 0,
                      child: w,
                    );
                  },
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget backButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: IconButton(
        onPressed: () {
          Navigator.maybeOf(context)?.maybePop();
        },
        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        icon: Icon(
          Icons.arrow_back,
          semanticLabel: MaterialLocalizations.of(context).closeButtonTooltip,
        ),
      ),
    );
  }
}
