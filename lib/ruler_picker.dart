library ruler_picker;

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// a triangle painter
class _TrianglePainter extends CustomPainter {
  final double lineSize;

  _TrianglePainter({this.lineSize = 16});

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(lineSize, 0);
    path.lineTo(lineSize / 2, tan(pi / 3) * lineSize / 2);
    path.close();
    Paint paint = Paint();
    paint.color = Color.fromARGB(255, 118, 165, 248);
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

/// The controller for the ruler picker
/// init the ruler value from the controller
/// used for RulerPickerController，The default value can be initialized in the constructor
class RulerPickerController extends ValueNotifier<num> {
  RulerPickerController({num value = 0.0}) : super(value);

  num get value => super.value;

  set value(num newValue) {
    super.value = newValue;
  }
}

typedef void ValueChangedCallback(num value);

/// RulerPicker Ruler selector
/// [width] Must be a specific value, including the width of the parent container, not double.infinity
/// You can pass in MediaQuery.of(context).size.width
class RulerPicker extends StatefulWidget {
  final ValueChangedCallback onValueChange;
  final double width;
  final double height;
  final Color backgroundColor;

  /// the fraction digits of the picker value
  int fractionDigits;
  RulerPickerController? controller;

  /// the marker on the ruler, default is a arrow
  final Widget? marker;

  late double _value;

  RulerPicker({
    required this.onValueChange,
    required this.width,
    required this.height,
    this.backgroundColor = Colors.white,
    this.fractionDigits = 0,
    this.controller,
    this.marker,
  });

  @override
  State<StatefulWidget> createState() {
    return RulerPickerState();
  }
}

// TODO implement animateTo
class RulerPickerState extends State<RulerPicker> {
  double lastOffset = 0;
  bool isPosFixed = false;
  String? value;
  ScrollController? scrollController;

  /// default mark
  Widget mark() {
    /// default mark arrow
    Widget triangle() {
      return SizedBox(
        width: 16,
        height: 16,
        child: CustomPaint(
          painter: _TrianglePainter(),
        ),
      );
    }

    return Container(
      child: SizedBox(
        width: 16,
        height: 34,
        child: Stack(
          children: <Widget>[
            triangle(),
            Container(
              width: 3,
              height: 34,
              margin: EdgeInsets.only(left: 6),
              color: Color.fromARGB(255, 118, 165, 248),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.backgroundColor,
      child: Stack(
        children: <Widget>[
          Listener(
            onPointerDown: (event) {
              FocusScope.of(context).requestFocus(new FocusNode());
              isPosFixed = false;
            },
            onPointerUp: (event) {},
            child: NotificationListener(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                } else if (scrollNotification is ScrollUpdateNotification) {
                } else if (scrollNotification is ScrollEndNotification) {
                  if (!isPosFixed) {
                    isPosFixed = true;
                    // fixPosition((scrollNotification.metrics.pixels / 100)
                    //         .roundToDouble() *
                    //     100);
                    fixPosition(scrollNotification.metrics.pixels.roundToDouble());
                    scrollController!.notifyListeners();
                  }
                }
                return true;
              },
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    // constraints: BoxConstraints(maxWidth: 10),
                    padding: index == 0
                        ? EdgeInsets.only(
                      left: widget.width / 2,
                    )
                        : EdgeInsets.zero,
                    child: Container(
                      width: 10,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Container(
                            width: index % 10 == 0 ? 2 : 1,
                            height: index % 10 == 0 ? 32 : 20,
                            color: Color.fromARGB(255, 188, 194, 203),
                          ),
                          Positioned(
                            bottom: 5,
                            width: 50,
                            left: -25,
                            child: index % 10 == 0
                                ? Container(
                              alignment: Alignment.center,
                              child: Text(
                                index.toString(),
                                style: TextStyle(
                                  color: Color.fromARGB(255, 188, 194, 203),
                                  fontSize: 14,
                                ),
                              ),
                            )
                                : Container(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: widget.width / 2 - 6,
            child: widget.marker ?? mark(),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController!.addListener(() {
      setState(() {
        widget._value = double.parse((scrollController!.offset / 10).toStringAsFixed(widget.fractionDigits));
        if (widget._value < 0) widget._value = 0;
        if (widget.onValueChange != null) {
          widget.onValueChange(widget._value);
        }
      });
    });
    widget.controller!.addListener(() {
      setPositionByValue(widget.controller!.value);
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController!.dispose();
  }

  @override
  void didUpdateWidget(RulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void fixPosition(double curPos) {
    double targetPos = double.parse(curPos.toStringAsFixed(widget.fractionDigits));
    if (targetPos < 0) targetPos = 0;
    // todo animateTo
    scrollController!.jumpTo(
      targetPos,
      // duration: Duration(milliseconds: 500),
      // curve: Curves.easeOut,
    );
  }

  void setPositionByValue(num value) {
    num targetPos = value * 10;
    if (targetPos < 0) targetPos = 0;
    scrollController!.jumpTo(
      targetPos.toDouble(),
      // duration: Duration(milliseconds: 500),
      // curve: Curves.easeOut,
    );
  }
}
