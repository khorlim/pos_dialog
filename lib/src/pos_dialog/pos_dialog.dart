import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pos_dialog/src/pos_dialog/utils/pos_calculation.dart';

class PosDialog extends StatefulWidget {
  final Size size;
  final Alignment followerAnchor;
  final Offset position;
  final Offset offset;
  final bool avoidOverflow;
  final Widget child;
  final double arrowSize;
  const PosDialog({
    super.key,
    required this.size,
    required this.followerAnchor,
    required this.position,
    required this.offset,
    required this.avoidOverflow,
    required this.child,
    this.arrowSize = 20,
  });

  @override
  State<PosDialog> createState() => _PosDialogState();
}

class _PosDialogState extends State<PosDialog> {
  @override
  Widget build(BuildContext context) {
    // Calculate the arrow position relative to the dialog
    final dialogSize = widget.size;
    final screenSize = MediaQuery.of(context).size;

    // Calculate dialog position on screen
    Offset dialogPosition = calculateDialogPosition(
      followerAnchor: widget.followerAnchor,
      dialogSize: dialogSize,
      position: widget.position,
      offset: widget.offset,
      avoidOverflow: widget.avoidOverflow,
      screenSize: screenSize,
    );

    // Calculate where the target point is relative to the dialog
    Offset arrowPosition = widget.position - dialogPosition;

    // Center the arrow based on direction
    ArrowDirection arrowDirection = _determineArrowDirection(
      arrowPosition,
      dialogSize,
    );

    // Adjust arrow position based on direction for proper centering
    switch (arrowDirection) {
      case ArrowDirection.top:
      case ArrowDirection.bottom:
        arrowPosition = Offset(
          arrowPosition.dx - widget.arrowSize / 2,
          arrowPosition.dy,
        );
        break;
      case ArrowDirection.left:
      case ArrowDirection.right:
        arrowPosition = Offset(
          arrowPosition.dx,
          arrowPosition.dy - widget.arrowSize / 2,
        );
        break;
    }

    // // Constrain arrow position to dialog edges
    // arrowPosition = _constrainArrowPosition(
    //   arrowPosition,
    //   dialogSize,
    //   arrowDirection,
    // );

    // Calculate content padding based on arrow direction
    EdgeInsets contentPadding = _getContentPadding(arrowDirection);

    // Check if we need to show the arrow (don't show if dialog had to avoid overflow)
    bool showArrow =
        !widget.avoidOverflow ||
        (dialogPosition.dx >= 0 &&
            dialogPosition.dy >= 0 &&
            dialogPosition.dx + dialogSize.width <= screenSize.width &&
            dialogPosition.dy + dialogSize.height <= screenSize.height);

    return SizedBox(
      width: dialogSize.width,
      height: dialogSize.height,
      child: Stack(
        children: [
          // Dialog content with padding to make room for arrow
          Positioned.fill(
            child: Padding(padding: contentPadding, child: widget.child),
          ),

          // Arrow
          if (showArrow)
            Positioned(
              left: arrowPosition.dx,
              top: arrowPosition.dy,
              child: ArrowWidget(
                direction: arrowDirection,
                color: Theme.of(context).dialogBackgroundColor,
                size: widget.arrowSize,
              ),
            ),
        ],
      ),
    );
  }

  // Determine which direction the arrow should point
  ArrowDirection _determineArrowDirection(
    Offset arrowPosition,
    Size dialogSize,
  ) {
    // Check if arrow is closer to top/bottom or left/right edges
    double topDistance = arrowPosition.dy;
    double bottomDistance = dialogSize.height - arrowPosition.dy;
    double leftDistance = arrowPosition.dx;
    double rightDistance = dialogSize.width - arrowPosition.dx;

    double minDistance = [
      topDistance,
      bottomDistance,
      leftDistance,
      rightDistance,
    ].reduce((curr, next) => curr < next ? curr : next);

    if (minDistance == topDistance) return ArrowDirection.top;
    if (minDistance == bottomDistance) return ArrowDirection.bottom;
    if (minDistance == leftDistance) return ArrowDirection.left;
    if (minDistance == rightDistance) return ArrowDirection.right;

    return ArrowDirection.top; // Default
  }

  // Constrain arrow position to be on the edge of the dialog
  Offset _constrainArrowPosition(
    Offset position,
    Size dialogSize,
    ArrowDirection direction,
  ) {
    final arrowSize = widget.arrowSize;
    const padding = 0.0; // Minimum distance from corners

    switch (direction) {
      case ArrowDirection.top:
        return Offset(
          _clamp(position.dx, padding, dialogSize.width - padding),
          0,
        );
      case ArrowDirection.bottom:
        return Offset(
          _clamp(position.dx, padding, dialogSize.width - padding),
          dialogSize.height - arrowSize,
        );
      case ArrowDirection.left:
        return Offset(
          0,
          _clamp(position.dy, padding, dialogSize.height - padding),
        );
      case ArrowDirection.right:
        return Offset(
          dialogSize.width - arrowSize,
          _clamp(position.dy, padding, dialogSize.height - padding),
        );
    }
  }

  double _clamp(double value, double min, double max) {
    return value < min ? min : (value > max ? max : value);
  }

  // Get content padding based on arrow direction
  EdgeInsets _getContentPadding(ArrowDirection direction) {
    final arrowPadding = widget.arrowSize;

    switch (direction) {
      case ArrowDirection.top:
        return EdgeInsets.only(top: arrowPadding);
      case ArrowDirection.bottom:
        return EdgeInsets.only(bottom: arrowPadding);
      case ArrowDirection.left:
        return EdgeInsets.only(left: arrowPadding);
      case ArrowDirection.right:
        return EdgeInsets.only(right: arrowPadding);
    }
  }
}

// Helper function to calculate dialog position
Offset calculateDialogPosition({
  required Alignment followerAnchor,
  required Size dialogSize,
  required Offset position,
  required Offset offset,
  required bool avoidOverflow,
  required Size screenSize,
}) {
  Offset anchorPoint = followerAnchor.alongSize(dialogSize);
  Offset dialogPosition = position - anchorPoint + offset;

  if (avoidOverflow) {
    if (dialogPosition.dx < 0) dialogPosition = Offset(0, dialogPosition.dy);
    if (dialogPosition.dy < 0) dialogPosition = Offset(dialogPosition.dx, 0);
    if (dialogPosition.dx + dialogSize.width > screenSize.width)
      dialogPosition = Offset(
        screenSize.width - dialogSize.width,
        dialogPosition.dy,
      );
    if (dialogPosition.dy + dialogSize.height > screenSize.height)
      dialogPosition = Offset(
        dialogPosition.dx,
        screenSize.height - dialogSize.height,
      );
  }

  return dialogPosition;
}

// Arrow direction enum
enum ArrowDirection { top, bottom, left, right }

// Arrow widget implementation
class ArrowWidget extends StatelessWidget {
  final ArrowDirection direction;
  final Color color;
  final double size;

  const ArrowWidget({
    Key? key,
    required this.direction,
    required this.color,
    this.size = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: ArrowPainter(direction: direction, color: color),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final ArrowDirection direction;
  final Color color;

  ArrowPainter({required this.direction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final Path path = Path();

    switch (direction) {
      case ArrowDirection.top:
        path.moveTo(0, size.height);
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        break;
      case ArrowDirection.bottom:
        path.moveTo(0, 0);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(size.width, 0);
        break;
      case ArrowDirection.left:
        path.moveTo(size.width, 0);
        path.lineTo(0, size.height / 2);
        path.lineTo(size.width, size.height);
        break;
      case ArrowDirection.right:
        path.moveTo(0, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
