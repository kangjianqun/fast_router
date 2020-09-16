import 'package:example/EmptyPage.dart';
import 'package:fast_router/fast_router.dart';

import 'article.dart';

class Routers extends ModuleRouter {
  static String _article = "/article";
  static String _empty = "/empty";

  static void articlePage(bool rootRefresh, bool configState, bool loadData) {
    FastRouter.push("$_article?rootRefresh=$rootRefresh"
        "&configState=$configState&loadData=$loadData");
  }

  static void emptyPage() => FastRouter.push(_empty);

  @override
  void initPath() {
    define(
      _article,
      (context, parameters) => ArticlePage(
        parse(parameters["rootRefresh"]?.first),
        configState: parse(parameters["configState"]?.first),
        loadData: parse(parameters["loadData"]?.first),
      ),
      transitionType: TransitionType.fadeIn,
    );

    define(_empty, (context, parameters) => EmptyPage());
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
