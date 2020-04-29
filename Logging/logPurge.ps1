Function Purge-Logs() {
    param(
        [String] $Path = $(Throw "Log Folder Path must be specified."),
        [Int] $DaysOld = 90
    )

    gci $path -Include '*.log' -Recurse | ? LastWriteTime -LT (Get-Date).AddDays(-$DaysOld) | Remove-Item
}