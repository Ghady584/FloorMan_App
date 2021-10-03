import 'package:flutter/material.dart';

//Copy this CustomPainter code to the Bottom of the File
class TablePainter extends CustomPainter {
  var color;
  var thickness;
  TablePainter({this.color, this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.7451333, size.height * 0.2872054);
    path_0.lineTo(size.width * 0.6479029, size.height * 0.2872054);
    path_0.cubicTo(
        size.width * 0.6198379,
        size.height * 0.2872054,
        size.width * 0.5912887,
        size.height * 0.2925712,
        size.width * 0.5630446,
        size.height * 0.3031503);
    path_0.cubicTo(
        size.width * 0.5429144,
        size.height * 0.3106916,
        size.width * 0.4570811,
        size.height * 0.3106938,
        size.width * 0.4369488,
        size.height * 0.3031503);
    path_0.cubicTo(
        size.width * 0.4087069,
        size.height * 0.2925690,
        size.width * 0.3801555,
        size.height * 0.2872054,
        size.width * 0.3520905,
        size.height * 0.2872054);
    path_0.lineTo(size.width * 0.2548623, size.height * 0.2872054);
    path_0.cubicTo(
        size.width * 0.1375261,
        size.height * 0.2872054,
        size.width * 0.04206656,
        size.height * 0.3826649,
        size.width * 0.04206656,
        size.height * 0.5000011);
    path_0.cubicTo(
        size.width * 0.04206656,
        size.height * 0.6173373,
        size.width * 0.1375261,
        size.height * 0.7127968,
        size.width * 0.2548623,
        size.height * 0.7127968);
    path_0.lineTo(size.width * 0.7451311, size.height * 0.7127968);
    path_0.cubicTo(
        size.width * 0.8624651,
        size.height * 0.7127968,
        size.width * 0.9579246,
        size.height * 0.6173373,
        size.width * 0.9579246,
        size.height * 0.5000011);
    path_0.cubicTo(
        size.width * 0.9579268,
        size.height * 0.3826649,
        size.width * 0.8624695,
        size.height * 0.2872054,
        size.width * 0.7451333,
        size.height * 0.2872054);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = this.color;
    canvas.drawPath(path_0, paint_0_fill);

    Path path_1 = Path();
    path_1.moveTo(size.width * 0.7456506, size.height * 0.2456517);
    path_1.lineTo(size.width * 0.5809130, size.height * 0.2456517);
    path_1.cubicTo(
        size.width * 0.5792084,
        size.height * 0.2456517,
        size.width * 0.5775369,
        size.height * 0.2461448,
        size.width * 0.5761043,
        size.height * 0.2470733);
    path_1.cubicTo(
        size.width * 0.5534029,
        size.height * 0.2617824,
        size.width * 0.5270867,
        size.height * 0.2695559,
        size.width * 0.4999989,
        size.height * 0.2695559);
    path_1.cubicTo(
        size.width * 0.4729111,
        size.height * 0.2695559,
        size.width * 0.4465927,
        size.height * 0.2617824,
        size.width * 0.4238935,
        size.height * 0.2470733);
    path_1.cubicTo(
        size.width * 0.4224609,
        size.height * 0.2461448,
        size.width * 0.4207916,
        size.height * 0.2456517,
        size.width * 0.4190848,
        size.height * 0.2456517);
    path_1.lineTo(size.width * 0.2543472, size.height * 0.2456517);
    path_1.cubicTo(size.width * 0.1140995, size.height * 0.2456517, 0,
        size.height * 0.3597512, 0, size.height * 0.5000011);
    path_1.cubicTo(
        0,
        size.height * 0.6402488,
        size.width * 0.1140995,
        size.height * 0.7543483,
        size.width * 0.2543472,
        size.height * 0.7543483);
    path_1.lineTo(size.width * 0.7456484, size.height * 0.7543483);
    path_1.cubicTo(
        size.width * 0.8858983,
        size.height * 0.7543483,
        size.width * 0.9999978,
        size.height * 0.6402488,
        size.width * 0.9999978,
        size.height * 0.4999989);
    path_1.cubicTo(
        size.width,
        size.height * 0.3597512,
        size.width * 0.8858983,
        size.height * 0.2456517,
        size.width * 0.7456506,
        size.height * 0.2456517);
    path_1.close();
    path_1.moveTo(size.width * 0.7456506, size.height * 0.7366612);
    path_1.lineTo(size.width * 0.2543472, size.height * 0.7366612);
    path_1.cubicTo(
        size.width * 0.1238539,
        size.height * 0.7366612,
        size.width * 0.01768710,
        size.height * 0.6304943,
        size.width * 0.01768710,
        size.height * 0.4999989);
    path_1.cubicTo(
        size.width * 0.01768710,
        size.height * 0.3695035,
        size.width * 0.1238539,
        size.height * 0.2633388,
        size.width * 0.2543472,
        size.height * 0.2633388);
    path_1.lineTo(size.width * 0.4165114, size.height * 0.2633388);
    path_1.cubicTo(
        size.width * 0.4415673,
        size.height * 0.2789875,
        size.width * 0.4703730,
        size.height * 0.2872430,
        size.width * 0.4999989,
        size.height * 0.2872430);
    path_1.cubicTo(
        size.width * 0.5296226,
        size.height * 0.2872430,
        size.width * 0.5584304,
        size.height * 0.2789875,
        size.width * 0.5834864,
        size.height * 0.2633388);
    path_1.lineTo(size.width * 0.7456506, size.height * 0.2633388);
    path_1.cubicTo(
        size.width * 0.8761461,
        size.height * 0.2633388,
        size.width * 0.9823129,
        size.height * 0.3695057,
        size.width * 0.9823129,
        size.height * 0.5000011);
    path_1.cubicTo(
        size.width * 0.9823129,
        size.height * 0.6304943,
        size.width * 0.8761461,
        size.height * 0.7366612,
        size.width * 0.7456506,
        size.height * 0.7366612);
    path_1.close();

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;

    if (thickness == "thin") {
      paint_1_fill.color = Color(0x000000).withOpacity(0.5);
    } else {
      paint_1_fill.color = Color(0x000000).withOpacity(1.0);
    }

    canvas.drawPath(path_1, paint_1_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
