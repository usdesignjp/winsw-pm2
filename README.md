English | [日本語](./README.ja.md)

# WinSW-PM2 - making PM2 easy to use on Windows

This package bundles [WinSW] with [PM2].

## Features

* [WinSW] launches
  [`pm2 --no-daemon`](https://pm2.keymetrics.io/docs/usage/specifics/#launch-pm2-in-no-daemon)
  as a Windows service.
* The running context of [PM2] and [npm] is isolated from user profiles.

## Installation

Clone or download this repository to your development environment, then run
`npm install` to install the dependencies to the local `node_modules` folder.

> [!IMPORTANT]
> [PM2] and applications it manages need to be accessible from the security
> context of the
> [LocalService account](https://docs.microsoft.com/windows/win32/services/localservice-account).
> Furthermore, since [Node.js] looks for `node_modules` folders to find
> dependencies up to the root, more access rights are required.

## Executables

### pm2.cmd

This batch file elevates the privileges of the current user as needed and then
calls `node_modules\.bin\pm2.cmd`. While [WinSW] launches the service in the
security context of the LocalService account by default, `pm2.cmd` is usually
called by other users logged in who need administrator privileges.

Also, before making a call to the CLI, some environment variables are set the
same as in `winsw-pm2.xml` as follows:

| Name                                                                                          | Value            |
| --------------------------------------------------------------------------------------------- | ---------------- |
| [`PM2_HOME`](https://pm2.keymetrics.io/docs/usage/specifics/#multiple-pm2-on-the-same-server) | `%~dp0.pm2`      |
| `TEMP`/`TMP`                                                                                  | `%~dp0.pm2\temp` |

In addition, since [npm] runs under the account of the current user who calls
`pm2 install`, to keep the running context isolated from user profiles and
avoid conflicts, some configuration parameters are set as follows:

| Config                                                                                        | Value            |
| --------------------------------------------------------------------------------------------- | ---------------- |
| [`cache`](https://docs.npmjs.com/cli/v11/configuring-npm/folders#cache)                       | `%~dp0.npm`      |
| [`prefix`](https://docs.npmjs.com/cli/v11/configuring-npm/folders#prefix-configuration)       | `%~dp0`          |

### winsw-pm2.exe

This file is just a renamed copy of
[WinSW.NET461.exe](https://github.com/winsw/winsw/releases/download/v2.12.0/WinSW.NET461.exe).
See
[Usage](https://github.com/winsw/winsw/tree/v2.12.0#usage)
for details.

## Restrictions

### pm2 kill

Even though the process launched with `pm2 --no-daemon` can also be killed by
`pm2 kill`, in the security context of the LocalService account, the state
of the service is not updated due to an access violation error in [WinSW].
Consequently, `services.msc` and `sc.exe` say that the service is still
running.

### pm2 update

This command kills any [PM2] instance and then starts another new daemon
instead. In the security context of the LocalService account, the same
problem as with `pm2 kill` is caused.

## License

WinSW-PM2 is released under the [MIT license](./LICENSE).

[Node.js]: https://nodejs.org/
[npm]: https://www.npmjs.com/
[PM2]: https://pm2.keymetrics.io/
[WinSW]: https://github.com/winsw/winsw
