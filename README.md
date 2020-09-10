# fast_router

 修改自 fluro 的新版本 加入一些新方法
 日常使用，加入一些便捷方法不需要context，可以抛弃Navigator
 支持ios  左滑 跟 android原生路由跳转

初始化路由
```
FastRouter.configureRouters(FastRouter(), [Routers()]);
```
然后配置 <kbd>navigatorObservers</kbd> 和<kbd>onGenerateRoute</kbd>
```
 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [FastRouter.observer],
      onGenerateRoute: FastRouter.router.generator,
      home: SelectPage(),
    );
  }
```
新建 Routers 类统一管理路由
```
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

```

页面调用
```
  void pushArticle(bool rootRefresh, bool isConfigState, bool isLoadData) {
    Routers.articlePage(rootRefresh, isConfigState, isLoadData);
  }

  ListTile(
              title: Text("空页面，不传参数"),
              onTap: () => Routers.emptyPage(),
            )
```

 一个MVVM框架fast_mvvm附带简单的demo,会一直更新，希望支持一下.有问题可以反馈QQ 275918180。
 博客讲解：https://blog.csdn.net/q948182974/article/details/106613565

 掘金讲解：https://juejin.im/post/5ee86c9b51882543313a0de7

