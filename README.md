# orcd

OPENREC.tvコメントダウンローダー

![サンプル画像](https://github.com/ts1/orcd/blob/master/sample.jpg?raw=true)

## 必要なもの

- Node.js

## インストール

```
yarn global add orcd
```

または

```
npm i -g orcd
```

## 使い方

```
orcd URL 
```

URLにOPENREC.tvのアーカイブURLを指定します。

コメントのダウンロードに成功するとタイトルと同名のXMLファイルに保存されます。

XMLファイルは Cometan のようなプレイヤーで使用できます。
