import 'package:flutter/widgets.dart';
import 'common.dart';

/// 节点类型
enum RouteTreeNodeType {
  component,
  parameter,
}

/// 路由树节点
class RouteTreeNode {
  RouteTreeNode(this.part, this.type);

  String part;

  ///当前节点类型
  RouteTreeNodeType type;
  List<AppRoute> routes = <AppRoute>[];

  /// 孩子 组成部分
  List<RouteTreeNode> nodes = <RouteTreeNode>[];
  RouteTreeNode parent;

  bool isParameter() => type == RouteTreeNodeType.parameter;
}

/// 应用程序路线匹配
class AppRouteMatch {
  AppRouteMatch(this.route);

  AppRoute route;

  /// 参数
  Map<String, List<String>> parameters = <String, List<String>>{};
}

/// 路由树节点匹配
class RouteTreeNodeMatch {
  RouteTreeNodeMatch(this.node);

  RouteTreeNode node;
  Map<String, List<String>> parameters = <String, List<String>>{};

  /// 来自匹配
  RouteTreeNodeMatch.fromMatch(RouteTreeNodeMatch match, this.node) {
    parameters = <String, List<String>>{};
    if (match != null) {
      parameters.addAll(match.parameters);
    }
  }
}

/// 路由树
class RouteTree {
  /// 路由书节点列表
  final List<RouteTreeNode> _nodes = <RouteTreeNode>[];

  /// 内部一致性
  bool _hasDefaultRoute = false;

  ///  将路由添加到路由树
  void addRoute(AppRoute route) {
    String path = route.route;

    /// 是根或默认路由，只需添加
    if (path == Navigator.defaultRouteName) {
      if (_hasDefaultRoute) {
        /// 引发错误，影响路由器的内部一致性
        throw ("Default route was already defined");
      }

      /// 创建节点
      var node = RouteTreeNode(path, RouteTreeNodeType.component);
      node.routes = [route];
      _nodes.add(node);
      _hasDefaultRoute = true;
      return;
    }

    /// 非根路由 解析路径 判断是否是路径组成成分
    if (path.startsWith("/")) {
      path = path.substring(1);
    }

    List<String> pathComponents = path.split('/');
    RouteTreeNode parent;

    /// 循环组成部分
    for (int i = 0; i < pathComponents.length; i++) {
      String component = pathComponents[i];

      RouteTreeNode node = _nodeForComponent(component, parent);

      if (node == null) {
        /// 得到节点的类型
        RouteTreeNodeType type = _typeForComponent(component);

        /// 创建节点
        node = RouteTreeNode(component, type);

        /// 添加父母
        node.parent = parent;

        /// 添加孩子
        if (parent == null) {
          _nodes.add(node);
        } else {
          parent.nodes.add(node);
        }
      }

      /// 结束生成路径 插入树
      if (i == pathComponents.length - 1) {
        if (node.routes == null) {
          node.routes = [route];
        } else {
          node.routes.add(route);
        }
      }
      parent = node;
    }
  }

  /// 匹配路由
  AppRouteMatch matchRoute(String path) {
    String usePath = path;
    if (usePath.startsWith("/")) {
      usePath = path.substring(1);
    }

    /// 解析路径
    List<String> components = usePath.split("/");
    if (path == Navigator.defaultRouteName) {
      components = ["/"];
    }

    Map<RouteTreeNode, RouteTreeNodeMatch> nodeMatches =
        <RouteTreeNode, RouteTreeNodeMatch>{};

    List<RouteTreeNode> nodesToCheck = _nodes;

    /// 循环片段
    for (String checkComponent in components) {
      Map<RouteTreeNode, RouteTreeNodeMatch> currentMatches =
          <RouteTreeNode, RouteTreeNodeMatch>{};

      List<RouteTreeNode> nextNodes = <RouteTreeNode>[];

      /// 循环要检查的节点
      for (RouteTreeNode node in nodesToCheck) {
        String pathPart = checkComponent;
        Map<String, List<String>> queryMap;

        /// 发现路径带有参数
        if (checkComponent.contains("?")) {
          /// 分割路径中  路径跟参数
          var splitParam = checkComponent.split("?");
          pathPart = splitParam[0];

          /// 处理参数
          queryMap = parseQueryString(splitParam[1]);
        }

        /// 是否匹配到路径
        bool isMatch = (node.part == pathPart || node.isParameter());
        if (isMatch) {
          RouteTreeNodeMatch parentMatch = nodeMatches[node.parent];
          RouteTreeNodeMatch match =
              RouteTreeNodeMatch.fromMatch(parentMatch, node);
          if (node.isParameter()) {
            String paramKey = node.part.substring(1);
            match.parameters[paramKey] = [pathPart];
          }
          if (queryMap != null) {
            match.parameters.addAll(queryMap);
          }
//          print("matched: ${node.part}, isParam: ${node.isParameter()}, params: ${match.parameters}");
          currentMatches[node] = match;
          if (node.nodes != null) {
            nextNodes.addAll(node.nodes);
          }
        }
      }
      nodeMatches = currentMatches;
      nodesToCheck = nextNodes;
      if (currentMatches.values.length == 0) {
        return null;
      }
    }

    List<RouteTreeNodeMatch> matches = nodeMatches.values.toList();
    if (matches.length > 0) {
      RouteTreeNodeMatch match = matches.first;
      RouteTreeNode nodeToUse = match.node;
//			print("using match: ${match}, ${nodeToUse?.part}, ${match?.parameters}");
      if (nodeToUse != null &&
          nodeToUse.routes != null &&
          nodeToUse.routes.length > 0) {
        List<AppRoute> routes = nodeToUse.routes;
        AppRouteMatch routeMatch = AppRouteMatch(routes[0]);
        routeMatch.parameters = match.parameters;
        return routeMatch;
      }
    }
    return null;
  }

  void printTree() => _printSubTree();

  void _printSubTree({RouteTreeNode parent, int level = 0}) {
    List<RouteTreeNode> nodes = parent != null ? parent.nodes : _nodes;
    for (RouteTreeNode node in nodes) {
      String indent = "";
      for (int i = 0; i < level; i++) {
        indent += "    ";
      }
      print("$indent${node.part}: total routes=${node.routes.length}");
      if (node.nodes != null && node.nodes.length > 0) {
        _printSubTree(parent: node, level: level + 1);
      }
    }
  }

  /// 获取节点
  RouteTreeNode _nodeForComponent(String component, RouteTreeNode parent) {
    List<RouteTreeNode> nodes = _nodes;
    if (parent != null) {
      /// 在父节点中搜索子节点匹配项
      nodes = parent.nodes;
    }
    for (RouteTreeNode node in nodes) {
      if (node.part == component) {
        return node;
      }
    }
    return null;
  }

  /// 判断是否为参数
  RouteTreeNodeType _typeForComponent(String component) {
    RouteTreeNodeType type = RouteTreeNodeType.component;
    if (_isParameterComponent(component)) {
      type = RouteTreeNodeType.parameter;
    }
    return type;
  }

  /// 路径组件是参数
  bool _isParameterComponent(String component) {
    return component.startsWith(":");
  }

  /// 解析查询字符串 取出参数
  Map<String, List<String>> parseQueryString(String query) {
    var search = RegExp('([^&=]+)=?([^&]*)');
    var params = Map<String, List<String>>();
    if (query.startsWith('?')) query = query.substring(1);

    ///
    decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));

    for (Match match in search.allMatches(query)) {
      String key = decode(match.group(1));
      String value = decode(match.group(2));
      if (params.containsKey(key)) {
        params[key].add(value);
      } else {
        params[key] = [value];
      }
    }
    return params;
  }
}
