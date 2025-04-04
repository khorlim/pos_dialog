import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pos_dialog/pos_dialog.dart';
import 'package:pos_dialog/src/pos_bottom_sheet/pos_bottom_sheet.dart';
import 'package:pos_dialog/src/pos_dialog/pos_dialog.dart';

const Duration _bottomSheetDuration = Duration(milliseconds: 400);
typedef WidgetWithChildBuilder =
    Widget Function(
      BuildContext context,
      Animation<double> animation,
      Widget child,
    );

class AdaptivePosDialogRoute<T> extends BaseAdaptivePosDialogRoute<T> {
  AdaptivePosDialogRoute({
    this.closeProgressThreshold,
    required this.followerAnchor,
    required this.builder,
    required this.position,
    this.useSafeArea = false,
    this.offset = Offset.zero,
    this.avoidOverflow = false,
    this.scrollController,
    this.barrierLabel,
    this.secondAnimationController,
    this.modalBarrierColor,
    this.isDismissible = true,
    this.enableDrag = true,
    required this.dialogSize,
    required this.expanded,
    this.bounce = false,
    this.animationCurve,
    Duration? duration,
    super.settings,
  }) : duration = duration ?? _bottomSheetDuration;

  final double? closeProgressThreshold;
  final WidgetBuilder builder;
  final bool expanded;
  final bool bounce;
  final Color? modalBarrierColor;
  final bool isDismissible;
  final bool enableDrag;
  final ScrollController? scrollController;
  final Size dialogSize;

  final Alignment followerAnchor;
  final Offset position;
  final bool useSafeArea;
  final Offset offset;
  final bool avoidOverflow;

  final Duration duration;

  final AnimationController? secondAnimationController;
  final Curve? animationCurve;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  bool get maintainState => true; // keep in memory when not active (#252)

  @override
  bool get opaque => false; //transparency

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => modalBarrierColor ?? Colors.black.withOpacity(0.35);

  AnimationController? animationController;

  @override
  AnimationController createAnimationController() {
    assert(animationController == null);
    animationController = AnimationController(
      duration: duration,
      debugLabel: 'BottomSheet',
      vsync: navigator!,
    );
    return animationController!;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDialog = screenWidth > 600;
    return isDialog ? buildDialog(context) : buildBottomSheet(context);
  }

  Widget buildDialog(BuildContext context) {
    final Widget pageChild = PosDialog(
      size: dialogSize,
      followerAnchor: followerAnchor,
      position: position,
      offset: offset,
      avoidOverflow: avoidOverflow,
      child: Builder(builder: (context) => builder(context)),
    );

    Widget dialog = Builder(
      builder: (BuildContext context) {
        final MediaQueryData mediaQuery = MediaQuery.of(context);
        return CustomSingleChildLayout(
          delegate: FollowerDialogRouteLayout(
            followerAnchor,
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
    if (useSafeArea) {
      dialog = SafeArea(child: dialog);
    }
    return dialog;
  }

  Widget buildBottomSheet(BuildContext context) {
    // By definition, the bottom sheet is aligned to the bottom of the page
    // and isn't exposed to the top padding of the MediaQuery.
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      // removeTop: true,
      child: PosBottomSheet<T>(
        closeProgressThreshold: closeProgressThreshold,
        route: this,
        secondAnimationController: secondAnimationController,
        expanded: expanded,
        bounce: bounce,
        enableDrag: enableDrag,
        animationCurve: animationCurve,
        builder: builder,
      ),
    );
    return bottomSheet;
  }

  // @override
  // bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
  //     nextRoute is ModalSheetRoute;

  // @override
  // bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
  //     previousRoute is ModalSheetRoute || previousRoute is PageRoute;

  Widget getPreviousRouteTransition(
    BuildContext context,
    Animation<double> secondAnimation,
    Widget child,
  ) {
    return child;
  }
}
