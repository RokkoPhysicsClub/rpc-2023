---
title: "Path Tracing"
date: 2023-08-09T21:12:53+09:00
description: "光のリアルタイムなシミュレーション"
image: "./img/PathTracing/PathTracing_title.jpg"
draft: true
---
<div align="right">83rd 0x4C</div>

## はじめに
最近、PS5ではレイトレーシングができるとか真のレイトレーシングモードとかの話題を聞きますよね。<br>
なので、今回は真のレイトレーシングである`Path Tracing`を実装しました。
{{< tweet user="async0x4C" id="1687241871708372992" >}}

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

## 実装
### 光線の発射
今皆さんがこの記事を見るのに使っているスマホやらパソコンやらタブレットというものは、全ての画像を
**「ピクセル」**
という最小単位で表示しています。<br>
そのため、`Path Tracing`では全てのピクセルに対して光線を発射します。(一般的なディスプレイの場合はピクセルは2,073,600個程度)

### 光線の計算
`Path Tracing`では、冒頭に説明した通り光線の計算が必要になります。<br>
具体的には、
1. シーン内のすべてのポリゴンと交差判定をする
2. 交差した中で最も近いポリゴンの法線を基に反射/屈折

という手順を踏みます。<br>
以下にその(ほぼ)疑似コードを示します。
```java
Triangle[] triangles;
int triangle_count;

Triangle get_nearest_triangle(Ray ray){
  Triangle t;
  for(int i=0;i<triangle_count;i++){
    if(is_hit(ray,triangles[i])){
      if(nearer_than(t,triangles[i]))t=triangles[i];
    }
  }
  return t;
}

Ray sample_direction(Ray ray){
  Triangle triangle=get_nearest_triangle(ray);
  if(is_opaque(triangle)){
    ray.reflect(triangle.normal);
  }else{
    ray.refract(triangle.normal);
  }
  return ray;
}
```
### BSDF
`Path Tracing`において物理的に正しい描画をするには、当然物体の材質も物理的に正しい物である必要があります。<br>
そこで、`BSDF(Bidirectional Scattaring Distribution Function,双方向散乱分布関数)`というものが必要になります。<br>
また、`BSDF`というのは反射の特性を表現する`BRDF(Bidirectional Reflectance Distribution Function,双方向反射率分布関数)`と透過の特性を表現する`BTDF(Bidirectional Transmission Distribution Function,双方向透過率分布関数)`の和によって表され、これらは
1. 表面色
2. 放射色
3. スペキュラー
4. メタリック
5. 粗さ
6. IOR
7. 透過率

のパラメータを持ちます。
### GGX
先ほど説明した`BRDF`を実装するために、今回は`GGX`というモデルを使います。<br>
`GGX`というのは、`Microfacet理論`という粗い物体は表面にある小さな凹凸を仮定することで表現できるという理論を利用したモデルで、
- 鏡面反射の強さを決めるF(フレネル項)
- 表面の凹凸の強さを決めるD(法線分布関数)
- 凹凸による遮蔽を計算するG(マスキングシャドウ関数)

によって構成され、
$$ \dfrac{F\cdot D\cdot G}{4 (\vec{n}\cdot \vec{w_o}) \cdot (\vec{n}\cdot \vec{w_i}) } $$
という式で計算することができます。<br>
<br>
↓GGXのテストの画像。背景の都合でノイズが多い。
![Materials](../../img/PathTracing/materials.png)

### 背景
今回の`Path Tracer`には背景画像を読み込む機能を実装しています。<br>
背景画像といえば、皆さんが普段使っている`jpeg`や`png`を思い浮かべるかもしれませんが、それらの形式の画像は明るさを0~255の間に切り詰めてしまうので正確な太陽の明るさを表すことができません。なので、Path Tracingにおいては`hdri`や`exr`といったより広範囲の明るさを表現できる形式を使います。