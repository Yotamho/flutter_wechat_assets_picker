// Copyright 2019 The FlutterCandies author. All rights reserved.
// Use of this source code is governed by an Apache license that can be found
// in the LICENSE file.

import 'package:flutter/cupertino.dart'
    show CupertinoContextMenu, CupertinoContextMenuAction;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'test_utils.dart';

void main() {
  PhotoManager.withPlugin(TestPhotoManagerPlugin());
  AssetPicker.setPickerDelegate(TestAssetPickerDelegate());

  group('Confirm button', () {
    group('when enabled preview', () {
      testWidgets('with multiple assets picking', (WidgetTester tester) async {
        await tester.pumpWidget(
          defaultPickerTestApp(
            onButtonPressed: (BuildContext context) {
              AssetPicker.pickAssets(
                context,
                pickerConfig: const AssetPickerConfig(
                  maxAssets: 10,
                  specialPickerType: null, // Explicitly null.
                ),
              );
            },
          ),
        );
        await tester.tap(defaultButtonFinder);
        await tester.pumpAndSettle();
        expect(
          find.text(const AssetPickerTextDelegate().confirm),
          findsOneWidget,
        );
      });
      testWidgets('with single asset picking', (WidgetTester tester) async {
        await tester.pumpWidget(
          defaultPickerTestApp(
            onButtonPressed: (BuildContext context) {
              AssetPicker.pickAssets(
                context,
                pickerConfig: const AssetPickerConfig(
                  maxAssets: 1,
                  specialPickerType: null, // Explicitly null.
                ),
              );
            },
          ),
        );
        await tester.tap(defaultButtonFinder);
        await tester.pumpAndSettle();
        expect(
          find.text(const AssetPickerTextDelegate().confirm),
          findsOneWidget,
        );
      });
    });
    group('when disabled preview', () {
      testWidgets('with multiple assets picker', (WidgetTester tester) async {
        await tester.pumpWidget(
          defaultPickerTestApp(
            onButtonPressed: (BuildContext context) {
              AssetPicker.pickAssets(
                context,
                pickerConfig: const AssetPickerConfig(
                  maxAssets: 2,
                  specialPickerType: SpecialPickerType.noPreview,
                ),
              );
            },
          ),
        );
        await tester.tap(defaultButtonFinder);
        await tester.pumpAndSettle();
        expect(
          find.text(const AssetPickerTextDelegate().confirm),
          findsOneWidget,
        );
      });
      testWidgets('with single asset picker', (WidgetTester tester) async {
        await tester.pumpWidget(
          defaultPickerTestApp(
            onButtonPressed: (BuildContext context) {
              AssetPicker.pickAssets(
                context,
                pickerConfig: const AssetPickerConfig(
                  maxAssets: 1,
                  specialPickerType: SpecialPickerType.noPreview,
                ),
              );
            },
          ),
        );
        await tester.tap(defaultButtonFinder);
        await tester.pumpAndSettle();
        expect(
          find.text(const AssetPickerTextDelegate().confirm),
          findsNothing,
        );
      });
    });
  });

  group('Context actions', () {
    testWidgets(
      'long press opens the context menu while drag-to-select is enabled',
      (WidgetTester tester) async {
        AssetPicker.setPickerDelegate(
          TestAssetPickerDelegate(assets: <AssetEntity>[testImageAssetEntity]),
        );
        addTearDown(() {
          AssetPicker.setPickerDelegate(TestAssetPickerDelegate());
        });
        await tester.pumpWidget(
          defaultPickerTestApp(
            onButtonPressed: (BuildContext context) {
              AssetPicker.pickAssets(
                context,
                pickerConfig: AssetPickerConfig(
                  contextActions: <Widget Function(BuildContext, AssetEntity)>[
                    (BuildContext context, AssetEntity asset) =>
                        CupertinoContextMenuAction(
                          onPressed: () {},
                          child: const Text('Test action'),
                        ),
                  ],
                ),
              );
            },
          ),
        );
        await tester.tap(defaultButtonFinder);
        await tester.pumpAndSettle();
        expect(find.byType(CupertinoContextMenu), findsOneWidget);

        // Press away from the top-end corner, which is covered by the
        // opaque select indicator.
        final Rect itemRect = tester.getRect(find.byType(CupertinoContextMenu));
        final TestGesture gesture = await tester.startGesture(
          itemRect.topLeft +
              Offset(itemRect.width * 0.25, itemRect.height * 0.75),
        );
        // The menu opens once the decoy animation completes (~800ms), unless
        // another recognizer (e.g. drag-to-select's long press) claims the
        // gesture arena first.
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(seconds: 1));
        await gesture.up();
        await tester.pumpAndSettle();
        expect(find.text('Test action'), findsOneWidget);
      },
    );
  });
}
