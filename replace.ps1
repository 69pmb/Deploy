param($file, $searched, $value)

$content = Get-Content($file) -Encoding 'UTF8'
$content = $content.replace($searched, $value)
$content | out-file -Encoding 'UTF8' ($file)
