import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jhw/jhw.dart';
import 'package:jhw/drop_down.dart';
import 'login.dart';

//class Manage extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return MaterialApp(
//      home: ManagePage(),
//    );
//  }
//}

class Manage extends StatefulWidget {
  @override
  ManageState createState() {
    // TODO: implement createState
    return ManageState();
  }
}

class ManageState extends State<Manage> {
  String _captcha = '', _mall = '', _supplier = '';
  DropDown _mallDropDown = new DropDown();
  DropDown _supplierDropDown = new DropDown();
  JHW lt = new JHW();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    request('/captcha').then((resp) {
      if (resp != null) {
        _captcha = resp.data['captcha'];
        setState(() {});
      }
    });
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
          Card(
            child: Container(
              alignment: Alignment.center,
              height: 40,
              child: Text(
                "动态码：" + _captcha,
                style: jhwStyle(),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 24,
                child: TextField(
                  style: jhwStyle(),
                  controller: TextEditingController(text: _mall),
                  decoration: InputDecoration(
                    icon: Text('门店', style: jhwStyle()),
                    contentPadding: EdgeInsets.all(1),
                  ),
                  onChanged: (str) {
                    _mall = str;
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              Expanded(
                flex: 5,
                child: RaisedButton(
                  padding: EdgeInsets.all(1),
                  child: Text('添加'),
                  onPressed: addMallButton,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 24,
                child: _mallDropDown.dropDown(lt.mall, updateDropDown),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              Expanded(
                flex: 5,
                child: RaisedButton(
                  padding: EdgeInsets.all(1),
                  child: Text('删除'),
                  onPressed: delMallButton,
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 24,
                child: TextField(
                  style: jhwStyle(),
                  controller: TextEditingController(text: _supplier),
                  decoration: InputDecoration(
                    icon: Text('供应商', style: jhwStyle()),
                    contentPadding: EdgeInsets.all(1),
                  ),
                  onChanged: (str) {
                    _supplier = str;
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              Expanded(
                flex: 5,
                child: RaisedButton(
                  padding: EdgeInsets.all(1),
                  child: Text('添加'),
                  onPressed: addSupplierButton,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 24,
                child: _supplierDropDown.dropDown(lt.supplier, updateDropDown),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              Expanded(
                flex: 5,
                child: RaisedButton(
                  padding: EdgeInsets.all(1),
                  child: Text('删除'),
                  onPressed: delSupplierButton,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> addMallButton() async {
    request('/mall/add', body: {"name": _mall}).then((resp) {
      if (resp != null) {
        _mall = '';
        lt.mall.add(
            Mall(resp.data["mallAdd"]["id"], resp.data["mallAdd"]["name"]));
        setState(() {});
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Login()),
            (route) => route == null);
      }
    });
  }

  Future<void> delMallButton() async {
    if (_mallDropDown.value != 0) {
      request('/mall/del',
          body: {"id": lt.mall.elementAt(_mallDropDown.value).id}).then((resp) {
        if (resp != null) {
          lt.mall.removeAt(_mallDropDown.value);
          _mallDropDown.value = 0;
          setState(() {});
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Login()),
              (route) => route == null);
        }
      });
    } else {
      showMessage(context, "不能删除");
    }
  }

  Future<void> addSupplierButton() async {
    request('/supplier/add', body: {"name": _supplier}).then((resp) {
      if (resp != null) {
        lt.supplier.add(Supplier(
            resp.data["supplierAdd"]["id"], resp.data["supplierAdd"]["name"]));
        _supplier = '';
        setState(() {});
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Login()),
            (route) => route == null);
      }
    });
  }

  Future<void> delSupplierButton() async {
    if (_supplierDropDown.value != 0) {
      request('/supplier/del',
              body: {"id": lt.supplier.elementAt(_supplierDropDown.value).id})
          .then((resp) {
        if (resp != null) {
          lt.supplier.removeAt(_supplierDropDown.value);
          _supplierDropDown.value = 0;
          setState(() {});
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Login()),
              (route) => route == null);
        }
      });
    } else {
      showMessage(context, "不能删除");
    }
  }
}
