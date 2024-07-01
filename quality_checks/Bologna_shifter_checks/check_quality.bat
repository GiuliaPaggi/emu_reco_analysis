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
Set Dir=D:\RUN3_W2_B%1\P%2
Set NasDir=F:\RUN3_W2_B%1\P%2
Set PavDir=D:\disp_multi_mic1
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
    xcopy %PavDir%\!PAVCameraModule.log %Dir%\%LogDir%\
    xcopy %PavDir%\!PAVGuide.log %Dir%\%LogDir%\
    xcopy %PavDir%\!PAVProcModule.log %Dir%\%LogDir%
    xcopy %PavDir%\PAVICOM.cfg %Dir%\%LogDir%\
    
    mkdir %Dir%\%LogDir%\procsrv1
    xcopy %PavDir%\procsrv1\OpTraProc_p1.cfg %Dir%\%LogDir%\procsrv1\
    xcopy %PavDir%\procsrv1\OpTraProc_p*.log %Dir%\%LogDir%\procsrv1\
    xcopy %PavDir%\procsrv1\!DispatchB.log %Dir%\%LogDir%\procsrv1\
    
    mkdir %Dir%\%LogDir%\mic1
    xcopy %PavDir%\mic1\OpTraProc_p1.cfg %Dir%\%LogDir%\mic1\
    xcopy %PavDir%\mic1\OpTraProc_p*.log %Dir%\%LogDir%\mic1\
    xcopy %PavDir%\mic1\!DispatchA.log %Dir%\%LogDir%\mic1\
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
    root -q -b tracks.raw.root check_raw.C
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
    
    xcopy %Dir%\ %NasDir%\ /D /E
    
goto e


:no 
echo ---------------------- NOT Backing up on NAS ----------------------
echo.
echo ---------------------- Renaming folder ----------------------

Set ErrorDir=%Dir%_scanError

if not exist "%ErrorDir%" (   
    echo No previous scan error
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

