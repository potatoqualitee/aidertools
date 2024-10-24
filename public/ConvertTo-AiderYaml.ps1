function ConvertTo-AiderYaml {
    <#
    .SYNOPSIS
        Converts a configuration object to aider YAML format.

    .DESCRIPTION
        Converts a PowerShell configuration object to aider's YAML format,
        handling special cases like API keys and boolean flags.

    .PARAMETER Config
        The configuration object to convert.

    .EXAMPLE
        $config | ConvertTo-AiderYaml

        Converts the config object to YAML format.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$Config
    )

    process {
        $yaml = "# Generated by AiderTools`n"

        # Handle API keys - only include if present
        if ($Config.openAiApiKey) {
            $yaml += "openai-api-key: $($Config.openAiApiKey)`n"
        }
        if ($Config.anthropicApiKey) {
            $yaml += "anthropic-api-key: $($Config.anthropicApiKey)`n"
        }

        # Handle model selection
        if ($Config.model) {
            $yaml += "model: $($Config.model)`n"
        }

        # Handle edit format
        if ($Config.editFormat) {
            $yaml += "edit-format: $($Config.editFormat)`n"
        }

        # Handle boolean flags - only include if true
        if ($Config.darkMode) {
            $yaml += "dark-mode: true`n"
        }
        if ($Config.lightMode) {
            $yaml += "light-mode: true`n"
        }
        if ($Config.pretty) {
            $yaml += "pretty: true`n"
        }
        if ($Config.stream) {
            $yaml += "stream: true`n"
        }
        if ($Config.showDiff) {
            $yaml += "show-diffs: true`n"
        }
        if ($Config.git) {
            $yaml += "git: true`n"
        }
        if ($Config.gitignore) {
            $yaml += "gitignore: true`n"
        }
        if ($Config.autoLint) {
            $yaml += "auto-lint: true`n"
        }
        if ($Config.autoTest) {
            $yaml += "auto-test: true`n"
        }

        # Handle colors
        if ($Config.userInputColor) {
            $yaml += "user-input-color: $($Config.userInputColor)`n"
        }
        if ($Config.toolOutputColor) {
            $yaml += "tool-output-color: $($Config.toolOutputColor)`n"
        }
        if ($Config.toolErrorColor) {
            $yaml += "tool-error-color: $($Config.toolErrorColor)`n"
        }
        if ($Config.toolWarningColor) {
            $yaml += "tool-warning-color: $($Config.toolWarningColor)`n"
        }
        if ($Config.assistantOutputColor) {
            $yaml += "assistant-output-color: $($Config.assistantOutputColor)`n"
        }

        # Handle other string settings
        if ($Config.encoding) {
            $yaml += "encoding: $($Config.encoding)`n"
        }
        if ($Config.voiceFormat) {
            $yaml += "voice-format: $($Config.voiceFormat)`n"
        }
        if ($Config.voiceLanguage) {
            $yaml += "voice-language: $($Config.voiceLanguage)`n"
        }
        if ($Config.codeTheme) {
            $yaml += "code-theme: $($Config.codeTheme)`n"
        }

        return $yaml
    }
}
