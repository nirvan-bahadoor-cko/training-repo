# reference: https://www.majorgeeks.com/content/page/how_to_check_your_windows_update_history_with_powershell.html#:~:text=Here's%20how%20it%20works.&text=Press%20the%20Windows%20Key%20%2B%20X,%2C%20installed%20date%2C%20and%20more.


Function Get-WuaHistory
{
# Get a WUA Session | Reference: https://docs.microsoft.com/en-us/windows/win32/api/wuapi/nn-wuapi-iupdatesession
$session = (New-Object -ComObject 'Microsoft.Update.Session')
# Query the latest 1000 History starting with the first record
$history = $session.QueryHistory("",0,100) | ForEach-Object {

# Make the properties hidden in com properties visible.
$_ | Add-Member -MemberType NoteProperty -Value $Result -Name Result
$Product = $_.Categories | Where-Object {$_.Type -eq 'Product'} | Select-Object -First 1 -ExpandProperty Name
$_ | Add-Member -MemberType NoteProperty -Value $Product -Name Product -PassThru
Write-Output $_
}
#Remove null records and only return the fields we want
$history | Where-Object {![String]::IsNullOrWhiteSpace($_.title)} | Select-Object Date, Title, Product
}

$today = (Get-Date)
$startDate = $today.Date.AddDays(-10)

#Get-WuaHistory

#Get-WuaHistory | where Title -Match "Security*" | where-Object { $_.Date -ge $startDate} | sort -Descending Date | Format-Table

$command_ws2019 = Get-WuaHistory | where Title -Match "Security*" | where-Object { $_.Date -ge $startDate} | sort -Descending Date | Format-Table
$command_ws2012 = Get-WuaHistory | where Title -Match "Security Monthly*" | where-Object { $_.Date -ge $startDate} | sort -Descending Date | Format-Table
#write-output $command

$windows_version = (Get-WmiObject -class Win32_OperatingSystem).Caption

if ($windows_version -eq "Microsoft Windows Server 2019 Datacenter") {
    
    if($command_ws2019){
        write-host `n$env:computername : "OK"
    }
    else{
        Write-Host `n$env:computername : "NOK"
    }

}
if ($windows_version -eq "Microsoft Windows Server 2012 R2 Standard") {
    if($command_ws2012){
        write-host `n$env:computername : "OK"
    }
    else{
        Write-Host `n$env:computername : "NOK"
    }
}
if ($windows_version -ne "Microsoft Windows Server 2012 R2 Standard" -and $windows_version -ne "Microsoft Windows Server 2019 Datacenter") {
    write-host "`nCheck Windows version on $env:computername"
}

