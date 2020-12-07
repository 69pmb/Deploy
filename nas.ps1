param ($name, $port, $workspace, $web_dir)

echo "name: $name"
echo "port: $port"
echo "workspace: $workspace"

$dir = Get-Location
Set-Variable -Name "web" -Value ($web_dir + "\" + $name)

rm -r -fo ($web + "\dist")
Copy-Item -Force -Path ($workspace + "\dist") -Destination $web -Recurse
Write-Host "Finish copying" -ForegroundColor Green

$server = $web + "\server.js"
if (-not (Test-Path -Path $server)) {
	Copy-Item -Path server.js -Destination $web
	& ".\replace.ps1" -file $server -searched "{{port}}" -value $port
}
$package = $web + "\package.json"
if (-not (Test-Path -Path $package)) {
	Copy-Item -Path package.json -Destination $web
	& ".\replace.ps1" -file $package -searched "{{name}}" -value $name
}
if (-not (Test-Path -Path "node_modules")) {
	cd $web
	yarn
	cd $dir
}

# Logging result
if((Get-Item ($web + "\dist\*")).length -lt 8) {
	Write-Host "AN ERROR OCCURRED" -ForegroundColor Red
} else {
	Write-Host "APP SUCCESSFULLY DEPLOYED" -ForegroundColor Green
}
