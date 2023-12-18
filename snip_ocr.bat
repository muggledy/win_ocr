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

if not exist %nircmd_path% (
    echo Error: nircmd.exe not exist
    exit /b 1
)
if not exist %py_script_path% (
    echo Error: baidu_ocr.py not exist
    exit /b 1
)

if exist "%tmp_img_path%" (
    del "%tmp_img_path%"
)
if exist "%tmp_img_output_path%" (
    del "%tmp_img_output_path%"
)
%nircmd_path% clipboard clear

for /f "tokens=2 delims= " %%a in ('tasklist /fi "imagename eq SnippingTool.exe" ^| find "SnippingTool.exe"') do set "PID=%%a"
if not "%PID%"=="" (
    echo Info: kill existed SnippingTool process %PID%
    taskkill /F /PID %PID%
)

SnippingTool.exe /clip
%nircmd_path% clipboard saveimage %tmp_img_path%

if exist "%tmp_img_path%" (
    python %py_script_path% %tmp_img_path%
) else (
    echo Error: snip failed
)
if exist "%tmp_img_output_path%" (
    %nircmd_path% clipboard clear
    %nircmd_path% clipboard readfile %tmp_img_output_path%
)
