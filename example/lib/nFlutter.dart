import 'package:fast_mvvm/fast_mvvm.dart';
import 'package:flutter/material.dart';

class NFVM extends BaseViewModel {}

class NFlutter extends StatelessWidget with BaseView {
  const NFlutter({Key? key}) : super(key: key);

  @override
  ViewConfig<BaseViewModel<BaseModel, BaseEntity>> initConfig() =>
      ViewConfig.noLoad(NFVM());

  @override
  Widget vBuild(context, vm, child, state) {
    return const Scaffold(body: Text("这是原生跳转flutter"));
  }
}
