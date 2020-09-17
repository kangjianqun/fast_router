import 'package:flutter/widgets.dart';

/// 类型
enum HandlerType {
  route,
  function,
}

/// 处理
class Handler {
  Handler({this.type = HandlerType.route, this.handlerFunc});
  final HandlerType type;
  final HandlerFunc handlerFunc;
}

///
typedef Widget HandlerFunc(BuildContext context,
    Map<String, List<String>> parameters, Object arguments);

/// 路由item
class AppRoute {
  String route;
  dynamic handler;
  TransitionType transitionType;
  AppRoute(this.route, this.handler, {this.transitionType});
}

enum TransitionType {
  native,
  nativeModal,
  inFromLeft,
  inFromRight,
  inFromBottom,
  fadeIn,
  custom, // if using custom then you must also provide a transition
  material,
  materialFullScreenDialog,
  cupertino,
  cupertinoFullScreenDialog,
}

enum RouteMatchType {
  visual,
  nonVisual,
  noMatch,
}

///
class RouteMatch {
  RouteMatch(
      {this.matchType = RouteMatchType.noMatch,
      this.route,
      this.errorMessage = "Unable to match route. Please check the logs."});
  final Route<dynamic> route;
  final RouteMatchType matchType;
  final String errorMessage;
}

class RouteNotFoundException implements Exception {
  final String message;
  final String path;
  RouteNotFoundException(this.message, this.path);

  @override
  String toString() {
    return "No registered route was found to handle '$path'";
  }
}
