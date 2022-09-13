import 'package:fast_router/fast_router.dart';
import 'package:flutter/material.dart';

import 'routers.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            FastRouter.popBack();
            Routers.jumpNative();
          },
          child: const Icon(Icons.chevron_left),
        ),
        title: const Text("空白页面，不需要参数"),
      ),
      body: const Center(child: Text("空白页面，不需要参数")),
    );
  }
}
