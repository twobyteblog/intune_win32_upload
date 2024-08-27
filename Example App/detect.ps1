$registryKey = "HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown"
$ValueName = "bEnableGentech"

if (Test-Path $registryKey) {

    try {
        $value = Get-ItemProperty -Path $registryKey -Name $valueName -ErrorAction Stop | Select-Object -ExpandProperty $ValueName
    } catch {
        Write-Host "Value does not exist."
        exit 1
    }

}

if ( $value -eq 0 ) {
    Write-Host "Detection Successful."
    exit 0
} else {
    Write-Host "Detection failed."
    exit 1
}