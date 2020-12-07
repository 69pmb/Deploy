param ($name, $output_dir, $workspace, $java, $size)

echo "name: $name"
echo "output_dir: $output_dir"
echo "workspace: $workspace"
echo "java: $java"
echo "size: $size"

# Set Java to 1.8
Set-Variable -Name JAVA_HOME -Value $java
Set-Item -path env:path -force -value ($JAVA_HOME + $env:path)
java -version

if((Get-Command java | Select-Object -ExpandProperty Version).Major -ne 8) {
	Write-Host "NEED JAVA 8" -ForegroundColor Red
	exit
}

# paths variables
$dir = Get-Location
Set-Variable -Name "web" -Value ("\\myNas\web\" + $name)
$apkDir = $workspace + "\cordova\" + $name + "\platforms\android\app\build\outputs\apk\debug"
cd $workspace

# Build the app
Write-Host "Build angular app" -ForegroundColor Cyan
yarn cordova

# Insert timestamp
cd $dir
& ".\replace.ps1" -file ($workspace + "\dist\index.html") -searched "{{timestamp}}" -value (Get-Date -UFormat '%d/%m/%Y %Hh%M')
cd $workspace

Write-Host "Finish building" -ForegroundColor Green

# Build the apk
$cordovaDir = "cordova\" + $name + "\www"
rm -r -fo $cordovaDir
mkdir $cordovaDir
xcopy /q /s dist $cordovaDir
Write-Host "Finish copying" -ForegroundColor Green
cd ("cordova\" + $name)
Write-Host "Build apk" -ForegroundColor Cyan
cordova build android
Write-Host "Finish generating apk" -ForegroundColor Green

# Rename, move and upload the apk to dropbox
$newName = $name + "_" + (Get-Date -UFormat '%Y.%m.%dT%H.%M.%S') + ".apk"
Rename-Item -Path ($apkDir + "\app-debug.apk") -NewName $newName
Move-Item ($apkDir + "\" + $newName) -Destination $output_dir -force

# Logging result
if((Get-Item ($output_dir + "\" + $newName)).length -lt ($size * 1KB)) {
	Write-Host "AN ERROR OCCURRED" -ForegroundColor Red
} else {
	Write-Host "APK SUCCESSFULLY GENERATED" -ForegroundColor Green
}

cd $dir
