// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

const String _testButtonText = 'Picker test press';

final Finder defaultButtonFinder = find.widgetWithText(
  TextButton,
  _testButtonText,
);

Widget defaultPickerTestApp({
  void Function(BuildContext)? onButtonPressed,
  Locale locale = const Locale('zh'),
}) {
  return MaterialApp(
    home: _DefaultHomePage(onButtonPressed),
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      GlobalWidgetsLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const <Locale>[
      Locale('zh'),
      Locale('en'),
      Locale('he'),
      Locale('de'),
      Locale('ru'),
      Locale('ja'),
      Locale('ar'),
      Locale('fr'),
      Locale('vi'),
      Locale('ko'),
    ],
    locale: locale,
  );
}

class _DefaultHomePage extends StatelessWidget {
  const _DefaultHomePage(this.onButtonPressed);

  final void Function(BuildContext)? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            onButtonPressed?.call(context);
          },
          child: const Text(_testButtonText),
        ),
      ),
    );
  }
}

class TestPhotoManagerPlugin extends PhotoManagerPlugin {
  @override
  Future<PermissionState> requestPermissionExtend(
    PermissionRequestOption requestOption,
  ) {
    return SynchronousFuture<PermissionState>(PermissionState.authorized);
  }

  @override
  Future<Uint8List?> getThumbnail({
    required String id,
    required ThumbnailOption option,
    PMProgressHandler? progressHandler,
  }) {
    return SynchronousFuture<Uint8List?>(transparentImageBytes);
  }

  @override
  Future<bool> isLocallyAvailable(
    String id, {
    bool isOrigin = false,
    int subtype = 0,
    PMDarwinAVFileType? darwinFileType,
  }) {
    return SynchronousFuture<bool>(true);
  }

  @override
  Future<bool> notifyChange({required bool start}) {
    return SynchronousFuture<bool>(true);
  }
}

class TestAssetPickerDelegate extends AssetPickerDelegate {
  TestAssetPickerDelegate({this.assets});

  /// Assets the picker provider gets populated with.
  final List<AssetEntity>? assets;

  @override
  Future<PermissionState> permissionCheck({
    PermissionRequestOption requestOption = const PermissionRequestOption(),
  }) async {
    return SynchronousFuture<PermissionState>(PermissionState.authorized);
  }

  @override
  Future<List<AssetEntity>?> pickAssets(
    BuildContext context, {
    Key? key,
    AssetPickerConfig pickerConfig = const AssetPickerConfig(),
    PermissionRequestOption? permissionRequestOption,
    bool useRootNavigator = true,
    RouteSettings? pageRouteSettings,
    AssetPickerPageRouteBuilder<List<AssetEntity>>? pageRouteBuilder,
  }) async {
    permissionRequestOption ??= PermissionRequestOption(
      androidPermission: AndroidPermission(
        type: pickerConfig.requestType,
        mediaLocation: false,
      ),
    );
    final PermissionState ps = await permissionCheck(
      requestOption: permissionRequestOption,
    );
    final AssetPathEntity pathEntity = AssetPathEntity(
      id: 'test',
      name: 'pathEntity',
    );
    final DefaultAssetPickerProvider provider =
        DefaultAssetPickerProvider.forTest(
      maxAssets: pickerConfig.maxAssets,
      pageSize: pickerConfig.pageSize,
      pathThumbnailSize: pickerConfig.pathThumbnailSize,
      selectedAssets: pickerConfig.selectedAssets,
      requestType: pickerConfig.requestType,
      sortPathDelegate: pickerConfig.sortPathDelegate,
      filterOptions: pickerConfig.filterOptions,
    );
    final List<AssetEntity> currentAssets =
        assets ?? <AssetEntity>[testAssetEntity];
    provider
      ..currentAssets = currentAssets
      ..currentPath = PathWrapper<AssetPathEntity>(
        path: pathEntity,
        assetCount: currentAssets.length,
      )
      ..hasAssetsToDisplay = true
      ..totalAssetsCount = currentAssets.length;
    final picker = AssetPicker<AssetEntity, AssetPathEntity,
        DefaultAssetPickerBuilderDelegate>(
      key: key,
      permissionRequestOption: permissionRequestOption,
      builder: DefaultAssetPickerBuilderDelegate(
        provider: provider,
        initialPermission: ps,
        gridCount: pickerConfig.gridCount,
        pickerTheme: pickerConfig.pickerTheme,
        gridThumbnailSize: pickerConfig.gridThumbnailSize,
        previewThumbnailSize: pickerConfig.previewThumbnailSize,
        specialPickerType: pickerConfig.specialPickerType,
        specialItems: pickerConfig.specialItems,
        loadingIndicatorBuilder: pickerConfig.loadingIndicatorBuilder,
        selectPredicate: pickerConfig.selectPredicate,
        shouldRevertGrid: pickerConfig.shouldRevertGrid,
        limitedPermissionOverlayPredicate:
            pickerConfig.limitedPermissionOverlayPredicate,
        pathNameBuilder: pickerConfig.pathNameBuilder,
        textDelegate: pickerConfig.textDelegate,
        themeColor: pickerConfig.themeColor,
        locale: Localizations.maybeLocaleOf(context),
        shouldAutoplayPreview: pickerConfig.shouldAutoplayPreview,
        contextActions: pickerConfig.contextActions,
        dragToSelect: pickerConfig.dragToSelect,
      ),
    );
    final List<AssetEntity>? result = await Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).push<List<AssetEntity>>(
      pageRouteBuilder?.call(picker) ??
          AssetPickerPageRoute<List<AssetEntity>>(
            builder: (_) => picker,
            settings: pageRouteSettings,
          ),
    );
    return result;
  }
}

final AssetEntity testAssetEntity = AssetEntity(
  id: 'test',
  typeInt: 0,
  width: 0,
  height: 0,
);

const AssetEntity testImageAssetEntity = AssetEntity(
  id: 'test-image',
  typeInt: 1, // AssetType.image
  width: 1,
  height: 1,
);

/// A 1x1 transparent PNG, served as every thumbnail in tests.
final Uint8List transparentImageBytes = Uint8List.fromList(const <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, //
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, //
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, //
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, //
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, //
  0x42, 0x60, 0x82, //
]);
