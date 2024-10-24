function New-AiderConfig {
    <#
    .SYNOPSIS
        Creates a new aider configuration with common defaults.

    .DESCRIPTION
        Creates a new aider configuration with sensible defaults.
        It's a convenience wrapper around Set-AiderConfig that sets up
        a new configuration file with commonly used settings.

    .PARAMETER ConfigFile
        Path to the configuration file. If not specified, follows standard search paths.

    .PARAMETER UseEnvFile
        When in a git repository, store API keys in .env file instead of config.

    .PARAMETER Force
        Overwrites existing configuration without prompting.

    .EXAMPLE
        New-AiderConfig -OpenAiApiKey "your-key"

        Creates a new configuration with the OpenAI API key and default settings.

    .EXAMPLE
        New-AiderConfig -UseEnvFile -AnthropicApiKey "your-key" -DarkMode

        Creates a new configuration, storing the API key in .env if in a git repo.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$OpenAiApiKey,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$AnthropicApiKey,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Model = "gpt-4",
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("diff", "whole", "patch")]
        [string]$EditFormat = "diff",
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$DarkMode,
        [Parameter()]
        [string]$ConfigFile,
        [Parameter()]
        [switch]$UseEnvFile,
        [Parameter()]
        [switch]$Force
    )

    process {
        $param = @{
            OpenAiApiKey = $OpenAiApiKey
            AnthropicApiKey = $AnthropicApiKey
            Model = $Model
            EditFormat = $EditFormat
            DarkMode = $DarkMode
            ConfigFile = $ConfigFile
            UseEnvFile = $UseEnvFile
            Force = $Force
            # Common defaults
            Pretty = $true
            Stream = $true
            Git = $true
            Gitignore = $true
            AutoLint = $true
            # Default colors
            UserInputColor = "#00cc00"
            ToolErrorColor = "#FF2222"
            ToolWarningColor = "#FFA500"
            AssistantOutputColor = "#0088ff"
        }

        Set-AiderConfig @param
    }
}
