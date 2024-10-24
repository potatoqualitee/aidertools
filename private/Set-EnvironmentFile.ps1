function Set-EnvironmentFile {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter()]
        [string]$OpenAiApiKey,

        [Parameter()]
        [string]$AnthropicApiKey
    )

    if (-not ($OpenAiApiKey -or $AnthropicApiKey)) {
        return
    }

    $envContent = @()

    if (Test-Path -Path $Path) {
        $envContent = Get-Content -Path $Path | Where-Object {
            $PSItem -notmatch '^(OPENAI_API_KEY|ANTHROPIC_API_KEY)='
        }
    }

    if ($OpenAiApiKey) {
        $envContent += "OPENAI_API_KEY=$OpenAiApiKey"
    }

    if ($AnthropicApiKey) {
        $envContent += "ANTHROPIC_API_KEY=$AnthropicApiKey"
    }

    $envContent | Set-Content -Path $Path
}
