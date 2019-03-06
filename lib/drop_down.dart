import 'package:flutter/material.dart';
import 'package:jhw/jhw.dart';

class DropDown {
  int value = 0;
  DropdownButtonHideUnderline dropDown(List list, Function fun) {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        hint: Text(list[value].name, style: jhwStyle()),
        value: value,
        items: itemList(list),
        onChanged: (T) {
          value = T;
          fun();
        },
      ),
    );
  }

  List<DropdownMenuItem> itemList(List _list) {
    List<DropdownMenuItem> _items = [];

    for (int i = 0; i < _list.length; i++) {
      _items.add(DropdownMenuItem(
        child: Text(_list[i].name, style: jhwStyle()),
        value: i,
      ));
    }
    return _items;
  }
}
