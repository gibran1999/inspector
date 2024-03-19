import 'package:flutter/material.dart';
import 'package:overlay_loading_progress/overlay_loading_progress.dart';

class CustomLoadingProgress {
  static void start(BuildContext context) {
    OverlayLoadingProgress.start(context,
      gifOrImagePath: 'assets/loading.gif',
      barrierDismissible: false,
      widget: Container(
        color: Colors.black38,
        width: 100,
        height: 100,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      )
    );
  }

  static void stop() {
    OverlayLoadingProgress.stop();
  }
}