# orcd

[![npm version](https://badge.fury.io/js/orcd.svg)](https://badge.fury.io/js/orcd)
![CI](https://github.com/ts1/orcd/workflows/CI/badge.svg)

OPENREC.tvコメントダウンローダー

![サンプル画像](https://github.com/ts1/orcd/blob/master/sample.jpg?raw=true)

## ブラウザ版の使用方法

下記のコードをURLとしてブックマークを作成してください。

```
javascript:(s=document.createElement('script')).src='https://unpkg.com/orcd/browser/orcd.js';document.body.append(s)
```

OPENRECの動画URLで、上記で作成したブックマークをクリックするとASS形式でダウンロードします。

以下はコマンドラインの使用法です。

## 必要なもの

- Node.js 10.x以上

## インストール

```
npm i -g orcd
```

または

```
yarn global add orcd
```

## 使い方

### ダウンロード

```
orcd https://www.openrec.tv/live/...
```

引数にOPENREC.tvのアーカイブURLを指定します。

コメントのダウンロードに成功するとタイトルと同名のXMLファイルに保存されます。

XMLファイルは Cometan のようなプレイヤーで使用できます。

`-f` オプションを使うと他のフォーマットで保存できます。


### 変換

```
orcd FILE -f FORMAT
```

XMLまたはJSONで保存したファイルをASS, JSON, XMLのいずれかに変換します。

#### ASSに変換する例

```
orcd 159.xml -f ass
```

#### 注意

~~v0.1.0 ではダウンロードの `delay` オプションがデフォルト15秒になっているため、そのまま変換すると `delay` が二重になってしまいます。
v0.1.0 でダウンロードしたファイルを変換するときは `-d 0` (または、補正値) をつけてください。~~ → v0.3.1 で常にデフォルト0秒に変更しました。

### その他のオプション

```
orcd <url|file>

動画のコメントを取得または変換します

位置:
  url|file  ダウンロードURL、または変換元ファイル                       [文字列]

ASSオプション:
  -F, --fontname  フォント名                 [文字列] [デフォルト: "MS PGothic"]
  -s, --fontsize  フォントサイズ(px)                     [数値] [デフォルト: 48]
  -m, --margin    上下のマージン(px)                      [数値] [デフォルト: 4]
  -O, --outline   文字のアウトライン(px)                  [数値] [デフォルト: 2]
  -t, --time      コメント1個の表示時間(秒)               [数値] [デフォルト: 8]

オプション:
  -v, --version   バージョンを表示                                        [真偽]
  -d, --delay     時間のずれ(秒)                          [数値] [デフォルト: 0]
  -R, --norandom  秒以下を乱数化しない                                    [真偽]
  -f, --format    出力フォーマット
                    [選択してください: "xml", "ass", "json"] [デフォルト: "xml"]
  -o, --output    出力ファイル名                   [文字列] [デフォルト: "auto"]
  -D, --debug     デバッグモード                                          [真偽]
  -h, --help      ヘルプを表示                                            [真偽]
```
