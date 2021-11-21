//密閉認識値（この値より大きい場合は密と判定）
import 'package:flutter/material.dart';

final int border_mippei_speed = 40;
final int border_mippei_accuracy = 10; //この値より大きい場合（GPS精度のみ基準は「より大きい」）

//密集認識値（この値以上の場合は密と判定）
final int border_missyuu = 40;

//密接認識値（この値以上の場合は密と判定）
final int border_missetu = 3;
final int border_missetu_rssi = -60;

//標準ボタン（塗りつぶし）のスタイル
ButtonStyle NormalButton(bool enable) {
  ButtonStyle style;
  Color color;

  if (enable) {
    //有効の場合
    color = const Color(0xFFEC407A);
  } else {
    //無効の場合
    color = const Color(0xFFC9C9C9);
  }

  style = OutlinedButton.styleFrom(
      primary: Colors.white,
      shape: const StadiumBorder(),
      backgroundColor: color,
      elevation: 4);

  return style;
}

//標準ボタン（枠線タイプ）のスタイル
ButtonStyle NormalButton_sub(bool enable) {
  ButtonStyle style;
  Color color;

  if (enable) {
    //有効の場合
    color = const Color(0xFFEC407A);
  } else {
    //無効の場合
    color = const Color(0xFFC9C9C9);
  }

  style = OutlinedButton.styleFrom(
    primary: Colors.black,
    shape: const StadiumBorder(),
    backgroundColor: Colors.white,
    side: BorderSide(color: color, width: 3),
    elevation: 4,
  );

  return style;
}
