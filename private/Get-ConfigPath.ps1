function Get-ConfigPath {
    [CmdletBinding()]
    param()

    $configName = ".aider.conf.yml"

    # First check current directory and parents
    $currentPath = Get-Location
    while ($true) {
        $configPath = Join-Path $currentPath $configName
        if (Test-Path $configPath) {
            return $configPath
        }
        $parent = Split-Path $currentPath -Parent
        if (-not $parent -or $parent -eq $currentPath) {
            break
        }
        $currentPath = $parent
    }

    # Then check user home directory
    Join-Path $HOME $configName
}
