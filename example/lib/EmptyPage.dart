import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EmptyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("空白页面，不需要参数")),
      body: Center(child: Text("空白页面，不需要参数")),
    );
  }
}
