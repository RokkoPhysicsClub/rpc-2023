---
title: "PathTracing"
date: 2023-08-09T21:12:53+09:00
description: "光のリアルタイムなシミュレーション"
image: "./img/PathTracing/PathTracing_title.jpg"
draft: false
---

<div align="right">83rd 0x4C</div>

## はじめに
最近、PS5ではレイトレーシングができるとか真のレイトレーシングモードとかの話題を聞きますよね。<br>
なので、今回は真のレイトレーシングである`Path Tracing`を実装しました。
<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">リアルタイムパストレーサーつくった <a href="https://t.co/yyXxIUCveC">pic.twitter.com/yyXxIUCveC</a></p>&mdash; 0x4C (@async0x4c) <a href="https://twitter.com/async0x4c/status/1687241871708372992?ref_src=twsrc%5Etfw">August 3, 2023</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## 開発環境
- OS : Windows10
- CPU : Intel🄬 core i7 11700
- GPU : NVIDIA GeForce RTX 3060
- RAM : DDR4-3200 48GB
- Java : Java17

## Path Tracingの説明
### そもそもPath Tracingって何?
Path Tracingというのは、超簡単に言うと光のシミュレーションです。<br>
もう少し厳密に言うと、光を粒子として考えた上で反射/屈折などの光学現象をシミュレートするというものです。
![Ray Trace](../../img/PathTracing/Ray_Trace.jpg)
### Path Tracingは何が良いのか
皆さんは1度ぐらいは3Dの綺麗なグラフィックスのゲームをプレイしたり動画を観たりしたことがあると思うのですが、それらは`ラスタライズ法`という方式で描画されています。<br>
`ラスタライズ法`というのは、キャラクターやオブジェクトなどを画面に投影して、その部分を光の位置を考えて塗りつぶすというものです。<br>
![ラスタライズ法](../../img/PathTracing/Rasterize.png)
この方法は、遮蔽や反射を考えないのでとても高速である反面、間接光や鏡の正確な表現ができません。<br>
<br>
一方、`Path Tracing`では画面のピクセルごとに光線を飛ばし、オブジェクトとの交差判定をとって反射/屈折などを繰り返すことで3Dの世界を描画するというものです。<br>
![Path Tracing](../../img/PathTracing/PT.png)
この方法は、圧倒的にリアルな表現ができる代わりにとても処理が遅く、ノイズも発生します。