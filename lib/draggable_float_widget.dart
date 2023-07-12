library draggable_float_widget;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'orntdrag.dart';

class DraggableFloatWidget extends StatefulWidget {

  final double? top; // top
  final double? left; // left
  final double? right;
  final double? bottom;
  final Widget child;
  final double bottomMargin; // 下边距缩进
  final double topMargin; // 上边距缩进
  final double horizontalSpace; // 水平边距
  final double verticalSpace; // 垂直边距
  final GlobalKey? containerKey; // 可滑动的区域，默认为全屏尺寸来适配
  final DraggableFloatController? controller; // 控制浮窗相关操作


  const DraggableFloatWidget({
    Key? key,
    required this.child,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.bottomMargin = 0,
    this.topMargin = 0,
    this.horizontalSpace = 10,
    this.verticalSpace = 10,
    this.containerKey,
    this.controller,
  }): assert(left == null || right == null),
        assert(top == null || bottom == null),
        super(key: key);

  @override
  _DraggableFloatWidgetState createState() => _DraggableFloatWidgetState();
}

class _DraggableFloatWidgetState extends State<DraggableFloatWidget> {

  double _top = 0;
  double _left = 0;
  double _width = 0;
  double _height = 0;
  final childKey = GlobalKey();
  bool dragging = false;
  double dragScale = 1.1;


  @override
  void initState() {
    updateBound();
    widget.controller?._setState(this);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return gposition();
  }

  /// position
  Widget gposition() {
    return Positioned(
      top: _top,
      left: _left,
      child: customGestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          key: childKey,
          margin: EdgeInsets.symmetric(
            horizontal: widget.horizontalSpace,
            vertical: widget.verticalSpace,
          ),
          child: Transform.scale(
              scale: dragging ? dragScale : 1,
              child: widget.child),
        ),
        // onHorizontalDragDown: onPanDown,
        // onHorizontalDragStart: onPanStart,
        // onHorizontalDragUpdate: onPanUpdate,
        // onHorizontalDragEnd: onPanEnd,
        // onHorizontalDragCancel: onPanCancel,
        // onVerticalDragDown: onPanDown,
        // onVerticalDragStart: onPanStart,
        // onVerticalDragUpdate: onPanUpdate,
        // onVerticalDragEnd: onPanEnd,
        // onVerticalDragCancel: onPanCancel,
        onPanDown: onPanDown,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        onPanCancel: onPanCancel,
      ),
    );
  }

  onPanCancel() {
    dragging = false;
    // 回到左边或右边
    boundLimitSetState(isEnd: true);
  }

  onPanEnd(DragEndDetails e) {
    onPanCancel();
  }
  onPanUpdate(DragUpdateDetails e) {
    //用户手指滑动时，更新偏移，重新构建
    _left += e.delta.dx;
    _top += e.delta.dy;
    boundLimitSetState();
  }
  onPanStart(DragStartDetails e) {
    if (kDebugMode) {
      print("gposition object: DragStartDetails: ${e.localPosition}");
    }
    dragging = true;
    /* customGestureDetector 已经处理了！
    // 回到点击中心点
    _left -= _width*dragScale/2.0 - e.localPosition.dx;
    _top -= _height*dragScale/2.0 - e.localPosition.dy;
    boundLimitSetState();
     */
  }
  onPanDown(DragDownDetails e) {
    //打印手指按下的位置(相对于屏幕)
    if (kDebugMode) {
      print("gposition object: DragDownDetails: ${e.localPosition}");
    }
  }

  // 范围限制
  boundLimitSetState({bool isEnd = false}) {
    // 所在容器范围
    Size containerSize = getWidgetSize(widget.containerKey);

    double containerWidth = containerSize.width;
    double containerHeight = containerSize.height;

    // 限制水平方向范围
    double maxLeft = containerWidth - _width;
    double minLeft = 0;

    // 限制垂直方向范围
    double maxTop = containerHeight - _height - widget.bottomMargin - widget.verticalSpace;
    double minTop = widget.topMargin + widget.verticalSpace;

    // if (kDebugMode) {
    //   print("gposition object: $_top, $_left, $_width, ${screentSize()}, $containerSize, left: $maxLeft, $minLeft, top: $maxTop, $minTop");
    // }

    if (_left < minLeft) {
      _left = minLeft;
    }else if (_left > maxLeft) {
      _left = maxLeft;
    }
    if (_top < minTop) {
      _top = minTop;
    }else if (_top > maxTop) {
      _top = maxTop;
    }

    if (isEnd) { // 结束吸边
      double containerCenterX = (containerWidth - _width)/2.0;
      if (_left < containerCenterX) {
        _left = minLeft;
      }else {
        _left = maxLeft;
      }
    }

    setState(() {});
  }

  // 更新初始化变量
  updateBound({bool isUpdate = false}) {
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
        final widgetSize = getWidgetSize(childKey);
        final Size containerSize = getWidgetSize(widget.containerKey);
        // 实际widgetSize.width是不可能大于屏幕一半的
        if (widgetSize.width < screentWidth()/2.0) {
          _height = widgetSize.height;
          _width = widgetSize.width;
        }
        if (!isUpdate) { // 更新就不要重置坐标了
          _top = widget.top ?? (containerSize.height - (widget.bottom ?? 0) - _height);
          _left = widget.left ?? (containerSize.width - (widget.right ?? 0) - _width);
        }
        if (kDebugMode) {
          print("gposition object: post: $_top, $_left, $_height, $_width, $widgetSize");
        }
        boundLimitSetState();
      });
    }
  }

  @override
  void didUpdateWidget(DraggableFloatWidget oldWidget) {
    // if (kDebugMode) {
    //   print("gposition object: didUpdateWidget: ${oldWidget.child != widget.child}");
    // }
    if (oldWidget.child != widget.child) updateBound(isUpdate: true);
    super.didUpdateWidget(oldWidget);
  }


  Size getWidgetSize(GlobalKey? key) {
    final obj = key?.currentContext?.findRenderObject();
    if (obj != null) {
      final box = obj as RenderBox;
      return box.size;
    } else {
      return screentSize();
    }
  }

  Size screentSize() => MediaQuery.of(context).size;
  double screentWidth() => MediaQuery.of(context).size.width;
  double screentHeight() => MediaQuery.of(context).size.height;

}

class DraggableFloatController {

  late _DraggableFloatWidgetState _state;

  _setState(_DraggableFloatWidgetState state) {
    _state = state;
  }
  /// 由外面手动触发更新
  updateWidget() {
    _state.updateBound(isUpdate: true);
  }
}

RawGestureDetector customGestureDetector({
  GestureDragDownCallback? onPanDown,
  GestureDragStartCallback? onPanStart,
  GestureDragUpdateCallback? onPanUpdate,
  GestureDragEndCallback? onPanEnd,
  GestureDragCancelCallback? onPanCancel,
  HitTestBehavior? behavior,
  Widget? child,
}) {
  return RawGestureDetector(
    child: child,
    behavior: behavior,
    gestures: {
      DirectionGestureRecognizer:
      GestureRecognizerFactoryWithHandlers<DirectionGestureRecognizer>(
            () => DirectionGestureRecognizer(DirectionGestureRecognizer.all),
            (detector) {
          detector.onCancel = onPanCancel;
          detector.onDown = onPanDown;
          detector.onStart = onPanStart;
          detector.onUpdate = onPanUpdate;
          detector.onEnd = onPanEnd;
        },
      )
    },
  );
}
