<#
    Logs output to file "$logFile" (must be declared in main script).

    Author: Some guy on the internet.

#>


Filter Log-This {
    (Get-Date).ToString("yyyyMMdd_hhmmss_fff") + ": " + $_ |
        Tee-Object -FilePath $logFile -Append
}