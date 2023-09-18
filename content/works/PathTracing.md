---
title: "Path Tracing"
date: 2023-08-09T21:12:53+09:00
description: "光のリアルタイムなシミュレーション"
image: "./img/PathTracing/PathTracing_title.avif"
draft: false
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
- Java : Java20
- OpenGL : OpenGL4.6

## Path Tracingの説明
### そもそもPath Tracingって何?
Path Tracingというのは`Ray Tracing`という手法の一種で、超簡単に言うと光のシミュレーションです。<br>
もう少し厳密に言うと、光を粒子として考えた上で反射/屈折などの光学現象をシミュレートするというものです。
![Ray Trace](../../img/PathTracing/Ray_Trace.avif)

### Path Tracingは何が良いのか
皆さんは1度ぐらいは3Dの綺麗なグラフィックスのゲームをプレイしたり動画を観たりしたことがあると思うのですが、それらはほぼ全て`ラスタライズ法`という方式で描画されています。<br>
`ラスタライズ法`というのは、キャラクターやオブジェクトなどを画面に投影して、その部分を光の位置を考えて塗りつぶすというものです。<br>
![ラスタライズ法](../../img/PathTracing/Rasterize.avif)
この方法は、遮蔽や反射を考えないのでとても高速である反面、間接光や鏡の正確な表現ができません。<br>
<br>
一方、`Path Tracing`では画面のピクセルごとに光線を飛ばし、オブジェクトとの交差判定をとって反射/屈折などを繰り返すことで3Dの世界を描画するというものです。<br>
![Path Tracing](../../img/PathTracing/PT.avif)
この方法は、圧倒的にリアルな表現ができる代わりにとても処理が遅く、ノイズも発生します。

### 使用されているもの
現在、Path Tracingは主に映画のようなリアルタイムで計算する必要が無い場面で利用されており、最近では一部のゲームがRay Tracingに対応、そしてほんの一握りのゲームがPath Tracingに対応しています。
![Game](../../img/PathTracing/PT_Game.avif)

## 作ったもの
Path Tracingをリアルタイムで実行するゲーム的な何かを作りました。<br>
W,A,S,Dのキーで動いたりMinecraftのような感覚で視点を操作できます。
{{< tweet user="RokkoPhysics" id="1697896443879817641" >}}

## 実装
### レンダリング方程式
パストレーシングは、次のような式で表現されます。
$$ L_o(x,\vec \omega_o)=L_e(x,\vec \omega_o)+\int_\Omega f_s(x,\vec\omega_i,\vec\omega_o)L_i(x,\vec\omega_i)|\vec\omega_i\cdot n|d\omega_i $$
この中で、$L_o(x,\vec \omega_o)$が出射光、$L_e(x,\vec \omega_o)$が物体自体の発光、$\int_\Omega f_s(x,\vec\omega_i,\vec\omega_o)L_i(x,\vec\omega_i)|\vec\omega_i\cdot n|d\omega_i$が物体表面で反射した光の強さを表します。

### パイプライン
レイトレーシングやラスタライズにおいては、GPUが効率的に仕事をこなす為に何をどういった順番で行うのかを決めるパイプラインというものが存在します。<br>

![Game](../../img/PathTracing/ShaderPipeline.avif)

普通はラスタライズ用のパイプラインを使うのですが、今回はレイトレーシングということでレイトレーシング用のパイプラインを<br>
**使いません。**<br>
今回は全ての処理を自分で書いてみたいと思ったので、ラスタライズ用のパイプラインで強引に実装します。

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
レイトレーシング用のパイプラインを使えばGPUが自動で超高速に交差判定をしてくれるのですが、今回は使わないので自前の実装という形になります。

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
$$ f(x,\omega_o,\omega_i)=\dfrac{F\cdot D\cdot G}{4 (\vec{n}\cdot \vec{w_o}) \cdot (\vec{n}\cdot \vec{w_i}) } $$
という式で計算することができます。<br>
<br>
↓GGXのテストの画像。背景の都合でノイズが多い。
![Materials](../../img/PathTracing/materials.avif)

### 背景
今回の`Path Tracer`には背景画像を読み込む機能を実装しています。<br>
背景画像といえば、皆さんが普段使っている`jpeg`や`png`を思い浮かべるかもしれませんが、それらの形式の画像は明るさを0~255の間に切り詰めてしまうので正確な太陽の明るさを表すことができません。なので、Path Tracingにおいては`hdri`や`exr`といったより広範囲の明るさを表現できる形式を使います。

### BVH
ポリゴンとの交差判定の処理は、ポリゴンの数が少ないときには何ともないのですが、流石に10,000ポリゴンのような大量のポリゴンでできたシーンをレンダリングするようになると大幅に速度が低下します。<br>
なので、`BVH(Bounding Volume Hierarchy)`というデータ構造を利用して交差判定の高速化を図ります。<br>
>![BVH](../../img/PathTracing/bvh_ex.avif)
>https://developer.nvidia.com/blog/thinking-parallel-part-ii-tree-traversal-gpu/ より引用

BVHの作り方としては、すべてのポリゴンを`SAH(Surface Area Heuristics)`という関数で計算したコストが最小になる組み合わせで2つにグループ分けするということを繰り返します。<br>
ただ、SAHが最小になるグループを素直に探すと時間がかかるので、`Binning`という、分割したいグループにすっぽりと被さるバウンディングボックスの最長辺の軸に沿ってグループ内のポリゴンをソートし、事前に決めた分割数の数のグループにポリゴンを均等に分け、その中からSAHが最小になるグループを見つけ出す手法を使うことによって、グループの探索を分割数の数にまで減らすことができます。<br>
今回は部誌の執筆時点では有効化していませんが、展示するときには多分有効化していると思います。<br>
ちなみに、今回のパストレーサーでは超高速なハードウェアが使えないので距離で非表示にするなどの最適化をしています。

### NEE
Path Tracingにおいては、光源にレイが当たらないと色を計算できないので、無理やり光源とレイをつなげようという`NEE(Next Event Estimination)`という名前の手法があります。<br>
今回のパストレーサーでは時間が足りず実装できませんでした。<br>
気が向いたら実装するかもしれません。

### デノイズ
最初のほうで触れた通り、Path Tracingではノイズが発生します。<br>
しかし、リアルタイムで動かすにはいちいち何回もサンプリングしている暇はありません。<br>
なので、どうにかしてノイズのある画像からノイズを取り除く必要があります。<br>
そこで出てくるのが`SVGF(Spatiotemporal Variance-Guided Filtering)`という手法です。
>![SVGF](../../img/PathTracing/SVGF_ex.avif)
>https://qiita.com/shocker-0x15/items/f928898730498c7a52c7 より引用

具体的にSVGFでは何をするのかというと、物体の本来の色や光の強さなどの情報からピクセルごとのノイズによる分散を推定し、推定した分散に従って範囲に気をつけつつ画像をぼかすことでノイズを大幅に減らします。<br>
このとき、過去のフレームの情報を再利用することによって実質的なサンプル数を稼いだり、時間軸においての一貫性を持たせることができるようになります。<br>
部誌の執筆時にはまだ実装していませんが、本番までにはフレームの再利用以外は実装しているかもしれません。

## Gallery
部誌の執筆時での画像たちです。
![Main_Scene](../../img/PathTracing/PathTracing_title.avif)
![Dragon](../../img/PathTracing/Dragon.avif)
![Entrance](../../img/PathTracing/Entrance.avif)

## 最後に
前々からパストレーサーを作りたいと思っていたものの、なかなかハードルが高くて実装までは至らなかったのですが、~~中間試験真っただ中に勉強をサボって~~原型となる単純な仕組みだけのレイトレーサーを実装してみたらそれを拡張することで案外すんなりと実装できました。(ただし普通に難しかった)<br>
やっぱり思い切りって大事なんだと思います。<br>
取り敢えず、OpenGLでリアルタイムを実現する難易度が高すぎたので、これに懲りて次からはOptiXとかVulkanを使って実装すると思います。

## あとがき
Path Tracingに興味がある人のために色々調べたことを載せておきます。(間違ってたらすいません)
* `MIS(Multiple Importance Sampling)`
  * NEEとPath Tracingをうまい具合に混ぜて使うことでノイズを減らす
* `双方向パストレーシング`
  * カメラからだけでなく光源からも光線を発射し、それらを繋ぐことで集光模様をサンプリングできるようになる。
* `MNEE(Manifold NEE)`
  * 集光模様(コースティクス)でもNEEを使えるようにした改良型NEE
* `SMS(Specular Manifold Sampling)`
  * MNEEでもノイズを減らすのが難しい高周波コースティクスもきれいにサンプリングできる手法。RISを使ってる?
* `RIS(Resampled Importance Sampling)`
  * 目標のPDFに近い分布でサンプリングできる。結構重要。
* `ReSTIR(Path Resampling for Real-Time Path Tracing)`
  * リアルタイム用のパストレーシングアルゴリズム。パスを再利用して実質的なサンプル数を大幅に増やす。
* `ReGIR`
  * ReSTIRをグリッドベースで放射輝度などを保存することで2次反射以降でもパスの再利用をできるようにしたもの(だった気がする)。Ray Tracing GemsⅡに掲載されている。

<br>
<a href="https://twitter.com/share?ref_src=twsrc%5Etfw" class="twitter-share-button" data-hashtags="六甲学院物理部2023" data-lang="ja" data-show-count="false">#六甲学院物理部2023 でポスト</a><script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>