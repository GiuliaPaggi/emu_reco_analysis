@echo off

if "%~2"=="" (
    echo Not all parameters specified. USAGE: check_quality.bat brick_number plate_number
    exit /B -1
)

echo ---------------------- Starting quality check ----------------------
echo.
echo ********************** Do not open PAVICOM yet **********************
echo.

Set Initialdir=%cd%
Set Dir=D:\RUN2_W4_B%1\P%2
Set NasDir=F:\RUN2_W4_B%1\P%2
Set PavDir=D:\disp_local
Set LogDir=PavicomLog


if not exist %Dir%\ (
    echo %Dir% not found
    exit /B -1
)

if exist %NasDir%\ (
    echo %NasDir% exist, check brick number and plate number
    exit /B -1
)

echo Entering %Dir%
cd /D %Dir%
echo pwd: %cd%
echo. 

if not exist %Dir%\%LogDir%\ (
    echo Copying log files
    mkdir %Dir%\%LogDir%\
    xcopy /q %PavDir%\!PAVCameraModule.log %Dir%\%LogDir%\
    xcopy /q %PavDir%\!PAVGuide.log %Dir%\%LogDir%\
    xcopy /q %PavDir%\!PAVProcModule.log %Dir%\%LogDir%
    xcopy /q %PavDir%\PAVICOM.cfg %Dir%\%LogDir%\
    
    mkdir %Dir%\%LogDir%\localhost
    xcopy /q %PavDir%\localhost\OpTraProc_p1.cfg %Dir%\%LogDir%\localhost\
    xcopy /q %PavDir%\localhost\OpTraProc_p*.log %Dir%\%LogDir%\localhost\

)
echo.
echo ********************** Now you can open PAVICOM and move the stage **********************
echo.

if not exist tracks.obx (
    echo tracks.obx not found. 
    exit /B -1
)

if not exist tracks.raw.root (
    echo.
    echo ---------------------- Converting .obx to .raw.root ----------------------
    C:\LASSO_X64\win32\EdbConv.exe -mode:OPERA_MT tracks.obx
) else (
    echo. 
    echo Conversion already done
)

if not exist cz.png (
    echo. 
    echo ---------------------- Doing quality plots ----------------------
    root -q -b -l tracks.raw.root check_raw.C
) else (
    echo.
    echo Quality plots already saved
)

if not exist thickness.png (
    echo.
    echo ---------------------- Checking thickness ----------------------
    root -q -l tracks.raw.root thickness.C 
) else (
    echo.
    echo Thickness plot already saved
)

:question
echo ---------------------- Evaluate data. Do you want to back up on NAS? (y/n) ----------------------



set /p dobackup=
IF /i "%dobackup%"=="y" goto yes
IF /i "%dobackup%"=="n" goto no

echo not valid
goto question

:yes 
    if exist %Dir%\thickness.png (
      del %Dir%\tracks.obx
    )
    echo ---------------------- Backing up on NAS ----------------------
    
    if exist %NasDir%\ (
        echo This folder already exist on the NAS
    ) else (
        echo Creating folder on NAS
        mkdir %NasDir%\
    )
    
    xcopy /q %Dir%\ %NasDir%\ /D /E
    
goto e


:no 
echo ---------------------- NOT Backing up on NAS ----------------------
echo.
echo ---------------------- Renaming folder ----------------------

cd ..
FOR /f %%A IN ('dir /b /ad ^|find /c "%Dir%*" ') DO SET fcount=%%A

Set ErrorDir=%Dir%_scanError%fcount%

if not exist "%ErrorDir%" (   
    cd ..
    move "%Dir%" "%ErrorDir%"
    goto e
) else (
    goto multipledir
)


:multipledir
echo There is a previous scan error. Please set the number e.g. 2 ^= ^_scanError2

set /p errornumber=
set newdir=%ErrorDir%%errornumber%
echo %newdir%
if exist "%newdir%" ( goto multipledir ) else (
cd ..
move "%Dir%" "%newdir%"
goto e
)



:e
    
cd /D %Initialdir%

echo Done

