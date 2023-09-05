# [0.3.0](https://github.com/yokenzan/receiptisan/compare/v0.2.20...v0.3.0) (2023-09-05)


### Features

* **preview:** update tags for 点数集計 12再診 ([ab99608](https://github.com/yokenzan/receiptisan/commit/ab996085ddd5de87031f9e904d049923d320fd74))
* **preview:** update tags for 点数集計 14在宅 ([42cfe46](https://github.com/yokenzan/receiptisan/commit/42cfe469a268cda1f22e3f7b15da617df988087a))
* **preview:** 外来レセプトのフォーマットテンプレートを整備 ([e4d1847](https://github.com/yokenzan/receiptisan/commit/e4d18475239343628365ec0cf3c2b41c9634b411))
* **preview:** 摘要欄の行数をレセプトの入外によって決めるよう実装 ([89d5681](https://github.com/yokenzan/receiptisan/commit/89d56817981364f10f2d024a08eb3780ba5b64f6))

## [0.2.20](https://github.com/yokenzan/receiptisan/compare/v0.2.19...v0.2.20) (2023-08-24)

## [0.2.19](https://github.com/yokenzan/receiptisan/compare/v0.2.18...v0.2.19) (2023-06-26)


### Bug Fixes

* **bug:** fix bug that master loader only load a CSV ([83fb86b](https://github.com/yokenzan/receiptisan/commit/83fb86b428f1c080429c37ba93ba266ca00fcf19))
* **bug:** fix tests ([4c2df2b](https://github.com/yokenzan/receiptisan/commit/4c2df2b1810717c0ae580f7e285161f26940175a))

## [0.2.18](https://github.com/yokenzan/receiptisan/compare/v0.2.17...v0.2.18) (2023-06-26)

## [0.2.16](https://github.com/yokenzan/receiptisan/compare/v0.2.15...v0.2.16) (2023-03-12)


### Bug Fixes

* **bug:** make parse and retrieve audit_payer ([7f7460b](https://github.com/yokenzan/receiptisan/commit/7f7460b981491a1d2ebc95e911abb4a4e517eae3))
* **refactor:** fix bug in iterating cost logic about shinryou shikibetsu ([75a955f](https://github.com/yokenzan/receiptisan/commit/75a955fa07c5bc26efd4bfaeec9c55acb70f3434))

## [0.2.15](https://github.com/yokenzan/receiptisan/compare/v0.2.14...v0.2.15) (2023-02-16)


### Bug Fixes

* **format:** コメント文がフォーマットの過程で意図せず空文字列に変更されてしまう不具合を修正 ([8036822](https://github.com/yokenzan/receiptisan/commit/8036822e53d3bac86c93f129eb27f338afeb1286))
* **parse:** 主傷病の判定が正しくおこなわれていなかった不具合を修正 ([e3023f4](https://github.com/yokenzan/receiptisan/commit/e3023f42fac0d5b844ac601725a00280eb91cb81))

## [0.2.14](https://github.com/yokenzan/receiptisan/compare/v0.2.13...v0.2.14) (2023-02-10)

## [0.2.13](https://github.com/yokenzan/receiptisan/compare/v0.2.12...v0.2.13) (2023-02-07)


### Bug Fixes

* **preview:** 医療機関所在地がない場合にプレビューの生成に失敗する不具合を修正 ([72a154c](https://github.com/yokenzan/receiptisan/commit/72a154cecdd0d75a37e9704eec30227398dd430d))

## [0.2.12](https://github.com/yokenzan/receiptisan/compare/v0.2.11...v0.2.12) (2023-02-05)

## [0.2.11](https://github.com/yokenzan/receiptisan/compare/v0.2.10...v0.2.11) (2023-02-02)


### Bug Fixes

* **format:** 点数欄に0点が表示されてしまう不具合を修正 ([b1bd9fe](https://github.com/yokenzan/receiptisan/commit/b1bd9fe7d6298c476dc998a297fbb54870ed79eb))

## [0.2.10](https://github.com/yokenzan/receiptisan/compare/v0.2.9...v0.2.10) (2023-01-31)


### Bug Fixes

* **format:** カッコ付き数字の置換処理で常に⑴を返してしまう不具合を修正 ([fa3a4c8](https://github.com/yokenzan/receiptisan/commit/fa3a4c8833452fc9a99f5465af70ab24bfadf592))

## [0.2.9](https://github.com/yokenzan/receiptisan/compare/v0.2.8...v0.2.9) (2023-01-22)


### Bug Fixes

* **parse:** fix bug failing to parse RECEIPTC.UKE by giving file path ([e6954d7](https://github.com/yokenzan/receiptisan/commit/e6954d7e4c227f528fc9f28444e353047acc836d))

## [0.2.8](https://github.com/yokenzan/receiptisan/compare/v0.2.7...v0.2.8) (2023-01-22)


### Bug Fixes

* **preview:** 入院料の点数集計欄で、病床報告コードがあると0点の行が出力されてしまう不具合を修正 ([e27a018](https://github.com/yokenzan/receiptisan/commit/e27a018a1307a591a8025505cc9f31e7b4af15e2))
