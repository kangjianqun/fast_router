import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("空白页面，不需要参数")),
      body: const Center(child: Text("空白页面，不需要参数")),
    );
  }
}
