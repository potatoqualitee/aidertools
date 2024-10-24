function Set-AiderConfig {
    <#
    .SYNOPSIS
        Sets the aider configuration.

    .DESCRIPTION
        Sets and persists the aider configuration in YAML format.
        Can set both global and local configuration.
        When in a git repository, API keys can be stored in .env file.

        Configuration can be stored in:
        - Global config: ~/.aider.conf.yml
        - Local config: .aider.conf.yml in git root
        - Environment: .env file in git root

    .PARAMETER OpenAiApiKey
        Specify the OpenAI API key.

    .PARAMETER AnthropicApiKey
        Specify the Anthropic API key.

    .PARAMETER Model
        Specify the model to use for the main chat. Default: gpt-4
        Supported models include:
        - OpenAI: gpt-4, gpt-4-turbo, gpt-3.5-turbo
        - Anthropic: claude-3-opus, claude-3-sonnet
        - Others: deepseek-coder, o1-mini, o1-preview

    .PARAMETER EditFormat
        Specify what edit format the LLM should use. Default: diff
        Valid values: diff, whole, patch

    .PARAMETER DarkMode
        Use colors suitable for a dark terminal background.

    .PARAMETER LightMode
        Use colors suitable for a light terminal background.

    .PARAMETER AutoCommit
        Enable/disable auto commit of LLM changes. Default: True

    .PARAMETER Pretty
        Enable/disable pretty, colorized output. Default: True

    .PARAMETER Stream
        Enable/disable streaming responses. Default: True

    .PARAMETER CodeTheme
        Set the markdown code theme. Default: default
        Options: default, monokai, solarized-dark, solarized-light

    .PARAMETER ShowDiff
        Show diffs when committing changes.

    .PARAMETER Git
        Enable/disable looking for a git repo. Default: True

    .PARAMETER Gitignore
        Enable/disable adding .aider* to .gitignore. Default: True

    .PARAMETER AutoLint
        Enable/disable automatic linting after changes. Default: True

    .PARAMETER AutoTest
        Enable/disable automatic testing after changes. Default: False

    .PARAMETER Encoding
        Specify the encoding for input and output. Default: utf-8

    .PARAMETER VoiceFormat
        Audio format for voice recording. Default: wav
        Options: wav, webm, mp3 (webm and mp3 require ffmpeg)

    .PARAMETER VoiceLanguage
        Specify the language for voice using ISO 639-1 code. Default: en

    .PARAMETER UserInputColor
        Set the color for user input. Default: #00cc00

    .PARAMETER ToolOutputColor
        Set the color for tool output.

    .PARAMETER ToolErrorColor
        Set the color for tool error messages. Default: #FF2222

    .PARAMETER ToolWarningColor
        Set the color for tool warning messages. Default: #FFA500

    .PARAMETER AssistantOutputColor
        Set the color for assistant output. Default: #0088ff

    .PARAMETER ConfigFile
        Path to the configuration file. If not specified, follows standard search paths:
        1. .aider.conf.yml in current directory
        2. .aider.conf.yml in git root
        3. .aider.conf.yml in user's home directory

    .PARAMETER UseEnvFile
        When in a git repository, store API keys in .env file instead of config.
        The .env file will be created in the git root directory.

    .PARAMETER Force
        Overwrites existing configuration without prompting.

    .EXAMPLE
        Set-AiderConfig -OpenAiApiKey "your-key" -Model "gpt-4"
        Sets the OpenAI API key and model in the configuration.

    .EXAMPLE
        Set-AiderConfig -UseEnvFile -OpenAiApiKey "your-key" -DarkMode
        In a git repository, stores the API key in .env and other settings in config.

    .EXAMPLE
        Set-AiderConfig -Model "claude-3-opus" -EditFormat "whole" -AutoCommit:$false
        Configures to use Claude 3 Opus model with whole file edit format and disables auto-commits.

    .EXAMPLE
        Set-AiderConfig -DarkMode -CodeTheme "monokai" -UserInputColor "#00ff00"
        Customizes the appearance with dark mode, monokai theme, and custom input color.

    .NOTES
        For more information about configuration options, visit:
        https://aider.chat/docs/configuration.html
    #>
    [CmdletBinding()]
    param(
        # Main Options
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$OpenAiApiKey,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$AnthropicApiKey,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Model = "gpt-4",
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Opus,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Sonnet,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('4')]
        [switch]$GPT4,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('4o')]
        [switch]$GPT4O,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Mini,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('4-turbo')]
        [switch]$GPT4Turbo,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('35turbo')]
        [switch]$GPT35Turbo,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Deepseek,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$O1Mini,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$O1Preview,

        # Model Settings
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$ListModels,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$OpenAIApiBase,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$OpenAIApiType,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$OpenAIApiVersion,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$OpenAIApiDeploymentId,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$OpenAIOrganizationId,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ModelSettingsFile,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ModelMetadataFile,
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$VerifySSL = $true,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("diff", "whole", "patch")]
        [string]$EditFormat = "diff",
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Architect,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$WeakModel,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$EditorModel,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$EditorEditFormat,
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$ShowModelWarnings = $true,
        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$MaxChatHistoryTokens,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$EnvFile,

        # Cache Settings
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$CachePrompts,
        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$CacheKeealivePings,

        # Repomap Settings
        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$MapTokens,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('auto', 'always', 'files', 'manual')]
        [string]$MapRefresh = 'auto',
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$MapMultiplierNoFiles = $true,

        # History Files
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$InputHistoryFile,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ChatHistoryFile,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$RestoreChatHistory,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$LLMHistoryFile,

        # Output Settings
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$DarkMode,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$LightMode,
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$Pretty = $true,
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$Stream = $true,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$UserInputColor = "#00cc00",
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ToolOutputColor,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ToolErrorColor = "#FF2222",
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ToolWarningColor = "#FFA500",
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$AssistantOutputColor = "#0088ff",
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$CompletionMenuColor,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$CompletionMenuBgColor,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$CompletionMenuCurrentColor,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$CompletionMenuCurrentBgColor,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('default', 'monokai', 'solarized-dark', 'solarized-light')]
        [string]$CodeTheme = 'default',
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$ShowDiffs,

        # Git Settings
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$Git = $true,
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$GitIgnore = $true,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$AiderIgnore,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$SubtreeOnly,
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$AutoCommits = $true,
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$DirtyCommits = $true,
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$AttributeAuthor = $true,
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$AttributeCommitter = $true,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$AttributeCommitMessageAuthor,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$AttributeCommitMessageCommitter,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Commit,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$CommitPrompt,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$DryRun,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$SkipSanityCheckRepo,

        # Fixing and Committing
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Lint,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$LintCmd,
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$AutoLint = $true,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$TestCmd,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$AutoTest,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Test,

        # Other Settings
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$File,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$Read,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Vim,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ChatLanguage,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Version,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$JustCheckUpdate,
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$CheckUpdate = $true,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$InstallMainBranch,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Upgrade,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Apply,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$YesAlways,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$ShowRepoMap,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$ShowPrompts,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Exit,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Message,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$MessageFile,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Encoding = 'utf-8',
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Config,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$GUI,
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$SuggestShellCommands = $true,

        # Voice Settings
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('wav', 'webm', 'mp3')]
        [string]$VoiceFormat = 'wav',
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$VoiceLanguage = 'en',

        # Original parameters
        [Parameter()]
        [string]$ConfigFile,
        [Parameter()]
        [switch]$UseEnvFile,
        [Parameter()]
        [switch]$Force
    )

    begin {
        $paths = Get-ConfigPath -ConfigFile $ConfigFile

        if (-not $paths.ConfigPath -and -not $Force) {
            throw "No configuration file found. Use -Force to create a new one."
        }

        # Default to first available path if none exists
        $targetPath = if ($paths.ConfigPath) {
            $paths.ConfigPath
        } else {
            $paths.DefaultConfigPaths[0]
        }

        # Create directory if needed
        $targetDir = Split-Path -Path $targetPath -Parent
        if (-not (Test-Path -Path $targetDir)) {
            $null = New-Item -Path $targetDir -ItemType Directory -Force
        }

        # Handle .gitignore if in a repo
        if ($paths.GitRoot) {
            $gitignorePath = Join-Path -Path $paths.GitRoot -ChildPath '.gitignore'
            Update-GitIgnore -Path $gitignorePath
        }
    }

    process {
        # Build config object
        $config = @{}

        $PSBoundParameters.GetEnumerator() | ForEach-Object {
            $key = $PSItem.Key
            # Convert from PowerShell style to YAML style (e.g., OpenAIApiKey to openai-api-key)
            $key = $key -replace '([a-z])([A-Z])', '$1-$2' -replace '([A-Z])([A-Z][a-z])', '$1-$2' | ForEach-Object { $PSItem.ToLower() }

            # Handle switch parameters correctly
            if ($PSItem.Value -is [System.Management.Automation.SwitchParameter]) {
                $config[$key] = $PSItem.Value.IsPresent
            }
            elseif ($null -ne $PSItem.Value) {
                $config[$key] = $PSItem.Value
            }
        }

        # Handle API keys
        if ($UseEnvFile.IsPresent -and $paths.GitRoot -and $paths.EnvPath) {
            # Store API keys in .env file
            Set-EnvironmentFile -Path $paths.EnvPath -OpenAiApiKey $OpenAiApiKey -AnthropicApiKey $AnthropicApiKey
        }
        else {
            # Store API keys in config
            if ($OpenAiApiKey) { $config['openai-api-key'] = $OpenAiApiKey }
            if ($AnthropicApiKey) { $config['anthropic-api-key'] = $AnthropicApiKey }
        }

        # Convert to YAML and save
        ConvertTo-AiderYaml -InputObject $config | Set-Content -Path $targetPath -Force:$Force.IsPresent -Encoding UTF8
    }
}