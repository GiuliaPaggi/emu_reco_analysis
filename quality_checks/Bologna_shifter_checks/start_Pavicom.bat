@echo off

cd /D D:\disp_local\localhost\
call D:\disp_local\localhost\run_OpTraProc.bat
echo 1/3

timeout 1

cd /D D:\disp_local\
call D:\disp_local\OpDispatch.bat
echo 2/3

timeout 1

call D:\disp_local\PAVICOM.bat
echo 3/3
