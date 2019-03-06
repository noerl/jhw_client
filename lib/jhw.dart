import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'util.dart';

const String jhwName = '京华旺';
const String jhwHost = 'http://172.18.45.86:9999';

class User {
  int id;
  String name, phone, secret, expire;
  User(this.id, this.name, this.phone, this.secret, this.expire);
}

class Mall {
  int id;
  String name;
  Mall(this.id, this.name);
}

class Supplier {
  int id;
  String name;
  Supplier(this.id, this.name);
}

class JHW {
  static JHW _jhw;
  JHW._();

  factory JHW() {
    if (_jhw == null) {
      _jhw = new JHW._();
      _jhw.mall.add(Mall(0, "所有门店"));
      _jhw.supplier.add(Supplier(0, "所有供应商"));
    }
    return _jhw;
  }

  void reset() {
    _jhw.mall = [Mall(0, "所有门店")];
    _jhw.supplier = [Supplier(0, "所有供应商")];
  }

  User user;
  List<Mall> mall = [];
  List<Supplier> supplier = [];
  Map<String, State> state = new Map();
}

Future<Response> request(String path,
    {Map<String, dynamic> header, Map body}) async {
  JHW _jhw = new JHW();
  var _dio = new Dio();
  _dio.options.headers =
      header ?? {'authorization': 'JHW ${_jhw.user.id}:${_jhw.user.secret}'};
  _dio.options.baseUrl = jhwHost;
  String _data = aesEncode(json.encode(body));
  Response<dynamic> _resp;
  try {
    _resp = await _dio.post(path, data: _data);
  } catch (e) {
    print("e:$e");
  }
  if (_resp.statusCode == 200) {
    _resp.data = json.decode(aesDecode(_resp.data));
    if (_resp.data["status"] == "ok") {
      return _resp;
    }
  }
  return null;
}

void showMessage(BuildContext context, String text, [String title = '警告']) {
  showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text(text),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('确定'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<DateTime> selectDate(BuildContext context, DateTime dateTime) async {
  DateTime _pickDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2030));
  if (_pickDate != null) {
    return DateTime(_pickDate.year, _pickDate.month, _pickDate.day,
        dateTime.hour, dateTime.minute);
  }
  return dateTime;
}

Future<DateTime> selectTime(BuildContext context, DateTime dateTime) async {
  TimeOfDay _pickTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(dateTime),
  );
  if (_pickTime != null) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, _pickTime.hour,
        _pickTime.minute);
  }
  return dateTime;
}

TextStyle jhwStyle([double fs = 22, FontWeight fw = FontWeight.w300]) =>
    TextStyle(color: Colors.black, fontSize: fs, fontWeight: fw);
