import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common.dart';
import 'tree.dart';

typedef RouterCallback = void Function(dynamic data);

Color fastRouterBgColor = Colors.white;
Duration fastRouterTransitionDuration = Duration(milliseconds: 250);
Widget notFoundWidget = Center(child: Text("未找到目标页面"));

initRouter(Color backgroundColor, Widget notFoundPage) {
  if (backgroundColor != null) fastRouterBgColor = backgroundColor;
  if (notFoundPage != null) notFoundWidget = notFoundPage;
}

///  定义路由对应的页面
abstract class ModuleRouter implements IModuleRouter {
  FastRouter router;

  /// 子类无需调用
  void initRouter(FastRouter router) {
    this.router = router;
    initPath();
  }

  ///路径与页匹配
  void define(String path, HandlerFunc handlerFunc,
      {TransitionType transitionType}) {
    router.define(
      path,
      handler: Handler(handlerFunc: handlerFunc),
      transitionType: transitionType,
    );
  }
}

/// 接口
abstract class IModuleRouter {
  void initPath();
}

/// 路由观察
/// 省略Context 即可调用
class RouterObserver extends NavigatorObserver {
  /// 静态私有成员，没有初始化
  static RouterObserver _instance;
  factory RouterObserver() => _getInstance();

  /// 私有构造函数 初始化
  RouterObserver._internal();

  /// 静态、同步、私有访问点
  static RouterObserver _getInstance() {
    if (_instance == null) {
      _instance = RouterObserver._internal();
    }
    return _instance;
  }
}

/// 匹配路径名称
/// 判断是否匹配到路径
RoutePredicate withName(String path) {
  return (Route<dynamic> route) {
    var result = false;
    if (!route.willHandlePopInternally && route is ModalRoute) {
      var n = route.settings.name;
//        LogUtil.printLog(n);
      try {
        if (n != null && n.contains("?")) {
          n = n.substring(0, n.indexOf("?"));
        }
      } catch (e) {
//        LogUtil.printLog(e);
      }

      result = n == path;
//        LogUtil.printLog("settingsName: ${route.settings.name}"
//            " newName: $n"
//            " targetName: $name");
    }
    return result;
  };
}

/// 路由使用
class FastRouter {
  /// 存储定义路线的树结构
  final RouteTree _routeTree = RouteTree();

  /// 未定义路线时的通用处理
  Handler notFoundHandler;

  static FastRouter _router;

  static FastRouter get router => _router;

  /// 自定义路由观察者
  static RouterObserver get observer => RouterObserver();

  /// 观察者对象的上下文
  static BuildContext get context => RouterObserver().navigator.context;

  /// 配置路由
  static void configureRouters(FastRouter config, List<ModuleRouter> listRouter,
      {Handler emptyPage, Duration transitionDuration}) {
    FastRouter._router = config;

    /// 指定路由跳转错误返回页
    FastRouter._router.notFoundHandler = emptyPage;
    FastRouter._router.notFoundHandler ??= Handler(
      handlerFunc: (context, params, arguments) {
        debugPrint("未找到目标页");
        return Container(color: fastRouterBgColor, child: notFoundWidget);
      },
    );

    if (transitionDuration != null)
      fastRouterTransitionDuration = transitionDuration;

    listRouter
        .forEach((moduleRouter) => moduleRouter.initRouter(FastRouter._router));
  }

  /// 为传递的[RouteHandler]创建[PageRoute]定义。您可以选择提供默认的过渡类型。
  void define(String routePath,
      {@required Handler handler, TransitionType transitionType}) {
    _routeTree.addRoute(
      AppRoute(routePath, handler, transitionType: transitionType),
    );
  }

  /// 未找到路径
  Route<Null> _notFoundRoute(String path) {
    var routeSettings = RouteSettings(name: path);
    return MaterialPageRoute<Null>(
      settings: routeSettings,
      builder: (context) => notFoundHandler.handlerFunc(context, null, null),
    );
  }

  RouteTransitionsBuilder _standardTransitionsBuilder(
      TransitionType transitionType) {
    return (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      if (transitionType == TransitionType.fadeIn) {
        return FadeTransition(opacity: animation, child: child);
      } else {
        const Offset topLeft = const Offset(0.0, 0.0);
        const Offset topRight = const Offset(1.0, 0.0);
        const Offset bottomLeft = const Offset(0.0, 1.0);
        Offset startOffset = bottomLeft;
        Offset endOffset = topLeft;
        if (transitionType == TransitionType.inFromLeft) {
          startOffset = const Offset(-1.0, 0.0);
          endOffset = topLeft;
        } else if (transitionType == TransitionType.inFromRight) {
          startOffset = topRight;
          endOffset = topLeft;
        }

        return SlideTransition(
          position: Tween<Offset>(
            begin: startOffset,
            end: endOffset,
          ).animate(animation),
          child: child,
        );
      }
    };
  }

  /// dialog  pop
  static popBackDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// [targetPath]目标页面   [openPage]打开页面  [result]数据
  static popBack({String targetPath, String openPage, result}) {
    _router._popBack(
        targetPath: targetPath, showPage: openPage, result: result);
  }

  static push(
    String path, {
    String targetPath,
    bool replace = false,
    Object arguments,
    RouterCallback callback,
    TransitionType transition,
    Duration transitionDuration,
    RouteTransitionsBuilder transitionBuilder,
  }) {
    _router
        ._navigate(
      path,
      targetPath: targetPath,
      replace: replace,
      arguments: arguments,
      transition: transition,
      transitionDuration: transitionDuration,
      transitionBuilder: transitionBuilder,
    )
        .then((result) {
      if (callback != null) callback(result);
    });
  }

  /// 回退
  _popBack({String targetPath, String showPage, result}) {
    if (showPage != null && showPage.isNotEmpty) {
      FastRouter._router._navigate(showPage,
          targetPath: targetPath, replace: true, pop: true);
    } else if (targetPath != null && targetPath.isNotEmpty) {
      observer.navigator.popUntil(withName(targetPath));
    } else {
      observer.navigator.pop(result);
    }
  }

  /// 跳转页面
  Future _navigate(
    String showPath, {
    String targetPath,
    bool replace = false,
    Object arguments,
    TransitionType transition,
    Duration transitionDuration,
    RouteTransitionsBuilder transitionBuilder,
    bool pop = false,
  }) {
    RouteMatch routeMatch = _matchRoute(showPath,
        buildContext: context,
        transitionType: transition,
        arguments: arguments,
        transitionsBuilder: transitionBuilder,
        transitionDuration: transitionDuration);
    Route<dynamic> route = routeMatch.route;
    Completer completer = Completer();
    Future future = completer.future;
    if (routeMatch.matchType == RouteMatchType.nonVisual) {
      completer.complete("Non visual route type.");
    } else {
      if (route == null && notFoundHandler != null) {
        route = _notFoundRoute(showPath);
      }
      if (route != null) {
        future =
            _action(replace, route, targetPath, pop: pop, showPath: showPath);
        completer.complete();
      } else {
        String error = "No registered route was found to handle '$showPath'.";
        print(error);
        completer.completeError(RouteNotFoundException(error, showPath));
      }
    }
    return future;
  }

  /// 跳转行为
  Future _action(bool replace, Route route, String targetPath,
      {String showPath, bool pop = false}) {
    var future;
    var clearStack = targetPath != null && targetPath.isNotEmpty;
    if (pop) {
      if (showPath != null && showPath.isNotEmpty) {
        future = observer.navigator
            .popAndPushNamed(showPath, result: withName(targetPath));
      } else {
        future = Future.sync(
            () => observer.navigator.popUntil(withName(targetPath)));
      }
    } else {
      if (clearStack) {
        future =
            observer.navigator.pushAndRemoveUntil(route, withName(targetPath));
      } else {
        future = replace
            ? observer.navigator.pushReplacement(route)
            : observer.navigator.push(route);
      }
    }
    return future;
  }

  /// 匹配路由 [arguments] 参数
  RouteMatch _matchRoute(String path,
      {BuildContext buildContext,
      Object arguments,
      TransitionType transitionType,
      Duration transitionDuration,
      RouteTransitionsBuilder transitionsBuilder}) {
    AppRouteMatch match = _routeTree.matchRoute(path);
    AppRoute route = match?.route;
    Handler handler = (route != null ? route.handler : notFoundHandler);

    /// 参数
    Map<String, List<String>> parameters = match?.parameters;

    RouteSettings _settings = RouteSettings(
      name: path,
      arguments: arguments ?? parameters.isEmpty ? null : parameters,
    );

    var type = transitionType ?? route?.transitionType ?? TransitionType.native;
    if (route == null && notFoundHandler == null) {
      return RouteMatch(
          matchType: RouteMatchType.noMatch,
          errorMessage: "No matching route was found");
    }
    if (handler.type == HandlerType.function) {
      handler.handlerFunc(buildContext, parameters, arguments);
      return RouteMatch(matchType: RouteMatchType.nonVisual);
    }

    return RouteMatch(
      matchType: RouteMatchType.visual,
      route: _creatorRouter(
          _settings, handler, type, transitionsBuilder, transitionDuration),
    );
  }

  /// 创建路由
  Route<dynamic> _creatorRouter(
      RouteSettings settings,
      Handler handler,
      TransitionType type,
      RouteTransitionsBuilder transitionsBuilder,
      Duration transitionDuration) {
    bool isNativeTransition =
        (type == TransitionType.native || type == TransitionType.nativeModal);
    var _arguments = settings.arguments;
    Map<String, List<String>> _parameters;

    if (_arguments is Map<String, List<String>>) _parameters = _arguments;
    if (isNativeTransition) {
      if (Platform.isIOS) {
        return CupertinoPageRoute<dynamic>(
            settings: settings,
            fullscreenDialog: type == TransitionType.nativeModal,
            builder: (context) =>
                handler.handlerFunc(context, _parameters, _arguments));
      } else {
        return MaterialPageRoute<dynamic>(
            settings: settings,
            fullscreenDialog: type == TransitionType.nativeModal,
            builder: (context) =>
                handler.handlerFunc(context, _parameters, _arguments));
      }
    } else if (type == TransitionType.material ||
        type == TransitionType.materialFullScreenDialog) {
      return MaterialPageRoute<dynamic>(
          settings: settings,
          fullscreenDialog: type == TransitionType.materialFullScreenDialog,
          builder: (context) =>
              handler.handlerFunc(context, _parameters, _arguments));
    } else if (type == TransitionType.cupertino ||
        type == TransitionType.cupertinoFullScreenDialog) {
      return CupertinoPageRoute<dynamic>(
          settings: settings,
          fullscreenDialog: type == TransitionType.cupertinoFullScreenDialog,
          builder: (context) =>
              handler.handlerFunc(context, _parameters, _arguments));
    } else {
      var routeTransitionsBuilder;
      if (type == TransitionType.custom) {
        routeTransitionsBuilder = transitionsBuilder;
      } else {
        routeTransitionsBuilder = _standardTransitionsBuilder(type);
      }
      return PageRouteBuilder<dynamic>(
        settings: settings,
        pageBuilder: (context, Animation<double> animation,
                Animation<double> secondaryAnimation) =>
            handler.handlerFunc(context, _parameters, _arguments),
        transitionDuration: transitionDuration ?? fastRouterTransitionDuration,
        transitionsBuilder: routeTransitionsBuilder,
      );
    }
  }

  /// Route generation method. This function can be used as a way to create routes on-the-fly
  /// if any defined handler is found. It can also be used with the [MaterialApp.onGenerateRoute]
  /// property as callback to create routes that can be used with the [Navigator] class.
  Route<dynamic> generator(RouteSettings routeSettings) {
    RouteMatch match =
        _matchRoute(routeSettings.name, arguments: routeSettings.arguments);
    return match.route;
  }

  /// 打印路由树，以便于您对其进行分析。
  void printTree() => _routeTree.printTree();
}
