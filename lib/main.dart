import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:flutter/material.dart';

import 'DashboardPage.dart';
import 'HistoryPage.dart';
import 'SettingsPage.dart';
import 'location_callback_handler.dart';

const PrimaryColor = const Color(0xffFF5722);
const PrimaryColorDark = const Color(0xffc62828);
const AccentColor = const Color(0xffFF5722);

bool locationFlag = false;
const String isolateName = "LocatorIsolate";
ReceivePort port = ReceivePort();

void startLocationService() {
  Map<String, dynamic> data = {'countInit': 1};
  BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
      initCallback: LocationCallbackHandler.initCallback,
      initDataCallback: data,
      disposeCallback: LocationCallbackHandler.disposeCallback,
      autoStop: false,
      iosSettings: IOSSettings(
          accuracy: LocationAccuracy.NAVIGATION,
          distanceFilter: 20), //位置情報取得間隔（何m移動したら取得するか）
      androidSettings: AndroidSettings(
          accuracy: LocationAccuracy.NAVIGATION,
          interval: 5, //リクエスト間隔（Androidのみ、5秒間隔で処理）
          distanceFilter: 20,
          androidNotificationSettings: AndroidNotificationSettings(
              notificationChannelName: 'Location tracking',
              notificationTitle: 'Start Location Tracking',
              notificationMsg: 'Track location in background',
              notificationBigMsg:
                  'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
              notificationIcon: '',
              notificationIconColor: Colors.grey,
              notificationTapCallback:
                  LocationCallbackHandler.notificationCallback)));
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3密チェッカー（テスト）',
      theme: ThemeData(
        //primarySwatch: Colors.blue,
        brightness: Brightness.light,
        primaryColor: PrimaryColor,
        primaryColorDark: PrimaryColorDark,
        accentColor: AccentColor,
      ),
      home: MyHomePage(title: '3密チェッカー（テスト）'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; //表示中のタブ番号
  late PageController _pageController;

  static const List<String> _pageTitle = ["Dashboard", "履歴", "設定"];
  static List<Widget> _pageList = [
    DashboardPage(title: 'Dashboard'),
    HistoryPage(),
    SettingsPage(),
  ];

  //起動時に実行する処理
  @override
  void initState() {
    super.initState();

    //タブ
    _pageController = PageController(
      initialPage: _selectedIndex,
    );

    initPlatformState();
  }

  Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
  }

  //タブ遷移時の動作
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false, //中央寄せを解除
        title: Text(_pageTitle[_selectedIndex]),
        backgroundColor: PrimaryColor,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pageList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).accentColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            title: Text('Dashboard'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_later),
            title: Text('履歴'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('設定'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          _selectedIndex = index;
          _pageController.animateToPage(index,
              duration: Duration(milliseconds: 100), curve: Curves.easeIn);
        },
      ),
    );
  }
}
