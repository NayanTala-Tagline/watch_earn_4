import 'package:flutter/cupertino.dart';

class WithdrawCategory {
  final String title;
  final String dbTitle;
  final List<WithdrawItem> items;

  WithdrawCategory({required this.title, required this.dbTitle, required this.items});
}

class WithdrawItem {
  final String title;
  final String dbTitle;
  final Widget icon;
  final Color color;
  final FormData formData;

  WithdrawItem(this.title, this.dbTitle, this.icon, this.color, this.formData);
}

class FormData {
  final String title;
  final Widget icon;
  final String regex;

  FormData(this.title, this.icon, this.regex);
}
