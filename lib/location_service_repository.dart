import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:background_locator/location_dto.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'Utils.dart';
import 'Variables.dart';

class LocationServiceRepository {
  static LocationServiceRepository _instance = LocationServiceRepository._();

  LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;
  }

  static const String isolateName = 'LocatorIsolate';
  int _count = -1;
  FlutterBlue flutterBlue = FlutterBlue.instance;

  Future<void> init(Map<dynamic, dynamic> params) async {
    //バックグラウンドサービス開始時
    //print("***********Init callback handler");
    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      } else if (tmpCount is String) {
        _count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        _count = tmpCount;
      } else {
        _count = -2;
      }
    } else {
      _count = 0;
    }
    //print("$_count");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> dispose() async {
    //バックグラウンドサービス終了時

    //print("***********Dispose callback handler");
    //print("$_count");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  bool working = false; //実行中の場合はtrue

  Future<void> callback(LocationDto locationDto) async {
    //既に実行中の場合はスキップする（二重実行防止）
    if (working == false) {
      working = true;
      //print('location in dart: ${locationDto.toString()}');

      print("--------------------------------------");
      print("バックグラウンドの測定を開始します");
      int missyuuCount = 0, missetuCount = 0, deviceCount = 0;
      //Bluetoothチェック
      /*final MethodChannel _channel = const MethodChannel('$NAMESPACE/methods');
      /*Future setUniqueId(String uniqueid) =>
          _channel.invokeMethod('setUniqueId', uniqueid.toString());*/
      _channel.invokeMethod(
          'setUniqueId', "wkjfenwnfkhwriofgwfjw" + DateTime.now().toString());*/
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
          timeout: Duration(seconds: 5)); //終了したら下の動作を続ける（「await」で終了まで待機）

      print("【指定距離移動検知後の測定結果】　デバイス数合計：" +
          deviceCount.toString() +
          "　密集：" +
          missyuuCount.toString() +
          "　密接：" +
          missetuCount.toString());

      flutterBlue.stopScan();

      //ここに位置情報の変更を検知したときに処理するプログラムを書く
      print("ido,keido: " +
          locationDto.latitude.toString() +
          "," +
          locationDto.longitude.toString() +
          " speed: " +
          locationDto.speed.toString());

      //ログファイルに追記
      String text = "";
      try {
        text = await TextFileLoad("backlog.txt");
      } catch (e) {}

      DateTime now = DateTime.now();
      String date = Date_to_String(now, "yyyy/MM/dd,HH:mm:ss");
      text = text +
          "\n" +
          date +
          "," +
          locationDto.latitude.toString() +
          "," +
          locationDto.longitude.toString() +
          "," +
          locationDto.speed.toString() +
          "m/s";
      TextFileSave("backlog.txt", text);
      print("保存完了");

      final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
      send?.send("精度送信テスト" + locationDto.accuracy.toString());
      _count++;
      working = false; //次の測定を可能にする
    }
  }

  static double dp(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  static String formatDateLog(DateTime date) {
    return date.hour.toString() +
        ":" +
        date.minute.toString() +
        ":" +
        date.second.toString();
  }

  static String formatLog(LocationDto locationDto) {
    return dp(locationDto.latitude, 4).toString() +
        " " +
        dp(locationDto.longitude, 4).toString();
  }
}
