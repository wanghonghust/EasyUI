@echo off
call "D:\Applications\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" -arch=amd64
cmake -S f:/QP/EasyChat -B f:/QP/EasyChat/build/Desktop_Qt_6_10_3_MSVC2022_64bit-Release -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=F:/QT/6.10.3/msvc2022_64 -GNinja
