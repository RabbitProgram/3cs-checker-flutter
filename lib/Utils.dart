import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

//URLを開く
void LaunchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not Launch $url';
  }
}

//指定した桁数まで表示（それ以降を四捨五入する）
String RoundPoint(double number, int keta) {
  num base_number = pow(10, keta); //10のketa乗
  double result = (number * base_number).round() / base_number;
  return result.toString();
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

//テキストファイルのパスを取得する
Future<File> getFilePath(String fileName) async {
  final directory = await getTemporaryDirectory();
  //debugPrint(directory.path);
  return File(directory.path + '/' + fileName);
}

//テキストファイル読み込み
Future<String> TextFileLoad(String fileName) async {
  final file = await getFilePath(fileName);
  return file.readAsString();
}

//テキストファイル書き込み
void TextFileSave(String fileName, String text) {
  getFilePath(fileName).then((File file) {
    //thenの記述で非同期処理であるgetFilePath関数の処理を待っている
    file.writeAsString(text);
  });
}
