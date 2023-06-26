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
