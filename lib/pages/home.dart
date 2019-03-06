import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'search.dart';
import 'purchase.dart';
import 'profit.dart';
import 'manage.dart';
import 'package:jhw/jhw.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: HomePage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('zh', 'CH'),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  HomeState createState() {
    // TODO: implement createState
    return HomeState();
  }
}

class HomeState extends State<HomePage> {
  JHW _jhw = new JHW();
  int _index = 0;
  List<Map<String, dynamic>> pageList = [
    {"name": '查询', "page": Search(), "icon": Icon(Icons.search)},
    {"name": '采购', "page": Purchase(), "icon": Icon(Icons.table_chart)},
    {"name": '收益', "page": Profit(), "icon": Icon(Icons.table_chart)},
    {"name": '管理', "page": Manage(), "icon": Icon(Icons.settings)},
  ];

  List<BottomNavigationBarItem> bottom() {
    List<BottomNavigationBarItem> _list = [];
    pageList.forEach((page) {
      _list.add(BottomNavigationBarItem(
          icon: page["icon"], title: Text(page["name"])));
    });
    return _list;
  }

  void loop() {
    request('/update').then((_resp) {
      print("_resp:${_resp.statusCode}");
      loop();
      if (_resp != null && _resp.data["update"].length != 0) {
        Map _data = _resp.data["update"]["data"];
        switch (_resp.data["update"]["cmd"]) {
          case "mallAdd":
            _jhw.mall.add(Mall(_data["id"], _data["name"]));
            _jhw.state["search"].setState(() {});
            _jhw.state["supplier"].setState(() {});
            _jhw.state["profit"].setState(() {});
            break;
          case "mallDel":
            _jhw.mall.removeWhere((_mall) => _mall.id == _data["id"]);
            _jhw.state["search"].setState(() {});
            _jhw.state["supplier"].setState(() {});
            _jhw.state["profit"].setState(() {});
            break;
          case "supplierAdd":
            _jhw.supplier.add(Supplier(_data["id"], _data["name"]));
            _jhw.state["search"].setState(() {});
            _jhw.state["supplier"].setState(() {});
            break;
          case "supplierDel":
            _jhw.supplier
                .removeWhere((_supplier) => _supplier.id == _data["id"]);
            _jhw.state["search"].setState(() {});
            _jhw.state["supplier"].setState(() {});
            break;
        }
      }
    });
  }

  @override
  void initState() {
    print("int:${this.runtimeType}");
    // TODO: implement initState
    super.initState();
    loop();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(pageList[_index]["name"]),
        centerTitle: true,
      ),
      body: pageList[_index]["page"],
      bottomNavigationBar: BottomNavigationBar(
        items: bottom(),
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          _index = index;

          setState(() {});
        },
      ),
    );
  }
}
