import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jhw/pages/login.dart';
import 'package:jhw/jhw.dart';
import 'package:jhw/pages/home.dart';
import 'package:dio/dio.dart';

Future main() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Widget _page = Login();
  print('auth:${prefs.getStringList("auth")} uid:${prefs.getInt("uid")}');
  if (prefs.getStringList("auth") != null && prefs.getInt("uid") != null) {
    String secret = prefs.getStringList("auth")[1];
    String expire = prefs.getStringList("auth")[2];
    int curSecond = (DateTime.now().millisecondsSinceEpoch) ~/ 1000;
    int uid = prefs.getInt("uid");
    if (curSecond < (int.parse(expire))) {
      Response resp =
          await request('/mall', header: {'authorization': 'JHW $uid:$secret'});
      if (resp != null) {
        print("resp:$resp");
        JHW _lt = new JHW();
        String phone = prefs.getStringList("auth")[0];
        String name = prefs.getStringList("auth")[3];
        _lt.user = new User(uid, name, phone, secret, expire);

        _lt.reset();

        List _mallList = resp.data["mall"];
        _mallList
          ..sort((m1, m2) => m1["id"].compareTo(m2["id"]))
          ..forEach((mall) {
            _lt.mall.add(Mall(mall["id"], mall["name"]));
          });

        List _supplierList = resp.data["supplier"];
        _supplierList
          ..sort((s1, s2) => s1["id"].compareTo(s2["id"]))
          ..forEach((supplier) {
            _lt.supplier.add(Supplier(supplier["id"], supplier["name"]));
          });

        _page = Home();
      }
    }
  }

  runApp(_page);
}
