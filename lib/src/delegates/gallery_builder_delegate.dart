import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/src/delegates/gallery_viewer_builder_delegate.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class GalleryBuilderDelegate extends DefaultAssetPickerBuilderDelegate {
  GalleryBuilderDelegate({required super.provider, required super.initialPermission, super.locale});


  @override
  Future<void> viewAsset(BuildContext context, int? index, AssetEntity currentAsset) async {
    if (index == null) {
      throw StateError('asset index should not be null in gallery view');
    }
    await AssetPickerViewer.pushToViewerWithDelegate(
      context,
      delegate: GalleryViewerBuilderDelegate(currentIndex: index, previewAssets: [currentAsset], themeData: theme),
    );
  }
}