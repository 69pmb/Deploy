$properties=Get-Content deploy-properties.json | ConvertFrom-Json

For($i=1;$i -le $properties.apps.Length;$i++) 
{ 
   Write-Output "$i. $($properties.apps[$i-1].name)"
}
$app=""
Do {
	$app = Read-Host "Which app do you want to deploy ?"
} Until ($app -eq 1 -or $app -le $properties.apps.Length)

$app=$properties.apps[$app-1]
echo "Deploying $app"

$dir = Get-Location
Set-Variable -Name "workspace" -Value ((Split-Path ($dir | Select-Object -ExpandProperty Path) -Parent) + "\" + $app.name)
if ($app.type -like "*cordova*") {
	if (-not (Test-Path -Path $app.output_dir)) {
		Write-Host "Output Directory"$app.output_dir"doesn't exist" -ForegroundColor Red
		exit
	}
	Write-Host "Generating apk file" -ForegroundColor Cyan
	& ".\cordova.ps1" -name $app.name -output_dir $app.output_dir -workspace $workspace -java $properties.java_path -size $app.size
	& ".\replace.ps1" -file ($workspace + "\dist\index.html") -searched "file:///android_asset/www/" -value '/'
} else {
	Write-Host "Build angular app" -ForegroundColor Cyan
	cd $workspace
	yarn build
	cd $dir
	& ".\replace.ps1" -file ($workspace + "\dist\index.html") -searched "{{timestamp}}" -value (Get-Date -UFormat '%d/%m/%Y %Hh%M')
	Write-Host "Finish building" -ForegroundColor Green
}

Write-Host "Deploying app to NAS" -ForegroundColor Cyan
& ".\nas.ps1" -name $app.name -port $app.port -workspace $workspace -web_dir $properties.web_dir

cd $dir
pause
