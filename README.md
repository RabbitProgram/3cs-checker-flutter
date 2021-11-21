# 3密チェッカーのFlutterリメイク版（iOS対応）
![GitHub repo size](https://img.shields.io/github/repo-size/RabbitProgram/3cs-checker-flutter)
![version](https://img.shields.io/badge/last%20update-v0.1.0-red)
![Flutter](https://img.shields.io/badge/Flutter-02569B.svg?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2.svg?logo=dart&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?logo=apple&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?logo=android&logoColor=white)

<a href="https://rabbitprogram.com/rabbitprogram/donate"><img src="https://img.shields.io/badge/buy me a coffee-ffdd00.svg?logo=buy me a coffee&logoColor=white&style=for-the-badge&label=DONATE"></a>

<img width="150" src="https://user-images.githubusercontent.com/74450836/142760124-ba93ba62-e1fa-4497-80e3-4070f201f24d.png">
<br/>


## はじめに
<table>
    <tr>
        <td width="220">
            <img
                src="https://user-images.githubusercontent.com/74450836/142760145-aa5a2eb9-2e80-47f2-bfef-d0659027cc1a.PNG">
        </td>
        <td>
<a href="https://www.amazon.co.jp/gp/product/B08P7L9Y6L">3密チェッカーアプリ</a>をiOS端末でも使えるようにするため、現在Flutterでプログラムを書き直しています。<br />
3密チェッカーについて：https://rabbitprogram.com/support/threec<br />
<br />
iOSではAndroidのようにバックグラウンドでの動作がうまくできず、解決方法が全くわからないため、この度パブリックなリポジトリでソースコードを公開することにしました。<br />
オープンソースだからこそ、皆様のご意見を取り入れながら、チームで開発していきたいと思っています。<br />
<br />
参考になりますよう、下にアプリの仕様や原状などを記載しています。<br />
お気づきの点がございましたら、ぜひお気軽に <a href="https://github.com/RabbitProgram/3cs-checker-flutter/issues">Issue</a> にお寄せください。<br />
<br />
些細な助言でも構いません。<br />
皆様のお力添えをお待ちしています🙇‍♂️
        </td>
    </tr>
</table>
<br />


## 現状
<table>
    <tr>
        <td></td>
        <td>フォアグラウンド</td>
        <td>バックグラウンド</td>
        <td>タスクキル</td>
    </tr>
    <tr>
        <td>Timer.periodic (※1)<br /></td>
        <td>✅</td>
        <td>⚠️</td>
        <td>？</td>
    </tr>
    <tr>
        <td>background_locator (※2)<br /><br /></td>
        <td>✅</td>
        <td>⚠️</td>
        <td>❌</td>
    </tr>
</table>
※1：指定時間間隔で処理するタイマー<br/>
※2：https://pub.dev/packages/background_locator<br/>
タスクを終了してしまうと、AndroidでいうServiceのように処理を続けることができないのが現状です。<br/>
バックグラウンドでは処理は呼ばれますが、Bluetoothを使用できず人数の測定ができません。<br/>
<br/>


## 分からないこと🤷‍♂️
- バックグラウンドの状態でBluetoothを使うにはどうしたらいいか<br/>
→ios/Runner.xcodeprojファイルのバックグラウンド周りの設定がおかしい？
- アプリを起動していない状態でどうやって測定したらいいか<br/>
<br/>


## テスト方法
Android Studioでリポジトリをクローンした後、まずはじめにpubspec.yamlを開いて「Pub get」ボタンを押してください。<br/>
または、次のコマンドを実行します：<br/>
```shell
flutter pub get
```

読み込み後、 ▶️ （再生）ボタンを押してアプリをビルドして実行します。<br/>
アプリ起動後、設定→「3密チェッカー（テスト）」→位置情報を開き、「常に」を選択してください。<br/>
（バックグラウンドテストの際にはこの設定が必要です）<br/>
<br/>


## 画面について
<table>
  <tr>
    <td width="220">
      <img src="https://user-images.githubusercontent.com/74450836/142760405-0f61e651-db3c-4ff1-a5fa-1e7011f24dc0.PNG">
    </td>
  <td>
・<img src="https://img.shields.io/badge/今すぐ測定-orange">：現在の3密状態を測定します<br/>
・<img src="https://img.shields.io/badge/サンプルログ書き込み-brightgreen">：内部的なファイル書き込みテストです。iPhoneのファイルアプリからはアクセスできない場所にテストログを記録します。<br/>
・<img src="https://img.shields.io/badge/サンプルログ読み込み-brightgreen">：上記の書き込み確認を行います。<br/>
・<img src="https://img.shields.io/badge/バックグラウンド測定履歴を確認-brightgreen">：20m移動ごとに記録された位置情報のログを表示します。<br/>
・<img src="https://img.shields.io/badge/開始-blue">：一定間隔（5秒ごと）の定期バックグラウンド測定を開始します。<br/>
    </td>
  </tr>
</table>
<br/>


## テストプログラムについて
2種類の測定プログラムを搭載しています。<br/>

### 1：指定時間おきにタイマーで定期処理する
<img width="400" src="https://user-images.githubusercontent.com/74450836/142761028-7ee34b6a-2c7c-406f-898d-8557b8491a12.png">
テストプログラムでは、アプリの開始ボタンを押下後、5秒おきに人数の測定を行います。<br/>
なお、バックグラウンドに移行した場合はBluetoothが使用できず人数は「0」を返します。<br/>

### 2：一定距離動いたら処理を実行する
<img width="400" src="https://user-images.githubusercontent.com/74450836/142761050-438ad35e-c161-4c8e-84de-8ccf609f720f.png">
テストプログラムでは、アプリの開始ボタンを押下後、20m移動するとログを記録するようにしています。<br/>
記録されたログは [バックグラウンド測定履歴を確認] ボタンを押すと確認できます。<br/>
<br />


## 注意
ここで公開しているFlutterバージョンは、現在はまだ開発途中の試作品です。<br />
残存する不具合などの保証はありませんので、ご注意ください。<br />


