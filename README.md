<p align="center"><img src="assets/icon.png" width="160" alt="torne再起動 アイコン"></p>

# torne relaunch

Mac で **torne® mobile** が「Dock のアイコンを押しても開かない」ときに、ワンクリックで開き直せるようにする小さなアプリです。
ダウンロードしてアプリケーションフォルダに入れるだけで使えます。

> 本アプリは個人が作成した非公式ツールです。株式会社ソニー・インタラクティブエンタテインメントおよび関連会社とは一切関係ありません。torne は同社の登録商標です。

## こんな症状の人向け

- torne mobile をウィンドウの ×（閉じる）で閉じたあと、Dock のアイコンを押しても**何も起きない**
- Mac を再起動すると、また開けるようになる

Mac 版の torne mobile は iPhone/iPad 版アプリをそのまま動かしているため、× で閉じても**アプリ本体が裏で動き続けます**。その状態だとアイコンを押しても「起動中」と扱われ、ウィンドウが出てきません。

「torne再起動」を開くと、裏に残っている torne を終了してから、あらためて torne mobile を開きます。torne が動いていないときに開いた場合は、普通に torne が起動するだけです。

## インストール

1. [Releases](https://github.com/yoshioka440/torne-relaunch/releases/latest) から `torne-relaunch.zip` をダウンロード
2. zip を開くと「torne再起動」が出てくるので、**アプリケーション** フォルダにドラッグ
3. （おすすめ）アプリケーションフォルダの「torne再起動」を **Dock にドラッグ**して、torne の代わりにこちらから開く

### はじめて開くとき（「開いていません」と表示された場合）

初めて開くと、次のようなメッセージが表示されます。

> “torne再起動.app”は開いていません
> Appleは、“torne再起動.app”にMacに損害を与えたり、プライバシーを侵害する可能性のあるマルウェアが含まれていないことを検証できませんでした。

これはアプリが壊れているわけではなく、Apple の公証（有料の開発者登録が必要）を受けていないアプリを初めて開いたときに必ず出る表示です。次の手順で**一度だけ**許可してください。

1. メッセージは **完了** を押して閉じる（「ゴミ箱に入れる」は押さないでください）
2. **システム設定**（画面左上の Apple メニュー → システム設定…）を開く
3. 左の一覧から **プライバシーとセキュリティ** を選ぶ
4. 右側を下にスクロールし、「セキュリティ」欄の「“torne再起動.app”は Mac を保護するためにブロックされました」の横にある **このまま開く** を押す
5. もう一度確認が出たら **このまま開く** を押し、パスワード（または Touch ID）で許可

2回目以降は普通にダブルクリックで開けます。

> **「このまま開く」が見当たらないとき**
> 許可のボタンは、ブロックされてから約1時間だけ表示されます。もう一度「torne再起動」をダブルクリックしてメッセージを出してから、システム設定を開き直してください。

#### ターミナルで許可する場合

ターミナルが使える方は、次の1行でも同じことができます（ダウンロード時に付く「隔離」の印を外します）。

```sh
xattr -dr com.apple.quarantine /Applications/torne再起動.app
```

アプリが何をしているかは、下の「[アプリの中身](#アプリの中身)」で全文を確認できます。

## アプリの中身

「torne再起動.app」の実体は、次のシェルスクリプト（[`scripts/launch`](scripts/launch)）だけです。ネットワーク通信やファイルの書き込みは一切行いません。

```bash
#!/bin/bash
# torne mobile (Mac) を開き直すランチャー
# ウィンドウを閉じても裏に残る torneplus プロセスを終了してから起動する

BUNDLE_ID="com.playstation.tornemobile"
PROCESS="torneplus"

killall "$PROCESS" 2>/dev/null

# 終了を最大5秒待つ
for _ in $(seq 1 20); do
  pgrep -x "$PROCESS" >/dev/null || break
  sleep 0.25
done

open -b "$BUNDLE_ID"
```

| 部分 | していること |
| --- | --- |
| `BUNDLE_ID` / `PROCESS` | torne mobile のアプリ ID と、実際に動いているプロセス名（`torneplus`）。Mac 版 torne はアプリ名と中身のプロセス名が異なります |
| `killall "$PROCESS"` | 裏に残っている torne を終了します。動いていなければ何もしません（エラー表示は捨てています） |
| `for … pgrep … sleep` | torne が完全に終了するまで、0.25 秒おきに最大 20 回（5 秒）確認します。終了前に起動すると、また開かない状態になるためです |
| `open -b "$BUNDLE_ID"` | アプリ ID を指定して torne mobile を開きます。アプリ名に「®」が含まれるため、名前ではなく ID で指定しています |

`.app` の残りは、アプリ名やアイコンを指定する `Info.plist` とアイコン画像（`AppIcon.icns`）だけです。Dock にアイコンを出さずにすぐ終了するよう、`LSUIElement` を指定しています。

## アプリを使わない方法

ターミナルで次を実行しても同じことができます。

```sh
killall torneplus; open -b com.playstation.tornemobile
```

また、torne を終了するときに × ではなく **⌘ + Q**（メニューの「torne mobile」→「終了」）を使えば、この症状は起きにくくなります。

## アンインストール

アプリケーションフォルダの「torne再起動」をゴミ箱に入れるだけです。設定ファイル等は作りません。

## 動作確認環境

- Apple silicon Mac（macOS 26）
- torne® mobile（iPad 版を Mac で利用）

## ソースからビルドする

```sh
git clone https://github.com/yoshioka440/torne-relaunch.git
cd torne-relaunch
./build.sh /Applications     # 引数なしだと ~/Applications に作成
```

### 構成

```
.
├── build.sh          # .app を組み立てる
├── scripts/
│   └── launch        # アプリの中身（torne を終了 → 起動）
└── assets/
    ├── icon.png
    └── AppIcon.icns
```

## ライセンス

[MIT](LICENSE)
