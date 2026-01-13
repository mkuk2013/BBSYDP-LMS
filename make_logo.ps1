$path = "c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\assets\bbsydp_logo.png"
$out = "c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\logo_base64.txt"
certutil -encode $path $out
$lines = Get-Content $out
$validLines = $lines | Where-Object { $_ -ne "-----BEGIN CERTIFICATE-----" -and $_ -ne "-----END CERTIFICATE-----" }
$base64 = [string]::Join("", $validLines)
$finalJS = "window.bbsydpLogo = 'data:image/png;base64," + $base64 + "';"
Add-Content -Path "c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\signature.js" -Value $finalJS
Write-Host "Logo added to signature.js successfully."
