import 'package:flutter/material.dart';
import 'package:pos_dialog/src/adaptive_pos_dialog_route.dart';

///show a dialog that is aligned to the widget(context) that opens it.
///The followerAnchor and targetAnchor tells how the dialog and the original widget should be aligned, similar to the CompositedTransformFollower widget.
///
///The offset is for additional fine control over how the dialog is positioned.
///
///avoidOverflow will shift the dialog as possible as it can to avoid painting the dialog outside of the screen, if set to true.
///
///isGlobal, if set to true, will align the dialog relative to the whole screen, rendering the targetAnchor parameter irrelevant.
///
///transitionsBuilder, tells how the dialog shows up and dismisses. The default behavior is a fade transtion, but you can add more animations like sliding easily. duration specifies how long this transtion takes.

Future<T?> showPosDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor = Colors.black54,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Alignment followerAnchor = Alignment.center,
  Alignment targetAnchor = Alignment.center,
  Offset offset = Offset.zero,
  bool avoidOverflow = false,
  bool isGlobal = false,
  RouteTransitionsBuilder? transitionsBuilder,
  Duration? duration,
  Size dialogSize = const Size(400, 600),
}) {
  final CapturedThemes themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(context, rootNavigator: useRootNavigator).context,
  );

  final RenderBox targetBox = context.findRenderObject()! as RenderBox;
  final RenderBox overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  Offset position = targetBox.localToGlobal(
    targetAnchor.alongSize(targetBox.size),
    ancestor: overlay,
  );

  if (isGlobal) {
    position = overlay.localToGlobal(followerAnchor.alongSize(overlay.size));
  }

  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    AdaptivePosDialogRoute<T>(
      followerAnchor: followerAnchor,
      position: position,
      builder: builder,
      barrierLabel: barrierLabel,
      useSafeArea: isGlobal == true,
      settings: routeSettings,
      duration: duration,
      avoidOverflow: avoidOverflow,
      offset: offset,
      dialogSize: dialogSize,
      expanded: true,
    ),
  );
}
