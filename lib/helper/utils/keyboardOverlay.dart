import 'package:flutter/material.dart';
import 'package:project/helper/utils/inputdoneview.dart';

class KeyboardOverlay {
  static OverlayEntry? _overlayEntry;

  static showOverlay(BuildContext context) {
    if (_overlayEntry != null) {
      return;
    }

    // [v5 iPad/iOS 27 crash fix] Overlay.of(context) can throw or return
    // null during route transitions / keyboard show-hide cycles on iPad
    // (especially iPadOS 27). Wrap in try/catch and a mounted check so the
    // focus listener never crashes the app.
    OverlayState? overlayState;
    try {
      overlayState = Overlay.of(context, rootOverlay: true);
    } catch (_) {
      // No overlay ancestor available — silently skip.
      return;
    }
    if (overlayState == null) {
      return;
    }
    if (!overlayState.mounted) {
      return;
    }

    try {
      _overlayEntry = OverlayEntry(builder: (context) {
        return Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            right: 0.0,
            left: 0.0,
            child: const InputDoneView());
      });
      overlayState.insert(_overlayEntry!);
    } catch (_) {
      // If insertion fails (e.g., overlay disposed during insert), reset
      // the entry so a future focus event can try again.
      _overlayEntry = null;
    }
  }

  static removeOverlay() {
    if (_overlayEntry != null) {
      try {
        _overlayEntry!.remove();
      } catch (_) {
        // Entry may already be removed if the overlay was disposed.
      }
      _overlayEntry = null;
    }
  }
}
