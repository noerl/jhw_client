import 'dart:async';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:jhw/jhw.dart';
import 'package:jhw/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: LoginPage(),
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

class LoginPage extends StatefulWidget {
  @override
  LoginState createState() {
    // TODO: implement createState
    return LoginState();
  }
}

class LoginState extends State<LoginPage> {
  String _phone = '', _pwd = '';
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(jhwName),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 80,
            ),
            TextField(
              style: jhwStyle(),
              maxLength: 11,
              controller: TextEditingController(text: _phone),
              decoration: InputDecoration(
                icon: Text('帐号', style: jhwStyle()),
                contentPadding: EdgeInsets.all(1),
              ),
              onChanged: (str) {
                _phone = str;
              },
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              style: jhwStyle(),
              maxLength: 16,
              obscureText: true,
              controller: TextEditingController(text: _pwd),
              decoration: InputDecoration(
                icon: Text('密码', style: jhwStyle()),
                contentPadding: EdgeInsets.all(1),
              ),
              onChanged: (str) {
                _pwd = str;
              },
            ),
            SizedBox(
              height: 10,
            ),
            RaisedButton(
                onPressed: loginButton,
                child: Text(
                  "登陆",
                  style: jhwStyle(),
                ))
          ],
        ),
      ),
    );
  }

  Future<void> loginButton() async {
    if (_phone.length == 11 && _pwd.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      int _uuid = Random().nextInt(899999) + 100000;

      Map _data = {
        "phone": _phone,
        "pwd": md5.convert(_pwd.codeUnits).toString()
      };
      request('/login', header: {"uuid": _uuid}, body: _data).then((resp) {
        if (resp != null) {
          print("resp:${resp.data}");
          prefs.setStringList("auth", [
            _phone,
            resp.headers.value("jhw"),
            resp.headers.value("expire"),
            resp.data["userInfo"]["name"],
          ]);
          prefs.setInt("uid", resp.data["userInfo"]["id"]);
          JHW _jhw = new JHW();

          _jhw.user = User(
              resp.data["userInfo"]["id"],
              resp.data["userInfo"]["name"],
              _phone,
              resp.headers.value("jhw"),
              resp.headers.value("expire"));

          _jhw.reset();

          List _mallList = resp.data["mall"];
          _mallList
            ..sort((m1, m2) => m1["id"].compareTo(m2["id"]))
            ..forEach((mall) {
              _jhw.mall.add(Mall(mall["id"], mall["name"]));
            });

          List _supplierList = resp.data["supplier"];
          _supplierList
            ..sort((s1, s2) => s1["id"].compareTo(s2["id"]))
            ..forEach((supplier) {
              _jhw.supplier.add(Supplier(supplier["id"], supplier["name"]));
            });

          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) {
            return HomePage();
          }), (route) => route == null);
        } else {
          showMessage(context, '账号密码错误');
        }
      });
    } else {
      showMessage(context, '账号密码错误');
    }
  }
}
