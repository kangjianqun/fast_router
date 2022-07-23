import 'package:example/EmptyPage.dart';
import 'package:fast_router/fast_router.dart';
import 'package:flutter/widgets.dart';

import 'article.dart';

class Routers extends ModuleRouter {
  static const String _article = "/article";
  static const String _empty = "/empty";

  static void articlePage(bool rootRefresh, bool configState, bool loadData,
      bool isNew, bool isNavigator) {
    if (isNew) {
      var arguments = ArticleParamsData(rootRefresh, configState, loadData);
      if (isNavigator) {
        Navigator.of(FastRouter.context)
            .pushNamed(_article, arguments: arguments);
      } else {
        FastRouter.push(_article, arguments: arguments);
      }
    } else {
      FastRouter.push("$_article?rootRefresh=$rootRefresh"
          "&configState=$configState&loadData=$loadData");
    }
  }

  static void emptyPage() => FastRouter.push(_empty);

  @override
  void initPath() {
    define(
      _article,
      (context, parameters, arguments) {
        bool rootRefresh = false;
        bool configState = false;
        bool loadData = false;
        if (parameters != null) {
          rootRefresh = parse(parameters["rootRefresh"]?.first);
          configState = parse(parameters["configState"]?.first);
          loadData = parse(parameters["loadData"]?.first);
        } else if (arguments != null && arguments is ArticleParamsData) {
          rootRefresh = arguments.rootRefresh;
          configState = arguments.configState;
          loadData = arguments.loadData;
        }
        return ArticlePage(
          rootRefresh,
          configState: configState,
          loadData: loadData,
        );
      },
      transitionType: TransitionType.fadeIn,
    );

    define(_empty, (context, parameters, arguments) => const EmptyPage());
  }

  ///因为相互依赖这里不能依赖 fast_develop ，正常项目依赖fast_develop这个库就行，
  static bool parse(dynamic value) {
//    LogUtil.printLog(value);
    if (value is int) {
      return value == 1;
    } else if (value is String) {
      return value == "1" ||
          value.toLowerCase() == "true" ||
          value.toLowerCase() == "ok";
    } else if (value is bool) {
      return value;
    } else {
      return false;
    }
  }
}
