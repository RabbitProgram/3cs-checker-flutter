//Dashboardタブ

import 'dart:async';
import 'dart:ui';

import 'package:background_locator/background_locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'QuickCheck.dart';
import 'Utils.dart';
import 'Variables.dart';
import 'main.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            child: Text('今すぐ測定'),
            color: Colors.orange,
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuickCheck(),
                ),
              );
            },
          ),
          ElevatedButton(
            child: const Text('サンプルログ書き込み'),
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              onPrimary: Colors.white,
            ),
            onPressed: () async {
              DateTime now = DateTime.now();
              String date = Date_to_String(now, "yyyy/MM/dd HH:mm:ss");

              String text = "保存：" + date;
              TextFileSave("test.txt", text);
              print("保存完了");
            },
          ),
          ElevatedButton(
            child: const Text('サンプルログ読み込み'),
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              onPrimary: Colors.white,
            ),
            onPressed: () {
              TextFileLoad("test.txt").then((String value) {
                showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: Text("結果"),
                      content: Text(value),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("OK"),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    );
                  },
                );
              });
            },
          ),
          ElevatedButton(
            child: const Text("バックグラウンド測定履歴を確認"),
            style: ElevatedButton.styleFrom(
              primary: Colors.green,
              onPrimary: Colors.white,
            ),
            onPressed: () async {
              String value = "";
              try {
                value = await TextFileLoad("backlog.txt");
              } catch (e) {}

              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: Text("結果"),
                    content: Text(value),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("クリア"),
                        onPressed: () async {
                          TextFileSave("backlog.txt", "");
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text("コピー"),
                        onPressed: () async {
                          final data = ClipboardData(text: value);
                          await Clipboard.setData(data);
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text("OK"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ElevatedButton(
            child: Text(locationFlag ? "停止" : "開始"),
            style: ElevatedButton.styleFrom(
              primary: locationFlag ? Colors.red : Colors.blue,
              onPrimary: Colors.white,
            ),
            onPressed: () {
              if (locationFlag == false) {
                //開始
                print("バックグラウンド測定を開始します");
                //startLocationService();  before！！

                //指定距離移動検知の動作用
                IsolateNameServer.registerPortWithName(
                    port.sendPort, isolateName);
                port.listen((dynamic data) {
                  // do something with data
                  print("受信：" + data.toString());
                });

                //↓このやり方でもバックグラウンド状態ではBluetooth測定不可！（2021/08/16検証）
                //timer　ここから
                bool working = false;
                FlutterBlue flutterBlue = FlutterBlue.instance;
                Timer timerObj;
                timerObj = Timer.periodic(Duration(seconds: 5), (timer) async {
                  if (working == false) {
                    working = true;
                    print("-------------------------------------");
                    print("定期処理テスト　" + DateTime.now().toString());

                    int missyuuCount = 0, missetuCount = 0, deviceCount = 0;
                    flutterBlue.scanResults.listen((results) {
                      missyuuCount = 0; //変数は毎回初期化する
                      missetuCount = 0;

                      for (ScanResult r in results) {
                        //print("${r.device.name} found!　rssi: ${r.rssi}" +"　id: " +r.device.id.toString());

                        if (r.rssi >= border_missetu_rssi) {
                          //密接
                          missetuCount++;
                        } else {
                          //密接
                          missyuuCount++;
                        }
                      }
                      deviceCount = results.length;
                    });
                    await flutterBlue.startScan(
                        timeout: Duration(
                            seconds: 5)); //終了したら下の動作を続ける（「await」で終了まで待機）

                    print("【測定結果】　デバイス数合計：" +
                        deviceCount.toString() +
                        "　密集：" +
                        missyuuCount.toString() +
                        "　密接：" +
                        missetuCount.toString());

                    flutterBlue.stopScan();
                    working = false;
                  }
                });
                //timer　ここまで

              } else {
                //停止
                print("バックグラウンド測定を停止します");
                IsolateNameServer.removePortNameMapping(isolateName);
                BackgroundLocator.unRegisterLocationUpdate();
              }

              setState(() {
                locationFlag = !locationFlag;
              });
            },
          ),
        ],
      ),
    );
  }

  //DateTime型→String型　変換
  //format　yyyy：年　MM：月　dd：日　HH：時間　mm：分　ss：秒
  String Date_to_String(DateTime dt, String format) {
    String result = format;
    result = result.replaceAll("yyyy", dt.year.toString().padLeft(4, "0"));
    result = result.replaceAll("MM", dt.month.toString().padLeft(2, "0"));
    result = result.replaceAll("dd", dt.day.toString().padLeft(2, "0"));
    result = result.replaceAll("HH", dt.hour.toString().padLeft(2, "0"));
    result = result.replaceAll("mm", dt.minute.toString().padLeft(2, "0"));
    result = result.replaceAll("ss", dt.second.toString().padLeft(2, "0"));

    return result;
  }
}
