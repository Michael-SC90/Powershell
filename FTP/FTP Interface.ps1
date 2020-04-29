<#
    Enables SFTP transfers.

    Must have WinSCP installed and winSCPpath variable set to location of WinSCPnet.dll.

        WinSCP .NET
            1. Navigate to https://winscp.net/eng/download.php
            2. Click "Other Downloads"
            3. Download .NET Assembly / COM Library
    
    Author: Michael Craig
    Date: 3/19/2019
    Modified: 8/27/2019
#>


function Invoke-SFTP() {

    param(
        ## Foster Focus parameters
        [string] $HostName = $(throw "Host Name must be specified."),
        [string] $UserName = $(throw "User Name must be specified."),
        [string] $Password = $(),
        [string] $SSH = $(),
        [string] $InputPath = $(throw "Local filepath must be specified."),
        [string] $OutputPath = $(throw "Remote filepath must be specified."),
        [string] $WinSCPPath = $(throw "WinSCP path must be specified."),
        [string] $LogPath = $(),
        [boolean] $NoTime = 0
    )

    $dllPath = $WinSCPPath + "WinSCPnet.dll"
    $exePath = $WinSCPPath + "WinSCP.exe"
    $iniPath = $WinSCPPath + "winscp.ini"

    Add-Type -Path $dllPath

    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        PortNumber = 22
        HostName = $HostName
        UserName = $UserName
        Password = $Password
        SshHostKeyFingerprint = $SSH
    }

    $session = New-Object WinSCP.Session -Property @{
        ExecutablePath = $exePath
        SessionLogPath = $LogPath + "WinSCP.log"
    }

    $session.AddRawConfiguration("Logging\LogFileAppend", 1)
    $session.AddRawConfiguration("Logging\LogMaxSize", 10000)
    $session.AddRawConfiguration("Logging\LogMaxCount", 10)
    $session.AddRawConfiguration("Logging\LogSensitive", 1)

    try
    {
        # Connect
        $session.Open($sessionOptions)

        # Transfer Files
        $transferOptions = New-Object WinSCP.TransferOptions
        If ($NoTime) { $transferOptions.PreserveTimestamp = $False }

        $session.PutFiles($InputPath, $OutputPath, $False, $transferOptions).Check()
    }
    catch {
        throw $Error
    }
    finally
    {
        $session.Dispose()
    }
}