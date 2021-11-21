//履歴タブ

import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

var listItem = ["one", "two", "three", "four", "five"]; //テスト

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: listItem.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Material(
                  child: Card(
                    color: Colors.yellow.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: InkWell(
                      //hoverColor: Colors.grey.shade100,
                      //splashColor: Colors.grey.withAlpha(30),
                      borderRadius: BorderRadius.circular(10.0),
                      onTap: () => print('tap: ' + listItem[index]),
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            //時刻・住所を表示する部分
                            Container(
                              height: 40,
                              child: Row(
                                //mainAxisAlignment: MainAxisAlignment.start, //左寄せ
                                children: <Widget>[
                                  Container(
                                    width: 90,
                                    child: Text(
                                      "19:00",
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 30),
                                    ),
                                  ),
                                  Expanded(
                                    //幅は最大（全体に広げる）
                                    child: AutoSizeText.rich(
                                      TextSpan(
                                        text: '測定した場所の住所',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 18),
                                      ),
                                      maxLines: 1,
                                      minFontSize: 0,
                                      stepGranularity: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //各3密状況を表示する部分
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly, //均等に配置
                              children: [
                                Column(
                                  children: [
                                    Image(
                                        height: 50,
                                        width: 50,
                                        image: AssetImage('images/mippei.png')),
                                    Text(
                                      "密閉",
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 18),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Image(
                                        height: 50,
                                        width: 50,
                                        image:
                                            AssetImage('images/missyuu.png')),
                                    Text(
                                      "密集",
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 18),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Image(
                                        height: 50,
                                        width: 50,
                                        image:
                                            AssetImage('images/missetu.png')),
                                    Text(
                                      "密接",
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 18),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "一番下までスクロール",
        child: Icon(Icons.arrow_downward),
        onPressed: () {
          listItem[2] = "文字変更";
          setState(() {});
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 200),
          );
        },
      ),
    );
  }
}
