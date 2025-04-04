import 'package:flutter/material.dart';

Offset calculatePosDialogPosition({
  required Alignment followerAnchor,
  required Size childSize,
  required Offset position,
  required Offset offset,
  required bool avoidOverflow,
  required Size size,
}) {
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
