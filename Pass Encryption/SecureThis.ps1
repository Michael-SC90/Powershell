<#
    Encrypts and Decrypts password from file. Must be decrypted by same user on same machine as when encrypted. 
#>


## Converts plain-text password to encrypted string for storing to file.
Function Set-Secured() {
    param(
        [String] $Password = $(Throw 'Password must be specified.')
    )

    $encrypted = $Password | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString

    return $encrypted
}


## Converts encrypted string to NetworkCredentials object (used when sending credentials).
Function Get-Secured() {
    param(
        [String] $Loc = $(Throw "File path must be specified."),
        [String] $Username
    )

    $pw = Get-Content $Loc | ConvertTo-SecureString
    $credentials = New-Object System.Net.NetworkCredential($Username, $pw)
    return $credentials
}