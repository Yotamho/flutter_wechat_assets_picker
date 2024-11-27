import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class Gallery extends StatelessWidget {
  const Gallery({super.key});

  @override
  Widget build(BuildContext context) {
    final DefaultAssetPickerProvider provider =
        DefaultAssetPickerProvider(requestType: RequestType.all);
    final Future<PermissionState> ps = AssetPicker.permissionCheck(
      requestOption: PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: provider.requestType,
          mediaLocation: false,
        ),
      ),
    );

    return FutureBuilder(
      future: ps,
      builder: (context, snapshot) => snapshot.hasData
          ? GalleryBuilderDelegate(
                  provider: provider,
                  initialPermission: snapshot.data!,
                  locale: Localizations.maybeLocaleOf(context),
                  viewerBottomDetailWidgetBuilder: (p0, p1, p2) => const Text('Custom Widget'),)
              .build(context)
          : const CircularProgressIndicator(),
    );
  }
}
