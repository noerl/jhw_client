import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jhw/jhw.dart';
import 'package:jhw/drop_down.dart';
import 'login.dart';

class Purchase extends StatefulWidget {
  @override
  PurchaseState createState() {
    // TODO: implement createState
    return PurchaseState();
  }
}

class PurchaseState extends State<Purchase> {
  DateTime _startTime, _endTime;
  DropDown _mallDropDown = new DropDown();
  DropDown _supplierDropDown = new DropDown();
  JHW _jhw = new JHW();
  int _count = 0;
  double _totalPrice = 0;
  List<Widget> _report = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _jhw.state.addAll({"purchase": this});
    _startTime =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _endTime = _startTime.add(Duration(days: 1));
    _report = [Divider()];
  }

  void updateDropDown() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: ListView(
        children: <Widget>[
          Row(children: <Widget>[
            Expanded(
              flex: 3,
              child: Text("开始时间：${_startTime.toString().substring(0, 16)}"),
            ),
            Expanded(
              flex: 1,
              child: RaisedButton(
                onPressed: () =>
                    selectDate(context, _startTime).then((datetime) {
                      _startTime = datetime;
                      setState(() {});
                    }),
                child: Text("日期"),
              ),
            ),
            Expanded(
              flex: 1,
              child: RaisedButton(
                onPressed: () =>
                    selectTime(context, _startTime).then((datetime) {
                      _startTime = datetime;
                      setState(() {});
                    }),
                child: Text("时间"),
              ),
            ),
          ]),
          Row(children: <Widget>[
            Expanded(
              flex: 3,
              child: Text("结束时间：${_endTime.toString().substring(0, 16)}"),
            ),
            Expanded(
              flex: 1,
              child: RaisedButton(
                onPressed: () => selectDate(context, _endTime).then((datetime) {
                      _endTime = datetime;
                      setState(() {});
                    }),
                child: Text("日期"),
              ),
            ),
            Expanded(
              flex: 1,
              child: RaisedButton(
                onPressed: () => selectTime(context, _endTime).then((datetime) {
                      _endTime = datetime;
                      setState(() {});
                    }),
                child: Text("时间"),
              ),
            ),
          ]),
          _supplierDropDown.dropDown(_jhw.supplier, updateDropDown),
          _mallDropDown.dropDown(_jhw.mall, updateDropDown),
          RaisedButton(
            onPressed: purchaseButton,
            child: Text('查询'),
          ),
          Column(children: _report),
        ],
      ),
      bottomSheet: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              "",
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "全部：$_count",
              style: jhwStyle(),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "合计：￥$_totalPrice",
              style: jhwStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> purchaseButton() async {
    request('/purchase', body: {
      "mid": _jhw.mall.elementAt(_mallDropDown.value).id,
      "sid": _jhw.supplier.elementAt(_supplierDropDown.value).id,
      "startTime": _startTime.millisecondsSinceEpoch,
      "endTime": _endTime.millisecondsSinceEpoch
    }).then((resp) {
      if (resp != null) {
        _count = 0;
        _totalPrice = 0;
        print("resp:$resp");
        _report.clear();
        resp.data["purchase"].forEach((purchase) {
          _totalPrice += purchase["price"] * purchase["count"];
          Mall _mShow = _jhw.mall.firstWhere((_m) => _m.id == purchase["mid"]);
          Supplier _sShow =
              _jhw.supplier.firstWhere((_s) => _s.id == purchase["sid"]);
          _report.add(Card(
              child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(flex: 2, child: Text('商品名：${purchase["name"]}')),
                  Expanded(flex: 1, child: Text('进价：${purchase["price"]}')),
                  Expanded(flex: 1, child: Text('数量：${purchase["count"]}')),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(child: Text('店内码：${purchase["code"]}')),
                  Expanded(child: Text('条码：${purchase["barcode"]}')),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(child: Text('门店：${_mShow.name}')),
                  Expanded(child: Text('供应商：${_sShow.name}')),
                ],
              ),
            ],
          )));
        });
        _count = resp.data["purchase"].length;
        setState(() {});
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Login()),
            (route) => route == null);
      }
    });
  }
}
