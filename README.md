# receiptisan

電子レセプトファイル(`RECEIPTC.UKE`)を読込み、レセプトプレビューの出力やレセ電マスター検索ををおこなうことができます。

現在、入院および外来の出来高レセプトのみ対応しています。DPCレセプト(`RECEIPTD.UKE`)は未対応です。

症状詳記はプレビューに表示されません。

紹介記事: [会社のプロダクトに自作プログラムを活用した経緯と、その功罪 - Qiita](https://qiita.com/yokenzan/items/6ee089770d8ec4913123)

## インストール

```bash
git clone git@github.com:yokenzan/receiptisan.git
cd receiptisan
bundle install
bundle exec receiptisan --version
```

または [specific_install](https://github.com/rdp/specific_install) を利用できます。

```bash
gem specific_install -l https://github.com/yokenzan/receiptisan
```

## 使い方

### レセプトプレビュー(紙レセプト様式準拠)

紙レセプトのフォーマットをSVGとして生成し、紙レセプトを埋込んだHTMLとして出力します。

```bash
# SVGを埋込んだHTMLを出力
bundle exec receiptisan --preview --format=svg path/to/RECEIPTC.UKE > preview.html
```

電子レセプトファイルには医療機関所在地が記録されないため、既定では生成HTMLに印字されませんが、 `--hospitals` にJSON配列を渡すことで印字させることが可能です。

```bash
# code: 医療機関番号
# location: 医療機関所在地
# bed-count: 病床数(入院レセプトの「病」「診」記号等、病院・診療所の判定に利用)
bundle exec receiptisan --preview --format=svg \
  --hospitals='[
    {"code": "1234567", "location":"東京都千代田区1-2-3", "bed-count":120},
    {"code": "7654321", "location":"大阪府大阪市4-5-6",   "bed-count":80}
  ]' \
  path/to/RECEIPTC.UKE > preview.html
```

### レセプト構造化出力

上記の紙レセプト様式以外にも、構造化データとしてYAMLやJSON形式で出力することが可能です。 `--hospitals` のオプションも、SVGの場合と同様に指定可能です。

```bash
# YAMLで内部解析結果を出力
bundle exec receiptisan --preview --format=yaml path/to/RECEIPTC_1.UKE path/to/RECEIPTC_2.UKE | yq -C

# JSONで内部解析結果を出力
bundle exec receiptisan --preview --format=json path/to/*.UKE | jq -C

# 標準入力から電子レセプトファイルのデータを読むことも可能
cat path/to/RECEIPTC.UKE | bundle exec receiptisan --preview --format=json | jq -C
```

### レセプト電算マスター検索

`search` コマンドでレセ電マスターから該当レコードを簡易的に検索します。

検索結果として出力されるカラムは限定的で、今後拡充予定です。

```bash
# 診療行為マスターから「初診」を名称に含むものを検索
bundle exec receiptisan search --type=shinryou-koui --name=初診 | jq -C

# 医薬品マスターから名称が「ロキソプロフェン」に一致するものを検索
bundle exec receiptisan search --type=iyakuhin --name-exact=ロキソプロフェン | jq -C

# 点数または価格から検索
#
# 点数が288点の診療行為を検索
bundle exec receiptisan search --type=shinryou-koui --point=288 | jq -C
# 薬価が1～10円の医薬品を検索
bundle exec receiptisan search --type=iyakuhin --point-min=1 --point-max=10 | jq -C

# 検索基準月とヒット上限件数を指定
#
# 2024年6月現在の傷病名マスターから「糖尿病」名称に含むものを検索し、20件を上限に出力
# YAMLでの出力も可能
bundle exec receiptisan search --type=shoubyoumei --name=糖尿病 --month=202406 --limit=20 --format=yaml

# レセ電コードを指定する場合は検索結果が一意に定まる想定となるため `--type` の指定を省略可能
bundle exec receiptisan search --code=111000110 | jq -C

# `search` のエイリアスとして `s` での実行も可能
bundle exec receiptisan s --code=111000110 | jq -C
```

指定できる `--type`:

| オプション      | 意味         |
|-----------------|--------------|
| `shinryou-koui` | 医科診療行為 |
| `iyakuhin`      | 医薬品       |
| `tokutei-kizai` | 特定器材     |
| `comment`       | コメント     |
| `shoubyoumei`   | 傷病名       |
| `shuushokugo`   | 修飾語       |

検索仕様:

| オプション     | 意味                                                                                        |
|----------------|---------------------------------------------------------------------------------------------|
| `--code`       | レセ電コードの完全一致で検索                                                                |
| `--name`       | `省略名称 漢字名称`・`省略名称 カナ名称`・`基本漢字名称`に対する部分一致で検索              |
| `--name-exact` | `省略名称 漢字名称`・`省略名称 カナ名称`・`基本漢字名称`に対する完全一致で検索              |
| `--point`      | 点数・価格の完全一致で検索。`--point-min` / `--point-max` との同時指定時は `--point` を優先 |
| `--point-min`  | 点数・価格の下限を指定（`--point-max` と組合せて範囲検索）                                  |
| `--point-max`  | 点数・価格の上限を指定（`--point-min` と組合せて範囲検索）                                  |
| `--month`      | 検索対象のマスターの基準年月を指定。省略時は当月                                            |

## マスターのキャッシュ機構

レセ電マスターCSV は `csv/master/<年度>/` 配下にあり、receiptisan実行時には診療年月に対応する版が自動選択されますが、マスターファイルの走査は繰り返し発生し処理に時間がかかるため、高速化のためのキャッシュ機構を設けています。

### cache の事前生成

```bash
# デフォルトでは最新2年度分に限り生成
bundle exec rake master:generate_cache

# 年度を指定して生成
bundle exec rake master:generate_cache VERSION=2020

# 年度を確認する場合
bundle exec rake master:list_versions
# => 2018: 2018-04～2019-03
#    2019: 2019-04～2020-03
#    2020: 2020-04～2022-03..

# 全年度分一括で生成する場合
# (古い年度は失敗します)
VERSIONS=$(bundle exec rake master:list_versions | sed -e 's/:.*//')
for i in $VERSIONS; do echo $i; bundle exec rake master:generate_cache VERSION=$i; done
```

キャッシュファイルは `csv/master/<年度>/.cache/` 下に生成されます。

## 旧版(recediff)

電子レセプトファイルのCSV変換、CUIやVim上での部分プレビューには、下記リンクの旧版(旧名`recediff`)を利用できます。

- [v0.1.0 branch](https://github.com/yokenzan/receiptisan/tree/v0.1.0)
- [v0.1.0 release](https://github.com/yokenzan/receiptisan/releases/tag/v0.1.0)

## VSCodeからの利用

[receiptisan-vscode](https://github.com/yokenzan/receiptisan-vscode)をインストールすることで、receiptisanをバックエンドにVSCodeをレセプトのビューワとして使うことが可能です。
