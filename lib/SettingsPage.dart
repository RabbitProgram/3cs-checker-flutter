//設定タブ
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Utils.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: () {
            LaunchURL("https://rabbitprogram.com/");
          },
          child: Text('公式ホームページを開く'),
        ),
      ],
    );
  }
}
