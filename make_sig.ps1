$path = "C:\Users\Hon3y Chauhan\.gemini\antigravity\brain\fb7bddb0-10ec-4eef-829e-3460c0648398\uploaded_image_base64.txt"
$out = "c:\Users\Hon3y Chauhan\Desktop\BBSYDP-LMS\signature.js"
$lines = Get-Content $path
$validLines = $lines | Where-Object { $_ -ne "-----BEGIN CERTIFICATE-----" -and $_ -ne "-----END CERTIFICATE-----" }
$base64 = [string]::Join("", $validLines)
$finalJS = "window.adminSignature = 'data:image/png;base64," + $base64 + "';"
Set-Content -Path $out -Value $finalJS
Write-Host "Signature JS created successfully."
