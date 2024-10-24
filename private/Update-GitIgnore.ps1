function Update-GitIgnore {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter()]
        [string[]]$Pattern = @('.aider*', '.env')
    )

    if (-not (Test-Path -Path $Path)) {
        $Pattern | Set-Content -Path $Path
        return
    }

    $content = Get-Content -Path $Path
    $newPatterns = $Pattern | Where-Object { $content -notcontains $PSItem }

    if ($newPatterns) {
        $content + $newPatterns | Set-Content -Path $Path
    }
}
