Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = "Images (*.png;*.jpg;*.jpeg)|*.png;*.jpg;*.jpeg"
    Title = "Select the Stamp Image"
}
$null = $FileBrowser.ShowDialog()
$ImagePath = $FileBrowser.FileName

if ($ImagePath) {
    $Bytes = [IO.File]::ReadAllBytes($ImagePath)
    $Base64 = [Convert]::ToBase64String($Bytes)
    $Ext = [IO.Path]::GetExtension($ImagePath).TrimStart('.')
    if ($Ext -eq 'jpg') { $Ext = 'jpeg' }
    
    $Base64String = "data:image/$Ext;base64,$Base64"
    
    # Update index.html
    $Content = Get-Content "index.html" -Raw
    # Regex to replace the image src
    # This regex looks for the img tag with the stamp classes or id
    # We'll use a specific marker or just replace the huge base64 src we know is there
    $NewContent = $Content -replace 'src="data:image/[^;]+;base64,[^"]+"', "src=""$Base64String"""
    
    # Be careful not to replace other images if any (like signature)
    # The signature uses id="admin-sig-img" and is loaded via JS usually, but let's be safe.
    # The stamp is in the middle div.
    
    $NewContent | Set-Content "index.html"
    
    Write-Host "Success! The stamp has been updated in index.html." -ForegroundColor Green
} else {
    Write-Host "No file selected." -ForegroundColor Yellow
}
