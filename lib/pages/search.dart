import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jhw/jhw.dart';
import 'package:jhw/drop_down.dart';
import 'login.dart';

class Search extends StatefulWidget {
  @override
  SearchState createState() {
    // TODO: implement createState
    return SearchState();
  }
}

class SearchState extends State<Search> {
  DropDown _mallDropDown = new DropDown();
  DropDown _supplierDropDown = new DropDown();

  JHW _jhw = new JHW();
  String _search = '';
  List<Widget> _stockList = [];
  List<dynamic> _searchResp = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _jhw.state.addAll({"search": this});
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
            _supplierDropDown.dropDown(_jhw.supplier, updateDropDown),
            _mallDropDown.dropDown(_jhw.mall, updateDropDown),
            TextField(
              style: jhwStyle(32),
              controller: TextEditingController(text: _search),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 2),
                suffixIcon: IconButton(
                  iconSize: 32,
                  icon: Icon(Icons.search),
                  onPressed: searchButton,
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: (str) {
                _search = str;
              },
            ),
            Column(children: _stockList),
          ],
        ));
  }

  Future searchButton() async {
    if (_search.isNotEmpty) {
      request('/search', body: {
        "mid": _jhw.mall[_mallDropDown.value].id,
        "sid": _jhw.supplier[_supplierDropDown.value].id,
        "msg": _search
      }).then((resp) {
        if (resp != null) {
          _searchResp = resp.data["stock"];
          searchResult();
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Login()),
              (route) => route == null);
        }
      });
    } else {
      showMessage(context, "查询数据不能为空");
    }
  }

  void searchResult() {
    List<dynamic> _tmpList = [];
    _stockList.clear();
    for (int i = 0; i < _searchResp.length; i++) {
      Map stock = _searchResp[i];
      String _mallName = getName(_jhw.mall, stock["mid"]);
      String _supplierName = getName(_jhw.supplier, stock["sid"]);
      DropDown _supplierDropDownNew = stock["dropdown"] ?? new DropDown();
      stock["dropdown"] = _supplierDropDownNew;

      _stockList.add(Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.lightBlue, width: 2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('条形码：${stock["barcode"]}'),
            Text('商品名：${stock["name"]}'),
            Text('门店名：$_mallName'),
            Text('供应商：$_supplierName'),
            Row(
              children: <Widget>[
                Expanded(flex: 2, child: Text('店内码：${stock["code"]}')),
                Expanded(flex: 1, child: Text('库存量：${stock["count"]}')),
                Expanded(flex: 1, child: Text('售价：${stock["sellPrice"]}')),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(
                    '进价：${stock["buyPrice"]}',
                    style: jhwStyle(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: RaisedButton(
                    onPressed: () => priceButton(stock["code"]),
                    child: Text('历史价'),
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller:
                        TextEditingController(text: stock["inputcount"]),
                    decoration: InputDecoration(
                        icon: Text(
                      '采购量',
                      style: jhwStyle(),
                    )),
                    onChanged: ((str) {
                      stock["inputcount"] = str;
                    }),
                  ),
                ),
                Expanded(flex: 1, child: Text('')),
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller:
                        TextEditingController(text: stock["inputprice"]),
                    decoration: InputDecoration(
                        icon: Text(
                      '采购价',
                      style: jhwStyle(),
                    )),
                    onChanged: ((str) {
                      stock["inputprice"] = str;
                    }),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                    flex: 5,
                    child: _supplierDropDownNew.dropDown(
                        _jhw.supplier, searchResult)),
                Expanded(
                  flex: 1,
                  child: RaisedButton(
                    color: Colors.red,
                    child: Text('采购'),
                    padding: EdgeInsets.all(1),
                    onPressed: () => purchaseButton(
                        i,
                        stock["mid"],
                        stock["code"],
                        double.parse(stock["inputprice"]),
                        int.parse(stock["inputcount"]),
                        _jhw.supplier.elementAt(_supplierDropDownNew.value).id),
                  ),
                ),
              ],
            ),
          ],
        ),
      ));

      _tmpList.add(stock);
    }

    _searchResp = _tmpList;
    setState(() {});
  }

  String getName(List list, int id) {
    if (id != 0) {
      try {
        return list.firstWhere((T) => T.id == id).name;
      } catch (e) {
        print("error:$e");
        return "";
      }
    }
    return "";
  }

  Future<void> purchaseButton(int index, int mid, String code, double buyPrice,
      int count, int sid) async {
    bool isReq = purchaseCheck(buyPrice, count, sid);
    if (isReq) {
      Map _data = {
        "mid": mid,
        "code": code,
        "buyPrice": buyPrice,
        "count": count,
        "sid": sid
      };
      print("map body:$_data");
      request('/stock/update', body: _data).then((resp) {
        if (resp != null) {
          Map _stock = _searchResp.elementAt(index);
          _stock["count"] = resp.data["stock"]["count"];
          _stock["buyPrice"] = resp.data["stock"]["price"];
          _stock["inputprice"] = '';
          _stock["inputcount"] = '';
          _searchResp.replaceRange(index, index + 1, [_stock]);
          searchResult();
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Login()),
              (route) => route == null);
        }
      });
    }
  }

  bool purchaseCheck(double buyPrice, int count, int sid) {
    if (buyPrice > 0) {
      if (count > 0) {
        if (sid > 0) {
          return true;
        } else {
          showMessage(context, '请选择供应商');
        }
      } else {
        showMessage(context, '请正确填写采购数量');
      }
    } else {
      showMessage(context, '请正确填写采购价格');
    }
    return false;
  }

  Future<void> priceButton(String code) async {
    request('/price', body: {"code": code}).then((resp) {
      if (resp != null) {
        String _strShow = '';
        resp.data["priceLog"].forEach((priceInfo) {
          Supplier _sShow =
              _jhw.supplier.firstWhere((_s) => _s.id == priceInfo["sid"]);
          _strShow += '价格:${priceInfo["price"]}\n'
              '供应商:${_sShow.name}\n'
              '时间:${DateTime.fromMillisecondsSinceEpoch(priceInfo["time"] * 1000).toString()}\n\n';
        });
        showMessage(context, _strShow, '历史价');
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Login()),
            (route) => route == null);
      }
    });
  }
}
