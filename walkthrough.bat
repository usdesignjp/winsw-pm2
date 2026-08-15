@if "%USERNAME%" equ "WDAGUtilityAccount" goto :sandbox

@setlocal
@cd /d %~dp0
@call :elevated
@if errorlevel 1 goto :walkthrough
@goto :runas

:elevated
@PowerShell -Command "exit [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)"
@goto :EOF
:runas
@PowerShell -Command "start 'cmd' '/c cd /d \"%CD%\" & \"%~f0\"' -Verb RunAs"
@goto :EOF
:session
@set session=None & for /f "tokens=1-6" %%a in ('tasklist ^| findstr node.exe') do @set "session=%%c"
@goto :EOF
:state
@set state=NONE & for /f "tokens=1-4" %%a in ('sc query "PM2" ^| findstr STATE') do @set "state=%%d"
@goto :EOF
:tasklist
@tasklist /fi "IMAGENAME eq node.exe"
@goto :EOF
:wait
@timeout /nobreak %1 >nul
@goto :EOF

:sandbox
@echo This batch file cannot be run in the Windows Sandbox.
@goto :finally
:walkthrough
@echo WinSW-PM2 - making PM2 easy to use on Windows
@call :state
@echo STATE: %state%
@if %state% neq NONE goto :failed
:install
.\winsw-pm2 install
@call :state
@echo STATE: %state%
@if %state% neq STOPPED goto :failed
:start
.\winsw-pm2 start
@call :state
@echo STATE: %state%
@if %state% equ RUNNING goto :RUNNING
:START_PENDING
@if %state% neq START_PENDING goto :failed
@call :wait 1
@call :state
@echo STATE: %state%
@if %state% neq RUNNING goto :START_PENDING
:RUNNING
@set polling=0
:rendezvous
@call :wait 1
@call :session
@if %session% neq None goto :ready
@set /a polling+=1
@if %polling% equ 8 goto :failed
@goto :rendezvous
:ready
@call :tasklist
@call :wait 1
start .\pm2 logs
@call :wait 1
start .\pm2 monit
@call :wait 3
@call :tasklist
@rem [@jessety/pm2-logrotate](https://github.com/jessety/pm2-logrotate)
cmd /c .\pm2 install @jessety/pm2-logrotate
cmd /c .\pm2 set @jessety/pm2-logrotate:rotateInterval "*/1 * * * *"
cmd /c .\pm2 start server.js --name %~n0 --shutdown-with-message
cmd /c .\pm2 save
curl http://localhost/
@call :wait 1
@call :tasklist
cmd /c .\pm2 delete %~n0
cmd /c .\pm2 uninstall @jessety/pm2-logrotate
cmd /c .\pm2 cleardump
@call :wait 1
@call :tasklist
:stop
.\winsw-pm2 stop
@call :state
@echo STATE: %state%
@if %state% equ STOPPED goto :STOPPED
:STOP_PENDING
@if %state% neq STOP_PENDING goto :failed
@call :wait 1
@call :state
@echo STATE: %state%
@if %state% neq STOPPED goto :STOP_PENDING
:STOPPED
@call :wait 1
@call :tasklist
:uninstall
.\winsw-pm2 uninstall
@call :state
@echo STATE: %state%
@if %state% neq NONE goto :failed
:done
@echo Done.
@goto :finally
:failed
@echo Failed.
@goto :finally
:finally
@pause
