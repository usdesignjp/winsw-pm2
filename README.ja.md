[English](./README.md) | 日本語

# WinSW-PM2 - making PM2 easy to use on Windows

このパッケージは、[WinSW] に [PM2] をバンドルします。

## 主要機能

* [WinSW] が
  [`pm2 --no-daemon`](https://pm2.keymetrics.io/docs/usage/specifics/#launch-pm2-in-no-daemon)
  を Windows サービスとして起動
* [PM2] と [npm] の実行コンテキストをユーザープロファイルから隔離

## 導入方法

このリポジトリをクローンまたはダウンロードして開発環境に配置し、`npm install`
を実行して依存パッケージをローカルの `node_modules`
フォルダにインストールしてください。

> [!IMPORTANT]
> [PM2] とそれが管理するアプリケーションは
> [LocalService アカウント](https://docs.microsoft.com/windows/win32/services/localservice-account)
> のセキュリティコンテキストからアクセスできる必要があります。また、[Node.js]
> は依存パッケージを見つけるためにルートに向かって `node_modules`
> フォルダを検索するので、そのアクセス権がさらに必要になります。

## 実行形式

### pm2.cmd

このバッチファイルは、必要であれば現在のユーザー権限を管理者権限に昇格させ、
`node_modules\.bin\pm2.cmd` を呼び出します。既定で [WinSW] は LocalService
アカウントのセキュリティコンテキストでサービスを起動しますが、通常、`pm2.cmd`
を実行するのはログインした別のユーザーであり、管理者権限が必要になります。

CLI を呼び出す前に、`winsw-pm2.xml` と同じように環境変数が設定されます：

| Name                                                                                          | Value            |
| --------------------------------------------------------------------------------------------- | ---------------- |
| [`PM2_HOME`](https://pm2.keymetrics.io/docs/usage/specifics/#multiple-pm2-on-the-same-server) | `%~dp0.pm2`      |
| `TEMP`/`TMP`                                                                                  | `%~dp0.pm2\temp` |

また、[npm] は `pm2 install`
を呼び出したユーザーのアカウントで実行されるため、npm
のコンフィギュレーションを変更してユーザープロファイルから隔離します：

| Config                                                                                        | Value            |
| --------------------------------------------------------------------------------------------- | ---------------- |
| [`cache`](https://docs.npmjs.com/cli/v11/configuring-npm/folders#cache)                       | `%~dp0.npm`      |
| [`prefix`](https://docs.npmjs.com/cli/v11/configuring-npm/folders#prefix-configuration)       | `%~dp0`          |

### winsw-pm2.exe

このファイルは、
[WinSW.NET461.exe](https://github.com/winsw/winsw/releases/download/v2.12.0/WinSW.NET461.exe)
の名前を変えたコピーです。詳細は
[Usage](https://github.com/winsw/winsw/tree/v2.12.0#usage)
をご覧ください。

## 制約事項

### pm2 kill

`pm2 --no-daemon` で起動したプロセスもまた `pm2 kill`
で停止できますが、LocalService アカウントの場合、[WinSW]
内部で起きるアクセス違反により、サービスの状態が更新されません。
`services.msc` や `sc.exe` が表示するサービスの状態は実行中のままです。

### pm2 update

[PM2] を停止し、別の新たなデーモンを起動します。LocalService
アカウントの場合、`pm2 kill` と同じ状況に陥ります。

## 利用許諾

WinSW-PM2 は、[MIT ライセンス](./LICENSE) で提供しています。

[Node.js]: https://nodejs.org/
[npm]: https://www.npmjs.com/
[PM2]: https://pm2.keymetrics.io/
[WinSW]: https://github.com/winsw/winsw
