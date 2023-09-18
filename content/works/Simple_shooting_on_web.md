---
title: "Simple_shooting_on_web"
date: 2023-08-09T23:15:28+09:00
description: "高難易度シューティングゲーム"
image: "./img/Simple_shooting_on_web/Simple_shooting_on_web_title.png"
draft: false
---

<div align="right">83rd 0x4C</div>
2年ぐらい前にSimple_shootingっていうゲームがありましたよね。<br>
<br>
↓これ
<br>
{{< link-card-complete "https://rokkophysicsclub.github.io/rpc-2021/works/shimple_shooting/" "Simple_shooting" "https://rokkophysicsclub.github.io/rpc-2021/img/simple_shooting/stage40.png" "ミニゲーム">}}

今回は、Simple_shootingをブラウザでプレイできるようにしました。<br>
<br>
↓成果物
<br>
{{< link-card-complete "https://asynchronous-0x4c.github.io/Simple_shooting_on_web/" "Simple_shooting_on_web" "../../img/Simple_shooting_on_web/Simple_shooting_on_web_title.png" "本来触れられることのなかった味わい深いバグを体験できるゲーム">}}

## 内容
今回、わざわざSimple_shootingのブラウザ版を作ったという報告をするためだけに部誌を書いたというわけではありません。<br>
Simple_shootingをブラウザで動かすために紆余曲折あったり無かったりしたので、それについて書いていこうと思います。

## 概要
- 開発人数 : 2人
- 開発期間 : 1年+ちょっと
- ソースコード : 世紀末

やはりどれだけ時が経とうとソースコードが世紀末のような汚さというのが変わらないのは、Simple_shootingのファンの皆さんにとっては実家のような安心感がありますよね。<br>
それと同時に僕(0x4C)にとっては、二度とこのようなソースコードを書いてはいけないという戒めになっています。

## どんなゲーム?
Simple_shootingは、緑色の円の形をしたプレイヤーをマウスで動かし、マウスクリックをすることで弾を発射して敵を倒しながら生き残るという内容になっています。<br>
また、Simple_shootingはステージ制となっており、現在ステージが1~42ぐらいまであります。<br>
その中で5の倍数のステージではボスが出現し、基本的にステージ20まではボスを倒さないとクリアできないという仕様になっています。

## Web版の制作
今回、Web版の制作をするにあたって[`Processing.js`](https://github.com/processing-js/processing-js)というライブラリを利用しました。<br>
Processing.jsはどのようなものかというと、Processing側で書いたソースコード(.pde)を自動でJavaScriptに変換して実行してくれるというものです。<br>
これはとても便利な反面、Processing.jsの開発が5~6年ほど前に終了しているので、最新版のProcessingでは使えてもProcessing.jsでは変換できないといった構文があります。<br>
例えば、ジェネリクスを使う場合
```java
ArrayList<Integer>int_list=new ArrayList<>();
```
という書き方は出来ず、
```java
ArrayList<Integer> int_list=new ArrayList<Integer>();
```
のように型と変数名の間にスペースを入れ、ジェネリクスの中を省略せずに書かなければエラーが発生してしまいます。

## 画面サイズをめぐる死闘
Web版Simple_shootingを開発するにあたり、プログラムの変換が完了しデプロイしてみたところ、<br>
<br>
**スマホで画面が収まっていない...**<br>
<br>
理由を説明しましょう。<br>
一般的なWebサイトでは、パソコンやスマホから同じコンテンツにアクセスすることができます。<br>
ただ、スマホはパソコンと同程度の画面解像度だからといってパソコンと同じ設定のままコンテンツを表示してしまうと、スマホからでは小さすぎて見えにくいという状況に陥ります。<br>
そこで、HTMLには`viewport`という仮想的な画面のサイズを決める機能があり、パソコンではそのままの解像度が、スマホでは元より小さな解像度(1920×1080→640×360など)が設定されています。<br>
なので、スマホからSimple_shootingにアクセスすると仮想的な解像度が小さすぎて画面に収まりきらないという現象が発生するのです。

### 試行錯誤
仮想的な画面サイズを使うせいで画面が収まりきらないのであれば、仮想的な画面サイズを使わず画面解像度をそのまま持ってくればいい話です。<br>
<br>
...<br>
<br>
**今度は画面が小さすぎる...**<br>
<br>
画面が小さいのであれば、仮想的な画面のサイズを1280×720に統一すれば改善するはずです。<br>
<br>
**あれ、画面が収ま(ry**<br>
<br>
結局、画面のサイズを固定するもサイズが合わなかったりで結局元の設定に戻しました。

## リメイク
今までひた隠しにしてきましたが、実はSimple_shootingのリメイク版なるものが存在します。<br>
その名も[**Re:Simple_shooting**](https://asynchronous-0x4c.github.io/Simple_shooting_on_web/Simple_shooting/)。
![Re:Simple_shooting](../../img/Simple_shooting_on_web/Re_SS.avif)

Re:Simple_shootingでは敵の弾を消せるようになったりパーティクルや演出が追加されるなど様々な点が改善されています。<br>
それに従ってソースコードも大幅に綺麗になりました。<br>
ただ、まだ開発中なので来年になったら完成しているかもしれません。

## 最後に
今年は遂に全国のSimple_shootingファンの方々が待ち望んでいたブラウザ版Simple_shootingを開発することができました。<br>
来年からもSimple_shooting_2.1やRe:Simple_shootingをはじめとしたSimple_shootingシリーズが開発されていくと思うので温かく見守っていただけたら幸いです。

<br>
<a href="https://twitter.com/share?ref_src=twsrc%5Etfw" class="twitter-share-button" data-hashtags="六甲学院物理部2023" data-lang="ja" data-show-count="false">#六甲学院物理部2023 でポスト</a><script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>