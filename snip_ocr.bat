@echo off

if not "%minimized%"=="" goto :minimized
set minimized=true
start /min cmd /C "%~dpnx0"
exit

:minimized
set "current_path=%CD%"
set "py_script_path=%current_path%\baidu_ocr.py"
set "tmp_img_path=%current_path%\tmp.png"
set "tmp_img_output_path=%current_path%\tmp.png.output"
set "nircmd_path=%current_path%\nircmd.exe"
set "lock_file_path=%current_path%\lockfile"
set seconds=4 2 1 1 1 1 1 1 1 1 1
set state=success
set /a seconds_total=0

echo baidu ocr...
if not exist %nircmd_path% (
    echo Error: nircmd.exe not exist!
    exit /b 1
)
if not exist %py_script_path% (
    echo Error: baidu_ocr.py not exist!
    exit /b 1
)

if exist %lock_file_path% (
    echo Error: locked, cannot re-exec snip_ocr.bat!
    exit /b 1
) else (
    echo. > %lock_file_path%
)

if exist "%tmp_img_path%" (
    del "%tmp_img_path%"
)
if exist "%tmp_img_output_path%" (
    del "%tmp_img_output_path%"
)
%nircmd_path% clipboard clear

start "" /b SnippingTool.exe /clip

for %%N in (%seconds%) do (
    set /a seconds_total+=%%N
    timeout /t %%N /nobreak
    %nircmd_path% clipboard saveimage %tmp_img_path%
    if exist "%tmp_img_path%" (
        python %py_script_path% %tmp_img_path%
        goto :exitloop
    )
)

if not exist "%tmp_img_path%" (
    echo Error: snip failed in %seconds_total% seconds!
    set state=fail
    goto :unlock
)
:exitloop
if exist "%tmp_img_output_path%" (
    %nircmd_path% clipboard clear
    %nircmd_path% clipboard readfile %tmp_img_output_path%
) else (
    echo Error: recognize failed!
    set state=fail
)
:unlock
if exist %lock_file_path% (
    del %lock_file_path%
)
if "%state%"=="fail" (
    exit /b 1
)