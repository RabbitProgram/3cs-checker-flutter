import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'Utils.dart';
import 'Variables.dart';
import 'main.dart';

class QuickCheck extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _QuickCheck();
  }
}

class _QuickCheck extends State<QuickCheck> with TickerProviderStateMixin {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  late Position position; // Geolocator
  double ido = -1.0, keido = -1.0, speed = -1.0, accuracy = -1.0;
  int deviceCount = 0; //テスト用（合計端末数）
  int missyuuCount = 0, missetuCount = 0; //Bluetoothで調べた端末数
  String _titleText = "お待ちください";
  String _subTitleText = "現在の空間状態をチェックしています";
  String _addressText = "測定場所：位置情報を取得中です…";
  String _checkText1 = "屋内か屋外かを判定中…";
  String _checkText2 = "集中デバイス数を測定中…";
  String _checkText3 = "近接デバイス数を測定中…";
  late AnimationController _rotate1Controller;
  late AnimationController _rotate2Controller;
  late AnimationController _rotate3Controller;
  IconData _icon1 = Icons.autorenew;
  IconData _icon2 = Icons.autorenew;
  IconData _icon3 = Icons.autorenew;
  Color _iconColor1 = Colors.black87;
  Color _iconColor2 = Colors.black87;
  Color _iconColor3 = Colors.black87;
  String _cancelButtonText = "キャンセル";
  ButtonStyle _shareButtonStyle = NormalButton(false);
  String _shareDialogSelect = "";
  bool _isChecking = false;
  List<String> addressList = []; //住所表示用
  int mituCount = 0;

  //起動時に実行する処理
  @override
  void initState() {
    super.initState();

    _rotate1Controller = AnimationController(
      duration: const Duration(milliseconds: 1500), //1.5秒で1回転
      vsync: this,
    );
    _rotate2Controller = AnimationController(
      duration: const Duration(milliseconds: 1500), //1.5秒で1回転
      vsync: this,
    );
    _rotate3Controller = AnimationController(
      duration: const Duration(milliseconds: 1500), //1.5秒で1回転
      vsync: this,
    );

    _determinePosition(); //権限チェック
    ViewSet(mounted); //変数を表示に適用

    //3密チェック
    ThreecsCheck();
  }

  Future<void> ThreecsCheck() async {
    //ボタンを押したときのプログラム
    _isChecking = true;
    _rotate1Controller.repeat(); //回転アニメーションを開始（止めるまでずっと）
    _rotate2Controller.repeat();
    _rotate3Controller.repeat();

    /*
    //表示を反映
    setState(() {
    });*/

    List<Future<void>> futureList = [];

    _determinePosition(); //権限チェック

    //GPSチェック
    futureList.add(CheckGPS());

    //Bluetoothチェック
    futureList.add(CheckBluetooth());

    //すべてのチェックが終了するまで待機
    Future.wait(futureList).then((value) {
      //すべて完了したときの処理
      switch (mituCount) {
        case 0:
          _titleText = "安全な場所です";
          _subTitleText = "趣味の時間に充てるなど、\nおうち時間を有意義に過ごしてみましょう。";
          break;
        case 1:
          _titleText = "注意が必要です！";
          _subTitleText = "外出時はマスクを着用し、\n手指消毒をこまめに行いましょう。";
          break;
        case 2:
          _titleText = "注意が必要です！";
          _subTitleText = "感染リスクを抑えるため、\n列に並ぶ際は間隔を開けましょう。";
          break;
        case 3:
          _titleText = "危険です！";
          _subTitleText = "感染リスクが非常に高い場所です。\n長時間滞在しないようにしてください。";
          break;
      }

      _shareButtonStyle = NormalButton(true);
      _cancelButtonText = "閉じる";
      ViewSet(mounted); //表示を反映

      _isChecking = false;
      ViewSet(mounted); //表示を反映
    });
  }

  //Bluetoothでデバイス数を取得
  Future<void> CheckBluetooth() async {
    //Bluetoothチェック
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

      _checkText2 = "集中デバイス数を測定中…\n検出デバイス数：" + missyuuCount.toString();
      _checkText3 = "近接デバイス数を測定中…\n検出デバイス数：" + missetuCount.toString();
      ViewSet(mounted); //変数を表示に適用
    });
    await flutterBlue.startScan(
        timeout: Duration(seconds: 5)); //終了したら下の動作を続ける（「await」で終了まで待機）

    print("デバイス数合計：" +
        deviceCount.toString() +
        "　密集：" +
        missyuuCount.toString() +
        "　密接：" +
        missetuCount.toString());

    flutterBlue.stopScan();

    _rotate2Controller.reset(); //回転アニメーションを停止
    _rotate3Controller.reset(); //回転アニメーションを停止

    if (missyuuCount >= border_missyuu) {
      //集中状態
      mituCount++;
      _checkText2 = "人が集中しています！！\n検出デバイス数：" + missyuuCount.toString();
      _icon2 = Icons.warning;
      _iconColor2 = Colors.pinkAccent.shade400;
    } else {
      //集中状態ではない
      _checkText2 = "集中状態ではありません\n検出デバイス数：" + missyuuCount.toString();
      _icon2 = Icons.check_circle;
      _iconColor2 = Colors.lightGreenAccent.shade700;
    }

    if (missetuCount >= border_missetu) {
      //近接状態
      mituCount++;
      _checkText3 = "近くに人が大勢います！！\n検出デバイス数：" + missetuCount.toString();
      _icon3 = Icons.warning;
      _iconColor3 = Colors.pinkAccent.shade400;
    } else {
      //近接状態ではない
      _checkText3 = "近接状態ではありません\n検出デバイス数：" + missetuCount.toString();
      _icon3 = Icons.check_circle;
      _iconColor3 = Colors.lightGreenAccent.shade700;
    }

    ViewSet(mounted); //表示を反映
  }

  //GPSで現在地・移動速度を取得
  Future<void> CheckGPS() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 5)); //現在地取得（5秒間）
      print("1回目の精度：" + position.accuracy.toString());

      await Future.delayed(Duration(seconds: 1)); //少し待機

      //もう一度取得（accuracyを正しく測定するため）
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 5));
      print("2回目の精度：" + position.accuracy.toString());

      ido = position.latitude;
      keido = position.longitude;
      if (position.speed > 0) {
        speed = position.speed * 3.6;
      } else {
        speed = 0.0;
      }
      accuracy = position.accuracy;

      List<Placemark> placemarks = await placemarkFromCoordinates(ido, keido);
      addressList.add(placemarks[0].administrativeArea.toString()); //都道府県
      addressList
          .add(addressList[0] + placemarks[0].locality.toString()); //市区町村まで
      addressList.add(
          addressList[1] + placemarks[0].subLocality.toString()); //番地以外の部分まで
      addressList.add(addressList[1] +
          placemarks[0].thoroughfare.toString() +
          placemarks[0].subThoroughfare.toString()); //完全（番地まで）
      _addressText = "測定場所：" + addressList[1];

      print("緯度,経度：" +
          ido.toString() +
          "," +
          keido.toString() +
          "　速度(km/h)：" +
          speed.toString());
    } catch (TimeOutException) {
      //タイムアウトの場合

    }

    _rotate1Controller.reset(); //回転アニメーションを停止

    if (speed >= border_mippei_speed || accuracy > border_mippei_accuracy) {
      //屋内
      mituCount++;
      _checkText1 = "換気の悪い場所です！！\n" +
          RoundPoint(speed, 1) +
          "km/h　GPS精度:" +
          RoundPoint(accuracy, 1) +
          "m";
      _icon1 = Icons.warning;
      _iconColor1 = Colors.pinkAccent.shade400;
    } else {
      //屋外
      _checkText1 = "換気の悪い場所ではありません\n" +
          RoundPoint(speed, 1) +
          "km/h　GPS精度:" +
          RoundPoint(accuracy, 1) +
          "m";
      _icon1 = Icons.check_circle;
      _iconColor1 = Colors.lightGreenAccent.shade700;
    }

    ViewSet(mounted); //表示を反映
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    /*
    //権限チェックと要求を同時に行う？？
    //参考サイト：https://engineer.dena.com/posts/2021.06/2021-hibiya-festival-client/
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      //「アプリが使用中のみ許可」または「常に許可」の権限がある場合

    }
    */
  }

  //変数を表示に適用
  void ViewSet(bool mounted) {
    //連続で呼ばれた際のエラー防止用
    if (mounted) {
      setState(() {
        //これを記述することで表示を反映させる
        /*_showtext = "緯度経度：" +
            ((ido * 100000000).round() / 100000000).toString() +
            "," +
            ((keido * 100000000).round() / 100000000).toString() +
            "\n速度：" +
            speed.toString() +
            " km/h\nデバイス数：" +
            deviceCount.toString() +
            "　密集：" +
            missyuuCount.toString() +
            "　密接：" +
            missetuCount.toString() +
            "\n精度：" +
            accuracy.toString();*/
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false, //中央寄せを解除
        title: Text("今すぐ測定"),
        backgroundColor: PrimaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _titleText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.black54,
                ),
              ),
              Text(
                _subTitleText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              AutoSizeText.rich(
                TextSpan(
                  text: _addressText,
                  style: TextStyle(color: Colors.black54, fontSize: 18),
                ),
                maxLines: 1,
                minFontSize: 0,
                stepGranularity: 0.1,
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 15.0)),
              //屋内か屋外かの判定表示
              Container(
                height: 50,
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Row(
                  //mainAxisSize: MainAxisSize.min,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0)
                          .animate(_rotate1Controller),
                      child: Icon(
                        _icon1,
                        color: _iconColor1,
                        size: 35,
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
                    Text(
                      _checkText1,
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
              //1箇所に人が集中していないかどうかの表示
              Container(
                height: 50,
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Row(
                  //mainAxisSize: MainAxisSize.min,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0)
                          .animate(_rotate2Controller),
                      child: Icon(
                        _icon2,
                        color: _iconColor2,
                        size: 35,
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
                    Text(
                      _checkText2,
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 10.0)),
              //近接デバイス数の表示
              Container(
                height: 50,
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Row(
                  //mainAxisSize: MainAxisSize.min,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0)
                          .animate(_rotate3Controller),
                      child: Icon(
                        _icon3,
                        color: _iconColor3,
                        size: 35,
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
                    Text(
                      _checkText3,
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 15.0)),
              //共有・キャンセルボタン
              Row(
                children: [
                  //共有ボタン
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.only(right: 10),
                      child: OutlinedButton(
                          style: _shareButtonStyle,
                          onPressed: () async {
                            //共有ボタンを押したときの動作
                            String? result = await _selectsortTimeOthers();

                            if (result != null) {
                              //表示を反映
                              setState(() {
                                _addressText = "測定場所：" + result;
                              });
                            }
                          },
                          child: const Text("共有する")),
                    ),
                  ),
                  //キャンセルボタン
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.only(left: 10),
                      child: OutlinedButton(
                        style: NormalButton_sub(true),
                        onPressed: () {
                          //閉じるボタンを押したときの動作
                          Navigator.pop(context);
                        },
                        child: Text(_cancelButtonText),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //共有ボタンの選択ダイアログ生成用
  Future<String?> _selectsortTimeOthers() async {
    //初回表示の場合は初期値をセット
    if (_shareDialogSelect.length == 0) {
      _shareDialogSelect = addressList[2];
    }

    String beforeSelect = _shareDialogSelect; //キャンセルボタンをした際にもとに戻すために使用

    var result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              titlePadding: EdgeInsets.all(0),
              clipBehavior:
                  Clip.antiAliasWithSaveLayer, //強制的に角丸を適用する（内部背景色を変更した際も必ず）
              title: Container(
                color: PrimaryColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.help,
                        color: Colors.white,
                        size: 35,
                      ),
                      Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
                      Text(
                        "測定場所の表示形式を\n選択してください",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 5),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    _shareDialogSelect = beforeSelect; //選択を元に戻す
                    Navigator.pop(context);
                  },
                  child: Text(
                    'キャンセル',
                    style: TextStyle(
                      color: AccentColor,
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context, _shareDialogSelect);
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: AccentColor,
                    ),
                  ),
                ),
              ],
              content: Container(
                width: double.minPositive,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: addressList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return RadioListTile<String>(
                      value: addressList[index],
                      activeColor: PrimaryColor,
                      groupValue: _shareDialogSelect,
                      title: Text(addressList[index]),
                      onChanged: (val) {
                        // ダイアログを更新
                        setState(() {
                          _shareDialogSelect = val.toString();
                        });
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );

    return result;
  }
}
