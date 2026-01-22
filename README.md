# receiptisan

電子レセプトファイル(`RECEIPTC.UKE`)を読込み、レセプトプレビューの出力をおこなうコマンドです。

現在、入院および外来の出来高レセプトのみ対応しています。DPCレセプト(`RECEIPTD.UKE`)は未対応です。

症状詳記はプレビューに表示されません。

紹介記事: https://qiita.com/yokenzan/items/6ee089770d8ec4913123

## インストール

```bash
$ git clone git@github.com:yokenzan/receiptisan.git
$ cd receiptisan
$ bundle install
$ bundle exec ruby exe/receiptisan --version
```

または[specific_install](https://github.com/rdp/specific_install)を利用して次のようにインストールすることも可能です。

```bash
$ gem specific_install -l https://github.com/yokenzan/receiptisan
```

## 使い方

```bash
# SVG(を埋込んだHTML)
$ bundle exec ruby exe/receiptisan --preview --format=svg path/to/RECEIPTC.UKE > preview.html

# YAML(プレビュー出力に使う内部解析データ)
$ bundle exec ruby exe/receiptisan --preview --format=yaml path/to/RECEIPTC.UKE_1 path/to/RECEIPTC.UKE_2 | yq -C

# JSON(プレビュー出力に使う内部解析データ)
$ bundle exec ruby exe/receiptisan --preview --format=json path/to/dir/*.UKE | jq -C
```

## 旧版

CSVなどへの変換、CUIやエディタでのプレビューには、下記リンクより旧版が利用いただけます:

- https://github.com/yokenzan/receiptisan/tree/v0.1.0
- https://github.com/yokenzan/receiptisan/releases/tag/v0.1.0
