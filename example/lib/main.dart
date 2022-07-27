import 'package:fast_mvvm/fast_mvvm.dart';
import 'package:fast_router/fast_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'article.dart';
import 'routers.dart';

void main() {
  runApp(const App());
}

class UserModel extends BaseModel {
  Future<bool> login(String account, String psd) async {
    await Future.delayed(const Duration(seconds: 3));
    return true;
  }

  Future<DataResponse<ArticleEntity>> getArticleList() async {
    await Future.delayed(const Duration(seconds: 1));

    var entity = ArticleEntity([
      ArticleItem("1", "好的", "内容内容内容内容内容", DateTime.now().toString()),
      ArticleItem("1", "好的", "内容内容内容内容内容", DateTime.now().toString()),
    ]);

    DataResponse<ArticleEntity> dataResponse =
    DataResponse<ArticleEntity>(entity: entity, totalPageNum: 3);
    return dataResponse;
  }
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    initMVVM<BaseViewModel>(
      [UserModel()],
      controllerBuild: () => EasyRefreshController(),
      resetRefreshState: (c) =>
          (c as EasyRefreshController).resetRefreshState(),
      finishRefresh: (c, {bool success = true, bool noMore = false}) =>
          (c as EasyRefreshController)
              .finishRefresh(success: success, noMore: noMore),
      resetLoadState: (c) => (c as EasyRefreshController).resetLoadState(),
      finishLoad: (c, {bool success = true, bool noMore = false}) =>
          (c as EasyRefreshController)
              .finishLoad(success: success, noMore: noMore),
    );
    FastRouter.configureRouters(FastRouter(), [Routers()]);

    platform.setMethodCallHandler((call) async {
      print('platform.setMethodCallHandler((call)');
      Routers.nativeToFlutter();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [FastRouter.observer],
      onGenerateRoute: FastRouter.router.generator,
      home: const SelectPage(),
    );
  }
}

class SelectVM extends BaseViewModel {
  ValueNotifier<bool> isLoadData = ValueNotifier(true);
  ValueNotifier<bool> isConfigState = ValueNotifier(false);
}

class SelectPage extends StatelessWidget with BaseView<SelectVM> {
  const SelectPage({Key? key}) : super(key: key);

  @override
  ViewConfig<SelectVM> initConfig() => ViewConfig.noLoad(vm: SelectVM());

  @override
  Widget vBuild(BuildContext context, SelectVM vm, Widget? child, Widget? state) {
    return Scaffold(
      appBar: AppBar(title: const Text("选择")),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text("是否加载数据,用来测试状态页和重新加载数据"),
            trailing: ValueListenableBuilder<bool>(
              valueListenable: vm.isLoadData,
              builder: (_, value, __) => Switch(
                value: value,
                onChanged: (value) => vm.isLoadData.value = value,
              ),
            ),
          ),
          ListTile(
            title: const Text("是否单独配置状态页,用来测试状态页和重新加载数据"),
            trailing: ValueListenableBuilder<bool>(
              valueListenable: vm.isConfigState,
              builder: (_, value, __) => Switch(
                value: value,
                onChanged: (value) => vm.isConfigState.value = value,
              ),
            ),
          ),
          ListTile(
            title: const Text("根布局刷新"),
            onTap: () => Routers.articlePage(
                true, vm.isConfigState.value, vm.isLoadData.value),
          ),
          ListTile(
            title: const Text("根布局不刷新"),
            onTap: () => Routers.articlePage(
                false, vm.isConfigState.value, vm.isLoadData.value),
          ),
          ListTile(
            title: const Text("新的参数方式"),
            onTap: () => Routers.articlePage(
              true,
              vm.isConfigState.value,
              vm.isLoadData.value,
              isNew: true,
            ),
          ),
          ListTile(
            title: const Text("Navigator的参数方式"),
            onTap: () => Routers.articlePage(
              true,
              vm.isConfigState.value,
              vm.isLoadData.value,
              isNew: true,
              isNavigator: true,
            ),
          ),
          ListTile(
            title: const Text("空页面，不传参数"),
            onTap: () => Routers.emptyPage(),
          ),
          ListTile(
            title: const Text("跳转原生"),
            onTap: () => Routers.jumpNative(),
          ),
        ],
      ),
    );
  }
}
