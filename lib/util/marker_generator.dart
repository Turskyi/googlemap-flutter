import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// This just adds overlay and builds [_MarkerHelper] on that overlay.
/// [_MarkerHelper] does all the heavy work of creating and getting bitmaps
class MarkerGenerator {
  MarkerGenerator({required this.widgets, required this.bitmapsCallback});

  final Function(List<Uint8List>) bitmapsCallback;
  final List<Widget> widgets;

  void generate(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      afterFirstLayout(context);
    });
  }

  void afterFirstLayout(BuildContext context) {
    addOverlay(context);
  }

  void addOverlay(BuildContext context) {
    final OverlayState overlayState = Overlay.of(context);

    final OverlayEntry entry = OverlayEntry(
      builder: (BuildContext context) {
        return _MarkerHelper(
          markerWidgets: widgets,
          callback: bitmapsCallback,
        );
      },
      maintainState: true,
    );

    overlayState.insert(entry);
  }
}

/// Maps are embedding GoogleMap library for Android/iOS  into flutter.
///
/// These native libraries accept BitmapDescriptor for marker,
/// which means that for custom markers
/// we need to draw view to bitmap and then send that to BitmapDescriptor.
///
/// Because Flutter also cannot accept Widget for marker,
/// we need draw it to bitmap and
/// that's what [_MarkerHelper] widget does:
///
/// 1) It draws marker widget to tree
/// 2) After painted access the repaint boundary with global key
/// and converts it to [Uint8List]
/// 3) Returns set of [Uint8List] (bitmaps) through callback.
class _MarkerHelper extends StatefulWidget {
  const _MarkerHelper({
    required this.markerWidgets,
    required this.callback,
  });

  final List<Widget> markerWidgets;
  final Function(List<Uint8List>) callback;

  @override
  _MarkerHelperState createState() => _MarkerHelperState();
}

class _MarkerHelperState extends State<_MarkerHelper> with AfterLayoutMixin {
  List<GlobalKey> globalKeys = [];

  @override
  void afterFirstLayout(BuildContext context) {
    _getBitmaps(context).then((list) {
      widget.callback(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(MediaQuery.of(context).size.width, 0),
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: widget.markerWidgets.map((i) {
            final markerKey = GlobalKey();
            globalKeys.add(markerKey);
            return RepaintBoundary(
              key: markerKey,
              child: i,
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<List<Uint8List>> _getBitmaps(BuildContext context) async {
    final Iterable<Future<Uint8List>> futures =
        globalKeys.map((key) => _getUint8List(key));
    return Future.wait(futures);
  }

  Future<Uint8List> _getUint8List(GlobalKey markerKey) async {
    Uint8List uint8list = Uint8List(0);
    final BuildContext? markerKeyBuildContext = markerKey.currentContext;
    final RenderObject? renderObject =
        markerKeyBuildContext?.findRenderObject();
    if (markerKeyBuildContext != null &&
        renderObject is RenderRepaintBoundary) {
      final RenderRepaintBoundary boundary = renderObject;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        uint8list = byteData.buffer.asUint8List();
      }
    }
    return uint8list;
  }
}

mixin AfterLayoutMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
      afterFirstLayout(context);
    });
  }

  void afterFirstLayout(BuildContext context);
}
