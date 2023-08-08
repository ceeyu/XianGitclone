import 'package:whiteboard_sdk_flutter/whiteboard_sdk_flutter.dart';

/// 快速工具類別，表示不同的白板工具
class FastAppliance {
  final String appliance;
  final String? shapeType;

  const FastAppliance(this.appliance, {this.shapeType});

  /// Clicker，可用於點擊和選擇 HTML5 文件上的內容。
  static const FastAppliance clicker = FastAppliance(ApplianceName.clicker);

  /// Selector
  static const FastAppliance selector = FastAppliance(ApplianceName.selector);

  /// 鉛筆
  static const FastAppliance pencil = FastAppliance(ApplianceName.pencil);

  /// 矩形
  static const FastAppliance rectangle = FastAppliance(ApplianceName.rectangle);

  /// 橢圓
  static const FastAppliance ellipse = FastAppliance(ApplianceName.ellipse);

  static const FastAppliance text = FastAppliance(ApplianceName.text);

  /// 橡皮擦
  static const FastAppliance eraser = FastAppliance(ApplianceName.eraser);

  /// 箭頭
  static const FastAppliance arrow = FastAppliance(ApplianceName.arrow);

  /// 直線。
  static const FastAppliance straight = FastAppliance(ApplianceName.straight);

  /// 五角星
  static const FastAppliance pentagram = FastAppliance(
    ApplianceName.shape,
    shapeType: ShapeType.pentagram,
  );

  /// 菱形
  static const FastAppliance rhombus = FastAppliance(
    ApplianceName.shape,
    shapeType: ShapeType.rhombus,
  );

  /// 三角形
  static const FastAppliance triangle = FastAppliance(
    ApplianceName.shape,
    shapeType: ShapeType.triangle,
  );

  /// 對話氣球。
  static const FastAppliance balloon = FastAppliance(
    ApplianceName.shape,
    shapeType: ShapeType.speechBalloon,
  );

  /// 清除當前白板頁面上的所有內容。
  static const FastAppliance clear = FastAppliance("");

  static const FastAppliance unknown = FastAppliance("unknown");

  static Map<FastAppliance, bool> kHasProperties = <FastAppliance, bool>{
    FastAppliance.clicker: false,
    FastAppliance.selector: false,
    FastAppliance.pencil: true,
    FastAppliance.rectangle: true,
    FastAppliance.ellipse: true,
    FastAppliance.text: true,
    FastAppliance.eraser: false,
    FastAppliance.arrow: true,
    FastAppliance.straight: true,
    FastAppliance.pentagram: true,
    FastAppliance.rhombus: true,
    FastAppliance.triangle: true,
    FastAppliance.balloon: true,
    FastAppliance.clear: false,
  };

  bool get hasProperties {
    return kHasProperties[this] ?? false;
  }

  /// 根據工具名稱和形狀類型返回對應的 FastAppliance 實例。
  static FastAppliance of(String? appliance, String? shapeType) {
    switch (appliance) {
      case ApplianceName.clicker:
        return clicker;
      case ApplianceName.selector:
        return selector;
      case ApplianceName.pencil:
        return pencil;
      case ApplianceName.text:
        return text;
      case ApplianceName.rectangle:
        return rectangle;
      case ApplianceName.ellipse:
        return ellipse;
      case ApplianceName.eraser:
        return eraser;
      case ApplianceName.arrow:
        return arrow;
      case ApplianceName.straight:
        return straight;
      case ApplianceName.shape:
        switch (shapeType) {
          case ShapeType.pentagram:
            return pentagram;
          case ShapeType.rhombus:
            return rhombus;
          case ShapeType.triangle:
            return triangle;
          case ShapeType.speechBalloon:
            return balloon;
        }
    }
    return unknown;
  }
}
