@echo off
call "D:\Applications\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" -arch=amd64
cmake --build f:/QP/EasyChat/build/Desktop_Qt_6_10_3_MSVC2022_64bit-Release --config Release --target EasyChat
