## Features

Floating windows can be dragged

## Getting started

```dart
import 'package:widget_float_draggable/draggable_float_widget.dart';
```

## Usage

```dart
  /// 可拖拽浮窗
DraggableFloatWidget draggableFloatWidget() {
  return DraggableFloatWidget(
    // 设置位置
    top: ScreenUtil().statusBarHeight + 1000.px,
    right: 20.px,
    child: GameEvent(
      LocationName.GAME_HALL_PAGE,
      didChangeWidgetCallback: () {
        // 如果需要更新自身大小，则需要调用该函数
        floatController.updateWidget();
      },
    ),
    controller: floatController,
    // 设置父类容器
    containerKey: containerKey,
  );
}
```

## Additional information

Hava fun
