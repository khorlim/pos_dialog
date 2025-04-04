import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class BaseAdaptivePosDialogRoute<T> extends PageRoute<T> {
  BaseAdaptivePosDialogRoute({
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
    this.duration = const Duration(milliseconds: 400),
    super.settings,
  });

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
  bool get maintainState => true;

  @override
  bool get opaque => false;

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

  Widget buildDialog(BuildContext context);

  Widget buildBottomSheet(BuildContext context);

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
