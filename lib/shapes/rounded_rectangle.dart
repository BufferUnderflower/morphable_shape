import 'dart:math';

import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:morphable_shape/ui_data_classes/dynamic_rectangle_styles.dart';

///Rectangle shape with various corner style and radius for each corner
class RoundedRectangleShape extends FilledBorderShape {
  final RectangleBorders borders;

  final DynamicBorderRadius borderRadius;

  const RoundedRectangleShape({
    this.borderRadius =
        const DynamicBorderRadius.all(DynamicRadius.circular(Length(0))),
    this.borders = const RectangleBorders.all(DynamicBorderSide.none),
  });

  RoundedRectangleShape.fromJson(Map<String, dynamic> map)
      : borderRadius = parseDynamicBorderRadius(map["borderRadius"]) ??
            DynamicBorderRadius.all(DynamicRadius.circular(Length(0))),
        this.borders = parseRectangleBorderSide(map["borders"]) ??
            RectangleBorders.all(DynamicBorderSide.none);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"type": "RoundedRectangleShape"};
    rst["borderRadius"] = borderRadius.toJson();
    rst["borders"] = borders.toJson();
    return rst;
  }

  RoundedRectangleShape copyWith(
      {RectangleBorders? borders, DynamicBorderRadius? borderRadius}) {
    return RoundedRectangleShape(
        borders: borders ?? this.borders,
        borderRadius: borderRadius ?? this.borderRadius);
  }

  bool isSameMorphGeometry(Shape shape) {
    return shape is RectangleShape || shape is RoundedRectangleShape;
  }

  EdgeInsetsGeometry get dimensions => EdgeInsets.only(
      top: borders.top.width,
      bottom: borders.bottom.width,
      left: borders.left.width,
      right: borders.right.width);

  List<Color> borderFillColors() {
    List<Color> rst = [];
    rst.addAll(List.generate(3, (index) => borders.top.color));
    rst.addAll(List.generate(3, (index) => borders.right.color));
    rst.addAll(List.generate(3, (index) => borders.bottom.color));
    rst.addAll(List.generate(3, (index) => borders.left.color));
    return rotateList(rst, 2).cast<Color>();
  }

  @override
  List<Gradient?> borderFillGradients() {
    List<Gradient?> rst = [];
    rst.addAll(List.generate(3, (index) => borders.top.gradient));
    rst.addAll(List.generate(3, (index) => borders.right.gradient));
    rst.addAll(List.generate(3, (index) => borders.bottom.gradient));
    rst.addAll(List.generate(3, (index) => borders.left.gradient));
    return rotateList(rst, 2).cast<Gradient?>();
  }

  DynamicPath generateInnerDynamicPath(Rect rect) {
    Size size = rect.size;

    double leftSideWidth = this.borders.left.width;
    double rightSideWidth = this.borders.right.width;
    double topSideWidth = this.borders.top.width;
    double bottomSideWidth = this.borders.bottom.width;

    BorderRadius borderRadius = this.borderRadius.toBorderRadius(size: size);

    double topLeftRadius = borderRadius.topLeft.x;
    double topRightRadius = borderRadius.topRight.x;

    double bottomLeftRadius = borderRadius.bottomLeft.x;
    double bottomRightRadius = borderRadius.bottomRight.x;

    double leftTopRadius = borderRadius.topLeft.y;
    double leftBottomRadius = borderRadius.bottomLeft.y;

    double rightTopRadius = borderRadius.topRight.y;
    double rightBottomRadius = borderRadius.bottomRight.y;

    ///Handling the case when either the border with or
    ///corner radius is too big
    double topTotal =
        max(topLeftRadius, leftSideWidth) + max(topRightRadius, rightSideWidth);
    double bottomTotal = max(bottomLeftRadius, leftSideWidth) +
        max(bottomRightRadius, rightSideWidth);
    double leftTotal = max(leftTopRadius, topSideWidth) +
        max(leftBottomRadius, bottomSideWidth);
    double rightTotal = max(rightTopRadius, topSideWidth) +
        max(rightBottomRadius, bottomSideWidth);

    if (max(topTotal, bottomTotal) > size.width ||
        max(leftTotal, rightTotal) > size.height) {
      double resizeRatio = min(size.width / max(topTotal, bottomTotal),
          size.height / max(leftTotal, rightTotal));

      topLeftRadius *= resizeRatio;
      topRightRadius *= resizeRatio;
      bottomLeftRadius *= resizeRatio;
      bottomRightRadius *= resizeRatio;
      leftSideWidth *= resizeRatio;
      rightSideWidth *= resizeRatio;

      leftTopRadius *= resizeRatio;
      rightTopRadius *= resizeRatio;
      leftBottomRadius *= resizeRatio;
      rightBottomRadius *= resizeRatio;
      topSideWidth *= resizeRatio;
      bottomSideWidth *= resizeRatio;
    }

    final double left = rect.left;
    final double top = rect.top;
    final double bottom = rect.bottom;
    final double right = rect.right;

    List<DynamicNode> nodes = [];

    double r1, r2, sweep1;
    var centerRect;

    r1 = max(0.0000001, 2 * topRightRadius - 2 * rightSideWidth);
    r2 = max(0.0000001, 2 * rightTopRadius - 2 * topSideWidth);
    centerRect = Rect.fromCenter(
        center: Offset(right - max(topRightRadius, rightSideWidth),
            top + max(rightTopRadius, topSideWidth)),
        width: r1,
        height: r2);
    sweep1 = r1 / (r1 + r2) * pi / 2;
    nodes.addArc(centerRect, -pi / 2, sweep1, splitTimes: 0);
    List<Offset> points = arcToCubicBezier(
        centerRect, -pi / 2 + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    r1 = max(0.0000001, 2 * bottomRightRadius - 2 * rightSideWidth);
    r2 = max(0.0000001, 2 * rightBottomRadius - 2 * bottomSideWidth);
    centerRect = Rect.fromCenter(
        center: Offset(right - max(bottomRightRadius, rightSideWidth),
            bottom - max(rightBottomRadius, bottomSideWidth)),
        width: r1,
        height: r2);
    sweep1 = r2 / (r1 + r2) * pi / 2;
    nodes.addArc(centerRect, 0, sweep1, splitTimes: 0);
    points = arcToCubicBezier(centerRect, 0 + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    r1 = max(0.0000001, 2 * bottomLeftRadius - 2 * leftSideWidth);
    r2 = max(0.0000001, 2 * leftBottomRadius - 2 * bottomSideWidth);
    centerRect = Rect.fromCenter(
        center: Offset(left + max(leftSideWidth, bottomLeftRadius),
            bottom - max(bottomSideWidth, leftBottomRadius)),
        width: r1,
        height: r2);
    sweep1 = r1 / (r1 + r2) * pi / 2;
    nodes.addArc(centerRect, pi / 2, sweep1, splitTimes: 0);
    points = arcToCubicBezier(centerRect, pi / 2 + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    r1 = max(0.0000001, 2 * topLeftRadius - 2 * leftSideWidth);
    r2 = max(0.0000001, 2 * leftTopRadius - 2 * topSideWidth);
    centerRect = Rect.fromCenter(
        center: Offset(left + max(leftSideWidth, topLeftRadius),
            top + max(topSideWidth, leftTopRadius)),
        width: r1,
        height: r2);
    sweep1 = r2 / (r1 + r2) * pi / 2;
    nodes.addArc(centerRect, pi, sweep1, splitTimes: 0);
    points = arcToCubicBezier(centerRect, pi + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    return DynamicPath(size: rect.size, nodes: nodes);
  }

  DynamicPath generateOuterDynamicPath(Rect rect) {
    Size size = rect.size;
    List<DynamicNode> nodes = [];

    final double left = rect.left;
    final double top = rect.top;
    final double bottom = rect.bottom;
    final double right = rect.right;

    double leftSideWidth = this.borders.left.width;
    double rightSideWidth = this.borders.right.width;
    double topSideWidth = this.borders.top.width;
    double bottomSideWidth = this.borders.bottom.width;

    BorderRadius borderRadius = this.borderRadius.toBorderRadius(size: size);

    double topLeftRadius = borderRadius.topLeft.x;
    double topRightRadius = borderRadius.topRight.x;

    double bottomLeftRadius = borderRadius.bottomLeft.x;
    double bottomRightRadius = borderRadius.bottomRight.x;

    double leftTopRadius = borderRadius.topLeft.y;
    double leftBottomRadius = borderRadius.bottomLeft.y;

    double rightTopRadius = borderRadius.topRight.y;
    double rightBottomRadius = borderRadius.bottomRight.y;

    ///Handling the case when either the border with or
    ///corner radius is too big
    double topTotal =
        max(topLeftRadius, leftSideWidth) + max(topRightRadius, rightSideWidth);
    double bottomTotal = max(bottomLeftRadius, leftSideWidth) +
        max(bottomRightRadius, rightSideWidth);
    double leftTotal = max(leftTopRadius, topSideWidth) +
        max(leftBottomRadius, bottomSideWidth);
    double rightTotal = max(rightTopRadius, topSideWidth) +
        max(rightBottomRadius, bottomSideWidth);

    if (max(topTotal, bottomTotal) > size.width ||
        max(leftTotal, rightTotal) > size.height) {
      double resizeRatio = min(size.width / max(topTotal, bottomTotal),
          size.height / max(leftTotal, rightTotal));

      topLeftRadius *= resizeRatio;
      topRightRadius *= resizeRatio;
      bottomLeftRadius *= resizeRatio;
      bottomRightRadius *= resizeRatio;
      leftSideWidth *= resizeRatio;
      rightSideWidth *= resizeRatio;

      leftTopRadius *= resizeRatio;
      rightTopRadius *= resizeRatio;
      leftBottomRadius *= resizeRatio;
      rightBottomRadius *= resizeRatio;
      topSideWidth *= resizeRatio;
      bottomSideWidth *= resizeRatio;
    }

    double r1, r2, sweep1;
    var centerRect;

    r1 = 2 * topRightRadius;
    r2 = 2 * rightTopRadius;
    centerRect = Rect.fromCenter(
        center: Offset(right - topRightRadius, top + rightTopRadius),
        width: r1,
        height: r2);
    sweep1 = r1 / (r1 + r2 + 0.0000001) * pi / 2;
    nodes.addArc(centerRect, -pi / 2, sweep1, splitTimes: 0);
    List<Offset> points = arcToCubicBezier(
        centerRect, -pi / 2 + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    r1 = 2 * bottomRightRadius;
    r2 = 2 * rightBottomRadius;
    centerRect = Rect.fromCenter(
        center: Offset(right - bottomRightRadius, bottom - rightBottomRadius),
        width: r1,
        height: r2);
    sweep1 = r2 / (r1 + r2 + 0.0000001) * pi / 2;
    nodes.addArc(centerRect, 0, sweep1, splitTimes: 0);
    points = arcToCubicBezier(centerRect, 0 + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    r1 = 2 * bottomLeftRadius;
    r2 = 2 * leftBottomRadius;
    centerRect = Rect.fromCenter(
        center: Offset(left + bottomLeftRadius, bottom - leftBottomRadius),
        width: r1,
        height: r2);
    sweep1 = r1 / (r1 + r2 + 0.0000001) * pi / 2;
    nodes.addArc(centerRect, pi / 2, sweep1, splitTimes: 0);
    points = arcToCubicBezier(centerRect, pi / 2 + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    r1 = 2 * topLeftRadius;
    r2 = 2 * leftTopRadius;
    centerRect = Rect.fromCenter(
        center: Offset(left + topLeftRadius, top + leftTopRadius),
        width: r1,
        height: r2);
    sweep1 = r2 / (r1 + r2 + 0.0000001) * pi / 2;
    nodes.addArc(centerRect, pi, sweep1, splitTimes: 0);
    points = arcToCubicBezier(centerRect, pi + sweep1, pi / 2 - sweep1,
        splitTimes: 0);
    for (int i = 0; i < points.length; i += 4) {
      nodes.cubicTo(points[i + 1], points[i + 2], points[i + 3]);
    }

    return DynamicPath(size: rect.size, nodes: nodes);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is RoundedRectangleShape &&
        other.borders == borders &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => hashValues(borders, borderRadius);
}
