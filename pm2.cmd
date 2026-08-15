@rem [PM2](https://pm2.keymetrics.io/)
@setlocal
@call :elevated
@if errorlevel 1 goto :pm2
@goto :runas

:elevated
@PowerShell -Command "exit [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)"
@goto :EOF

:runas
@set command="%~f0" %*
@set command=%command:\=\\%
@set command=%command:"=\"%
@PowerShell -Command "start 'cmd' '/c cd /d \"%CD:\=\\%\" & %command% & pause' -Verb RunAs"
@goto :EOF

:pm2
@rem [PM2_HOME](https://pm2.keymetrics.io/docs/usage/specifics/#multiple-pm2-on-the-same-server)
@set "PM2_HOME=%~dp0.pm2"
@set "TEMP=%~dp0.pm2\temp"
@set "TMP=%TEMP%"
@rem [npm_config_prefix](https://docs.npmjs.com/cli/v11/configuring-npm/folders#prefix-configuration)
@set "npm_config_prefix=%~dp0"
@rem [npm_config_cache](https://docs.npmjs.com/cli/v11/configuring-npm/folders#cache)
@set "npm_config_cache=%~dp0.npm"

@call "%~dp0node_modules\.bin\pm2" %*
