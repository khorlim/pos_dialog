import 'package:flutter/widgets.dart';

class PosBottomSheetConfig extends InheritedWidget {
  const PosBottomSheetConfig({
    super.key,
    required super.child,
    this.enableDrag = true,
    required this.updateEnableDrag,
  });

  final bool enableDrag;

  final void Function(bool draggable) updateEnableDrag;

  static PosBottomSheetConfig? of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<PosBottomSheetConfig>();
    return result;
  }

  @override
  bool updateShouldNotify(PosBottomSheetConfig oldWidget) =>
      enableDrag != oldWidget.enableDrag;
}
