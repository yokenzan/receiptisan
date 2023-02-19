# receiptisan

電子レセプトファイル(`RECEIPTC.UKE`)を読込み、レセプトプレビューの出力をおこないます。

現在、入院の出来高レセプトのみ対応しています。

## インストール

```bash
$ git clone git@github.com:yokenzan/receiptisan.git
$ cd receiptisan
$ bundle install
$ bundle exec ruby exe/receiptisan --version
```

or you also can install by using [specific_install](https://github.com/rdp/specific_install).

```bash
$ gem specific_install -l https://github.com/yokenzan/receiptisan
```

## 使い方

### コマンド

#### `--preview`

レセプトプレビューを表示します。

```bash
# SVG(を埋込んだHTML)
$ bundle exec ruby exe/receiptisan --preview --format=svg path/to/RECEIPTC.UKE > preview.html

# YAML(プレビュー出力に使う内部解析データ)
$ bundle exec ruby exe/receiptisan --preview --format=yaml path/to/RECEIPTC.UKE_1 path/to/RECEIPTC.UKE_2 | yq -C

# JSON(プレビュー出力に使う内部解析データ)
$ bundle exec ruby exe/receiptisan --preview --format=json path/to/dir/*.UKE | jq -C
```

## 旧版

CSVなどへの変換、CUIやエディタでのプレビューには旧版が利用いただけます。

https://github.com/yokenzan/receiptisan/releases/tag/v0.1.0
