import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PosDialogRoute<T> extends RawDialogRoute<T> {
  /// A dialog route with Material entrance and exit animations,
  /// modal barrier color, and modal barrier behavior (dialog is dismissible
  /// with a tap on the barrier).
  PosDialogRoute({
    required BuildContext context,
    required WidgetBuilder builder,
    required Alignment followerAlignment,
    required Offset position,
    CapturedThemes? themes,
    super.barrierColor = Colors.transparent,
    super.barrierDismissible,
    String? barrierLabel,
    bool useSafeArea = false,
    super.settings,
    RouteTransitionsBuilder? transitionsBuilder,
    Duration? duration,
    bool avoidOverflow = false,
    Offset offset = Offset.zero,
  }) : super(
         pageBuilder: (
           BuildContext buildContext,
           Animation<double> animation,
           Animation<double> secondaryAnimation,
         ) {
           final Widget pageChild = Builder(builder: builder);
           Widget dialog = Builder(
             builder: (BuildContext context) {
               final MediaQueryData mediaQuery = MediaQuery.of(context);
               return CustomSingleChildLayout(
                 delegate: FollowerDialogRouteLayout(
                   followerAlignment,
                   position,
                   Directionality.of(context),
                   mediaQuery.padding.top,
                   mediaQuery.padding.bottom,
                   offset,
                   avoidOverflow,
                 ),
                 child: pageChild,
               );
             },
           );
           dialog = themes?.wrap(dialog) ?? dialog;
           if (useSafeArea) {
             dialog = SafeArea(child: dialog);
           }
           return dialog;
         },
         barrierLabel:
             barrierLabel ??
             MaterialLocalizations.of(context).modalBarrierDismissLabel,
         transitionDuration: duration ?? const Duration(milliseconds: 200),
         transitionBuilder:
             transitionsBuilder ?? _buildMaterialDialogTransitions,
       );
}

// Positioning of the menu on the screen.
class FollowerDialogRouteLayout extends SingleChildLayoutDelegate {
  FollowerDialogRouteLayout(
    this.followerAnchor,
    this.position,
    this.textDirection,
    this.topPadding,
    this.bottomPadding,
    this.offset,
    this.avoidOverflow,
  );

  final Alignment followerAnchor;

  // Rectangle of underlying button, relative to the overlay's dimensions.
  final Offset position;

  // Whether to prefer going to the left or to the right.
  final TextDirection textDirection;

  // Top padding of unsafe area.
  final double topPadding;

  // Bottom padding of unsafe area.
  final double bottomPadding;

  final Offset offset;
  final bool avoidOverflow;

  // We put the child wherever position specifies, so long as it will fit within
  // the specified parent size padded (inset) by 8. If necessary, we adjust the
  // child's position so that it fits.

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    return BoxConstraints.loose(
      constraints.biggest,
    ).deflate(EdgeInsets.only(top: topPadding, bottom: bottomPadding));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    Offset rst = followerAnchor.alongSize(childSize);
    rst = position - rst;
    rst += offset;
    if (avoidOverflow) {
      if (rst.dx < 0) rst = Offset(0, rst.dy);
      if (rst.dy < 0) rst = Offset(rst.dx, 0);
      if (rst.dx + childSize.width > size.width)
        rst = Offset(size.width - childSize.width, rst.dy);
      if (rst.dy + childSize.height > size.height)
        rst = Offset(rst.dx, size.height - childSize.height);
    }
    return rst;
  }

  @override
  bool shouldRelayout(FollowerDialogRouteLayout oldDelegate) {
    // If called when the old and new itemSizes have been initialized then
    // we expect them to have the same length because there's no practical
    // way to change length of the items list once the menu has been shown.

    return followerAnchor != oldDelegate.followerAnchor ||
        position != oldDelegate.position ||
        offset != oldDelegate.offset ||
        avoidOverflow != oldDelegate.avoidOverflow ||
        textDirection != oldDelegate.textDirection ||
        topPadding != oldDelegate.topPadding ||
        bottomPadding != oldDelegate.bottomPadding;
  }
}

Widget _buildMaterialDialogTransitions(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
    child: child,
  );
}
