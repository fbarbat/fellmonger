@echo off

echo Building in release mode
cd ..
swift build -c release --product Fellmonger -Xswiftc -diagnostic-style=llvm
if %errorlevel% neq 0 exit /b %errorlevel%

cd Installer

echo Cleaning up the previous installer build
rmdir /S /Q ..\.build\installer

echo Creating necessary directories for the new build
mkdir ..\.build\installer\dependencies

echo Copying the icon, dlls and resources
REM TODO: Remove this hardcoding to the Swift runtime
copy D:\Swift\Runtimes\0.0.0\usr\bin\*.dll ..\.build\installer\dependencies\

copy fellmonger.ico ..\.build\installer\dependencies\

copy ..\.build\release\*.dll ..\.build\installer\dependencies\

for /D %%G in (..\.build\release\*.resources) do (
    xcopy /E /I /Y "%%G" "..\.build\installer\dependencies\%%~nxG"
)

echo Creating standalone installer
wix extension add -g WixToolset.UI.wixext
wix extension add -g WixToolset.Util.wixext
wix build Application.wxs -o ..\.build\installer\FellmongerStandalone -ext WixToolset.UI.wixext -ext WixToolset.Util.wixext

echo Creating bundle installer
wix extension add -g WixToolset.BootstrapperApplications.wixext
wix build Bundle.wxs -o ..\.build\installer\Fellmonger -ext WixToolset.BootstrapperApplications.wixext

echo Done :)