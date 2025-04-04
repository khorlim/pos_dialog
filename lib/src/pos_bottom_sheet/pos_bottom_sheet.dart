import 'package:flutter/material.dart';
import 'package:pos_dialog/pos_dialog.dart';
import 'package:pos_dialog/src/adaptive_pos_dialog_route.dart';
import 'package:pos_dialog/src/pos_bottom_sheet/base_pos_bottom_sheet.dart';
import 'package:pos_dialog/src/pos_bottom_sheet/utils/modal_scroll_controller.dart';

const Duration _bottomSheetDuration = Duration(milliseconds: 400);

class PosBottomSheet<T> extends StatefulWidget {
  const PosBottomSheet({
    super.key,
    this.closeProgressThreshold,
    required this.builder,
    required this.route,
    this.secondAnimationController,
    this.bounce = false,
    this.expanded = false,
    this.enableDrag = true,
    this.animationCurve,
  });
  final WidgetBuilder builder;
  final double? closeProgressThreshold;
  final BaseAdaptivePosDialogRoute<T> route;
  final bool expanded;
  final bool bounce;
  final bool enableDrag;
  final AnimationController? secondAnimationController;
  final Curve? animationCurve;

  @override
  _PosBottomSheetState<T> createState() => _PosBottomSheetState<T>();
}

class _PosBottomSheetState<T> extends State<PosBottomSheet<T>> {
  String _getRouteLabel() {
    final platform = Theme.of(context).platform; //?? defaultTargetPlatform;
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return '';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        if (Localizations.of(context, MaterialLocalizations) != null) {
          return MaterialLocalizations.of(context).dialogLabel;
        } else {
          return DefaultMaterialLocalizations().dialogLabel;
        }
    }
  }

  ScrollController? _scrollController;

  @override
  void initState() {
    widget.route.animation?.addListener(updateController);
    super.initState();
  }

  @override
  void dispose() {
    widget.route.animation?.removeListener(updateController);
    _scrollController?.dispose();
    super.dispose();
  }

  void updateController() {
    final animation = widget.route.animation;
    if (animation != null) {
      widget.secondAnimationController?.value = animation.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final scrollController =
        PrimaryScrollController.maybeOf(context) ??
        (_scrollController ??= ScrollController());
    return ModalScrollController(
      controller: scrollController,
      child: Builder(
        builder:
            (context) => AnimatedBuilder(
              animation: widget.route.animationController!,
              builder: (BuildContext context, final Widget? child) {
                assert(child != null);
                // Disable the initial animation when accessible navigation is on so
                // that the semantics are added to the tree at the correct time.
                return Semantics(
                  scopesRoute: true,
                  namesRoute: true,
                  label: _getRouteLabel(),
                  explicitChildNodes: true,
                  child: BasePosBottomSheet(
                    closeProgressThreshold: widget.closeProgressThreshold,
                    expanded: widget.expanded,
                    containerBuilder: null,
                    animationController: widget.route.animationController!,
                    shouldClose:
                        widget.route.popDisposition ==
                                    RoutePopDisposition.doNotPop ||
                                widget.route.hasScopedWillPopCallback
                            ? () async {
                              // ignore: deprecated_member_use
                              final willPop = await widget.route.willPop();
                              final popDisposition =
                                  widget.route.popDisposition;
                              final shouldClose =
                                  !(willPop == RoutePopDisposition.doNotPop ||
                                      popDisposition ==
                                          RoutePopDisposition.doNotPop);
                              popDisposition == RoutePopDisposition.doNotPop;
                              if (!shouldClose) {
                                widget.route.onPopInvoked(false);
                              }
                              return shouldClose;
                            }
                            : null,
                    onClosing: () {
                      if (widget.route.isCurrent) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: child!,
                    enableDrag: widget.enableDrag,
                    bounce: widget.bounce,
                    scrollController: scrollController,
                    animationCurve: widget.animationCurve,
                  ),
                );
              },
              child: widget.builder(context),
            ),
      ),
    );
  }
}
