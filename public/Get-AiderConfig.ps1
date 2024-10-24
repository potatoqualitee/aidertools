function Get-AiderConfig {
    <#
    .SYNOPSIS
        Gets the current aider configuration.

    .DESCRIPTION
        Gets the current aider configuration from YAML files and environment.
        Can read from both global and local configuration files.
        Supports reading API keys from .env files in git repositories.

    .PARAMETER ConfigFile
        Path to the configuration file. If not specified, follows standard search paths.

    .PARAMETER PlainText
        Returns API keys in plain text instead of as masked strings.

    .EXAMPLE
        Get-AiderConfig

        Gets the current aider configuration.

    .EXAMPLE
        Get-AiderConfig -ConfigFile "~/custom-aider.yml" -PlainText

        Gets configuration from a specific file, showing API keys in plain text.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ConfigFile,
        [Parameter()]
        [switch]$PlainText
    )

    # Get configuration paths
    $paths = Get-ConfigPath -ConfigFile $ConfigFile

    if (-not $paths.ConfigPath) {
        Write-Verbose "No configuration file found"
        return [PSCustomObject]@{}
    }

    # Read YAML configuration
    try {
        $yamlContent = Get-Content -Path $paths.ConfigPath -Raw
        # Simple YAML parsing for our specific format
        $config = @{}
        $yamlContent -split "`n" | ForEach-Object {
            if ($PSItem -match '^([^#:]+):\s*(.+)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()

                # Convert YAML key format to camelCase
                $key = $key -replace '-([a-z])', { $args[0].Groups[1].Value.ToUpper() }

                # Convert string boolean values
                if ($value -eq 'true') { $value = $true }
                elseif ($value -eq 'false') { $value = $false }

                $config[$key] = $value
            }
        }
    }
    catch {
        Write-Error "Failed to read configuration file: $PSItem"
        return [PSCustomObject]@{}
    }

    # Read .env file if in a git repository
    if ($paths.EnvPath -and (Test-Path $paths.EnvPath)) {
        Get-Content -Path $paths.EnvPath | ForEach-Object {
            if ($PSItem -match '^(OPENAI_API_KEY|ANTHROPIC_API_KEY)=(.+)$') {
                $key = $matches[1]
                $value = $matches[2]

                switch ($key) {
                    'OPENAI_API_KEY' { $config['openAiApiKey'] = $value }
                    'ANTHROPIC_API_KEY' { $config['anthropicApiKey'] = $value }
                }
            }
        }
    }

    # Mask API keys unless PlainText is specified
    if (-not $PlainText) {
        if ($config.openAiApiKey) {
            $config.openAiApiKey = $config.openAiApiKey -replace '.', '*'
        }
        if ($config.anthropicApiKey) {
            $config.anthropicApiKey = $config.anthropicApiKey -replace '.', '*'
        }
    }

    # Convert to PSObject and return
    return [PSCustomObject]$config
}
