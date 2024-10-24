function Invoke-Aider {
    <#
    .SYNOPSIS
        Invokes the aider AI pair programming tool.

    .DESCRIPTION
        The Invoke-Aider function provides a PowerShell interface to the aider AI pair programming tool.
        It supports all aider CLI options and can accept files via pipeline from Get-ChildItem.

    .PARAMETER Message
        The message to send to the AI. This is the primary way to communicate your intent.

    .PARAMETER File
        The files to edit. Can be piped in from Get-ChildItem.

    .PARAMETER Model
        The AI model to use (e.g., gpt-4, claude-3-opus-20240229).

    .PARAMETER EditorModel
        The model to use for editor tasks.

    .PARAMETER NoPretty
        Disable pretty, colorized output.

    .PARAMETER NoStream
        Disable streaming responses.

    .PARAMETER YesAlways
        Always say yes to every confirmation.

    .PARAMETER CachePrompts
        Enable caching of prompts.

    .PARAMETER MapTokens
        Suggested number of tokens to use for repo map.

    .PARAMETER MapRefresh
        Control how often the repo map is refreshed.

    .PARAMETER NoAutoLint
        Disable automatic linting after changes.

    .PARAMETER AutoTest
        Enable automatic testing after changes.

    .PARAMETER ShowPrompts
        Print the system prompts and exit.

    .PARAMETER EditFormat
        Specify what edit format the LLM should use.

    .PARAMETER MessageFile
        Specify a file containing the message to send.

    .PARAMETER ReadFile
        Specify read-only files.

    .PARAMETER Encoding
        Specify the encoding for input and output.

    .EXAMPLE
        Invoke-Aider -Message "Fix the bug" -File script.ps1

        Asks aider to fix a bug in script.ps1.

    .EXAMPLE
        Get-ChildItem *.ps1 | Invoke-Aider -Message "Add error handling"

        Adds error handling to all PowerShell files in the current directory.

    .EXAMPLE
        Invoke-Aider -Message "Update API" -Model gpt-4 -NoStream

        Uses GPT-4 to update API code without streaming output.
    #>
    [CmdletBinding()]
    param(
        [string]$Message,
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string[]]$File,
        [string]$Model,
        [string]$EditorModel,
        [switch]$NoPretty,
        [switch]$NoStream,
        [switch]$YesAlways,
        [switch]$CachePrompts,
        [int]$MapTokens,
        [ValidateSet('auto', 'always', 'files', 'manual')]
        [string]$MapRefresh,
        [switch]$NoAutoLint,
        [switch]$AutoTest,
        [switch]$ShowPrompts,
        [string]$EditFormat,
        [string]$MessageFile,
        [string[]]$ReadFile,
        [ValidateSet('utf-8', 'ascii', 'unicode', 'utf-16', 'utf-32', 'utf-7')]
        [string]$Encoding,
        [string]$OpenAiApiKey,
        [string]$AnthropicApiKey,
        [switch]$Opus,
        [switch]$Sonnet,
        [switch]$Four,
        [switch]$FourO,
        [switch]$Mini,
        [switch]$FourTurbo,
        [switch]$ThreeFiveTurbo,
        [switch]$DeepSeek,
        [switch]$O1Mini,
        [switch]$O1Preview,
        [string]$ListModels,
        [string]$OpenAiApiBase,
        [string]$OpenAiApiType,
        [string]$OpenAiApiVersion,
        [string]$OpenAiApiDeploymentId,
        [string]$OpenAiOrganizationId,
        [string]$ModelSettingsFile,
        [string]$ModelMetadataFile,
        [switch]$NoVerifySsl,
        [switch]$Architect,
        [string]$WeakModel,
        [string]$EditorEditFormat,
        [switch]$NoShowModelWarnings,
        [int]$MaxChatHistoryTokens,
        [string]$EnvFile,
        [int]$CacheKeepalivePings,
        [int]$MapMultiplierNoFiles,
        [string]$InputHistoryFile,
        [string]$ChatHistoryFile,
        [switch]$RestoreChatHistory,
        [string]$LlmHistoryFile,
        [switch]$DarkMode,
        [switch]$LightMode,
        [string]$UserInputColor,
        [string]$ToolOutputColor,
        [string]$ToolErrorColor,
        [string]$ToolWarningColor,
        [string]$AssistantOutputColor,
        [string]$CompletionMenuColor,
        [string]$CompletionMenuBgColor,
        [string]$CompletionMenuCurrentColor,
        [string]$CompletionMenuCurrentBgColor,
        [string]$CodeTheme,
        [switch]$ShowDiffs,
        [switch]$NoGit,
        [switch]$NoGitignore,
        [string]$AiderIgnore,
        [switch]$SubtreeOnly,
        [switch]$NoAutoCommits,
        [switch]$NoDirtyCommits,
        [switch]$NoAttributeAuthor,
        [switch]$NoAttributeCommitter,
        [switch]$AttributeCommitMessageAuthor,
        [switch]$AttributeCommitMessageCommitter,
        [switch]$Commit,
        [string]$CommitPrompt,
        [switch]$DryRun,
        [switch]$SkipSanityCheckRepo,
        [switch]$Lint,
        [string[]]$LintCmd,
        [string]$TestCmd,
        [switch]$Test,
        [switch]$Vim,
        [string]$ChatLanguage,
        [switch]$Version,
        [switch]$JustCheckUpdate,
        [switch]$NoCheckUpdate,
        [switch]$InstallMainBranch,
        [switch]$Upgrade,
        [string]$Apply,
        [switch]$ShowRepoMap,
        [switch]$Exit,
        [string]$ConfigFile,
        [switch]$Gui,
        [switch]$NoSuggestShellCommands,
        [string]$VoiceFormat,
        [string]$VoiceLanguage
    )
    begin {
        $allFiles = @()
    }
    process {
        if ($File) {
            $allFiles += $File
        }
    }
    end {
        if (-not (Get-Command -Name aider -ErrorAction SilentlyContinue)) {
            throw "Aider executable not found at $aiderPath"
        }
        $arguments = @()

        if ($allFiles) {
            $arguments += $allFiles
        }

        if ($Message) {
            $arguments += "--message", $Message
        }

        if ($Model) {
            $arguments += "--model", $Model
        }

        if ($EditorModel) {
            $arguments += "--editor-model", $EditorModel
        }

        if ($NoPretty) {
            $arguments += "--no-pretty"
        }

        if ($NoStream) {
            $arguments += "--no-stream"
        }

        if ($YesAlways) {
            $arguments += "--yes-always"
        }

        if ($CachePrompts) {
            $arguments += "--cache-prompts"
        }

        if ($MapTokens) {
            $arguments += "--map-tokens", $MapTokens
        }

        if ($MapRefresh) {
            $arguments += "--map-refresh", $MapRefresh
        }

        if ($NoAutoLint) {
            $arguments += "--no-auto-lint"
        }

        if ($AutoTest) {
            $arguments += "--auto-test"
        }

        if ($ShowPrompts) {
            $arguments += "--show-prompts"
        }

        if ($EditFormat) {
            $arguments += "--edit-format", $EditFormat
        }

        if ($MessageFile) {
            $arguments += "--message-file", $MessageFile
        }

        if ($ReadFile) {
            foreach ($file in $ReadFile) {
                $arguments += "--read", $file
            }
        }

        if ($Encoding) {
            $arguments += "--encoding", $Encoding
        }

        if ($OpenAiApiKey) {
            $arguments += "--openai-api-key", $OpenAiApiKey
        }

        if ($AnthropicApiKey) {
            $arguments += "--anthropic-api-key", $AnthropicApiKey
        }

        if ($Opus) {
            $arguments += "--opus"
        }

        if ($Sonnet) {
            $arguments += "--sonnet"
        }

        if ($Four) {
            $arguments += "--4"
        }

        if ($FourO) {
            $arguments += "--4o"
        }

        if ($Mini) {
            $arguments += "--mini"
        }

        if ($FourTurbo) {
            $arguments += "--4-turbo"
        }

        if ($ThreeFiveTurbo) {
            $arguments += "--35turbo"
        }

        if ($DeepSeek) {
            $arguments += "--deepseek"
        }

        if ($O1Mini) {
            $arguments += "--o1-mini"
        }

        if ($O1Preview) {
            $arguments += "--o1-preview"
        }

        if ($ListModels) {
            $arguments += "--list-models", $ListModels
        }

        if ($OpenAiApiBase) {
            $arguments += "--openai-api-base", $OpenAiApiBase
        }

        if ($OpenAiApiType) {
            $arguments += "--openai-api-type", $OpenAiApiType
        }

        if ($OpenAiApiVersion) {
            $arguments += "--openai-api-version", $OpenAiApiVersion
        }

        if ($OpenAiApiDeploymentId) {
            $arguments += "--openai-api-deployment-id", $OpenAiApiDeploymentId
        }

        if ($OpenAiOrganizationId) {
            $arguments += "--openai-organization-id", $OpenAiOrganizationId
        }

        if ($ModelSettingsFile) {
            $arguments += "--model-settings-file", $ModelSettingsFile
        }

        if ($ModelMetadataFile) {
            $arguments += "--model-metadata-file", $ModelMetadataFile
        }

        if ($NoVerifySsl) {
            $arguments += "--no-verify-ssl"
        }

        if ($Architect) {
            $arguments += "--architect"
        }

        if ($WeakModel) {
            $arguments += "--weak-model", $WeakModel
        }

        if ($EditorEditFormat) {
            $arguments += "--editor-edit-format", $EditorEditFormat
        }

        if ($NoShowModelWarnings) {
            $arguments += "--no-show-model-warnings"
        }

        if ($MaxChatHistoryTokens) {
            $arguments += "--max-chat-history-tokens", $MaxChatHistoryTokens
        }

        if ($EnvFile) {
            $arguments += "--env-file", $EnvFile
        }

        if ($CacheKeepalivePings) {
            $arguments += "--cache-keepalive-pings", $CacheKeepalivePings
        }

        if ($MapMultiplierNoFiles) {
            $arguments += "--map-multiplier-no-files", $MapMultiplierNoFiles
        }

        if ($InputHistoryFile) {
            $arguments += "--input-history-file", $InputHistoryFile
        }

        if ($ChatHistoryFile) {
            $arguments += "--chat-history-file", $ChatHistoryFile
        }

        if ($RestoreChatHistory) {
            $arguments += "--restore-chat-history"
        }

        if ($LlmHistoryFile) {
            $arguments += "--llm-history-file", $LlmHistoryFile
        }

        if ($DarkMode) {
            $arguments += "--dark-mode"
        }

        if ($LightMode) {
            $arguments += "--light-mode"
        }

        if ($UserInputColor) {
            $arguments += "--user-input-color", $UserInputColor
        }

        if ($ToolOutputColor) {
            $arguments += "--tool-output-color", $ToolOutputColor
        }

        if ($ToolErrorColor) {
            $arguments += "--tool-error-color", $ToolErrorColor
        }

        if ($ToolWarningColor) {
            $arguments += "--tool-warning-color", $ToolWarningColor
        }

        if ($AssistantOutputColor) {
            $arguments += "--assistant-output-color", $AssistantOutputColor
        }

        if ($CompletionMenuColor) {
            $arguments += "--completion-menu-color", $CompletionMenuColor
        }

        if ($CompletionMenuBgColor) {
            $arguments += "--completion-menu-bg-color", $CompletionMenuBgColor
        }

        if ($CompletionMenuCurrentColor) {
            $arguments += "--completion-menu-current-color", $CompletionMenuCurrentColor
        }

        if ($CompletionMenuCurrentBgColor) {
            $arguments += "--completion-menu-current-bg-color", $CompletionMenuCurrentBgColor
        }

        if ($CodeTheme) {
            $arguments += "--code-theme", $CodeTheme
        }

        if ($ShowDiffs) {
            $arguments += "--show-diffs"
        }

        if ($NoGit) {
            $arguments += "--no-git"
        }

        if ($NoGitignore) {
            $arguments += "--no-gitignore"
        }

        if ($AiderIgnore) {
            $arguments += "--aiderignore", $AiderIgnore
        }

        if ($SubtreeOnly) {
            $arguments += "--subtree-only"
        }

        if ($NoAutoCommits) {
            $arguments += "--no-auto-commits"
        }

        if ($NoDirtyCommits) {
            $arguments += "--no-dirty-commits"
        }

        if ($NoAttributeAuthor) {
            $arguments += "--no-attribute-author"
        }

        if ($NoAttributeCommitter) {
            $arguments += "--no-attribute-committer"
        }

        if ($AttributeCommitMessageAuthor) {
            $arguments += "--attribute-commit-message-author"
        }

        if ($AttributeCommitMessageCommitter) {
            $arguments += "--attribute-commit-message-committer"
        }

        if ($Commit) {
            $arguments += "--commit"
        }

        if ($CommitPrompt) {
            $arguments += "--commit-prompt", $CommitPrompt
        }

        if ($DryRun) {
            $arguments += "--dry-run"
        }

        if ($SkipSanityCheckRepo) {
            $arguments += "--skip-sanity-check-repo"
        }

        if ($Lint) {
            $arguments += "--lint"
        }

        if ($LintCmd) {
            foreach ($cmd in $LintCmd) {
                $arguments += "--lint-cmd", $cmd
            }
        }

        if ($TestCmd) {
            $arguments += "--test-cmd", $TestCmd
        }

        if ($Test) {
            $arguments += "--test"
        }

        if ($Vim) {
            $arguments += "--vim"
        }

        if ($ChatLanguage) {
            $arguments += "--chat-language", $ChatLanguage
        }

        if ($Version) {
            $arguments += "--version"
        }

        if ($JustCheckUpdate) {
            $arguments += "--just-check-update"
        }

        if ($NoCheckUpdate) {
            $arguments += "--no-check-update"
        }

        if ($InstallMainBranch) {
            $arguments += "--install-main-branch"
        }

        if ($Upgrade) {
            $arguments += "--upgrade"
        }

        if ($Apply) {
            $arguments += "--apply", $Apply
        }

        if ($ShowRepoMap) {
            $arguments += "--show-repo-map"
        }

        if ($Exit) {
            $arguments += "--exit"
        }

        if ($ConfigFile) {
            $arguments += "--config", $ConfigFile
        }

        if ($Gui) {
            $arguments += "--gui"
        }

        if ($NoSuggestShellCommands) {
            $arguments += "--no-suggest-shell-commands"
        }

        if ($VoiceFormat) {
            $arguments += "--voice-format", $VoiceFormat
        }

        if ($VoiceLanguage) {
            $arguments += "--voice-language", $VoiceLanguage
        }

        if ($VerbosePreference -eq 'Continue' -or $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
            $arguments += "--verbose"
        }

        Write-Verbose "Executing: $aiderPath $($arguments -join ' ')"
        & $aiderPath $arguments
    }
}
