@echo off
setlocal

set HVIGOR_CMD_DIR=%~dp0
set HVIGOR_DIR=%HVIGOR_CMD_DIR%hvigor

set NODE_HOME="C:\Program Files\Huawei\DevEco Studio\tools\node"
if not exist %NODE_HOME%\node.exe (
  set NODE_HOME="C:\Program Files\nodejs"
)

set NODE_PATH=%NODE_HOME%;%NODE_HOME%\node_modules;%PATH%

%NODE_HOME%\node "%HVIGOR_DIR%\hvigor\src\base\bin\hvigor.js" %*

endlocal
ENDOFBAT && echo "wrapper created"
