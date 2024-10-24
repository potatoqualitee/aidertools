BeforeAll {
    Import-Module $PSScriptRoot/../aidertools.psd1 -Force
    $TestConfigPath = Join-Path $TestDrive '.aider.conf.yml'
    $TestEnvPath = Join-Path $TestDrive '.env'
}

Describe 'ConvertTo-AiderYaml' {
    It 'Converts a basic configuration object to YAML' {
        $config = [PSCustomObject]@{
            model = 'gpt-4'
            darkMode = $true
            stream = $true
        }

        $yaml = $config | ConvertTo-AiderYaml
        $yaml | Should -Match 'model: gpt-4'
        $yaml | Should -Match 'dark-mode: true'
        $yaml | Should -Match 'stream: true'
    }

    It 'Handles API keys correctly' {
        $config = [PSCustomObject]@{
            openAiApiKey = 'test-key'
            anthropicApiKey = 'test-key-2'
        }

        $yaml = $config | ConvertTo-AiderYaml
        $yaml | Should -Match 'openai-api-key: test-key'
        $yaml | Should -Match 'anthropic-api-key: test-key-2'
    }

    It 'Only includes boolean flags when true' {
        $config = [PSCustomObject]@{
            darkMode = $true
            lightMode = $false
            pretty = $true
        }

        $yaml = $config | ConvertTo-AiderYaml
        $yaml | Should -Match 'dark-mode: true'
        $yaml | Should -Match 'pretty: true'
        $yaml | Should -Not -Match 'light-mode:'
    }
}

Describe 'Get-AiderConfig' {
    BeforeEach {
        Remove-Item -Path $TestConfigPath -ErrorAction SilentlyContinue
        Remove-Item -Path $TestEnvPath -ErrorAction SilentlyContinue
    }

    It 'Returns empty object when no config exists' {
        $config = Get-AiderConfig -ConfigFile $TestConfigPath
        $config | Should -BeOfType [PSCustomObject]
        $config.PSObject.Properties | Should -HaveCount 0
    }

    It 'Reads configuration from file' {
        @"
model: gpt-4
dark-mode: true
stream: true
"@ | Set-Content -Path $TestConfigPath

        $config = Get-AiderConfig -ConfigFile $TestConfigPath
        $config.model | Should -Be 'gpt-4'
        $config.darkMode | Should -Be $true
        $config.stream | Should -Be $true
    }

    It 'Masks API keys by default' {
        @"
openai-api-key: test-key
anthropic-api-key: test-key-2
"@ | Set-Content -Path $TestConfigPath

        $config = Get-AiderConfig -ConfigFile $TestConfigPath
        $config.openAiApiKey | Should -Be '********'
        $config.anthropicApiKey | Should -Be '*********'
    }

    It 'Shows API keys in plain text when requested' {
        @"
openai-api-key: test-key
anthropic-api-key: test-key-2
"@ | Set-Content -Path $TestConfigPath

        $config = Get-AiderConfig -ConfigFile $TestConfigPath -PlainText
        $config.openAiApiKey | Should -Be 'test-key'
        $config.anthropicApiKey | Should -Be 'test-key-2'
    }
}

Describe 'New-AiderConfig' {
    BeforeEach {
        Remove-Item -Path $TestConfigPath -ErrorAction SilentlyContinue
        Remove-Item -Path $TestEnvPath -ErrorAction SilentlyContinue
    }

    It 'Creates new configuration with defaults' {
        New-AiderConfig -ConfigFile $TestConfigPath -Force
        $config = Get-AiderConfig -ConfigFile $TestConfigPath

        $config.model | Should -Be 'gpt-4'
        $config.pretty | Should -Be $true
        $config.stream | Should -Be $true
        $config.git | Should -Be $true
        $config.gitignore | Should -Be $true
        $config.autoLint | Should -Be $true
    }

    It 'Creates configuration with custom settings' {
        New-AiderConfig -ConfigFile $TestConfigPath -Model 'gpt-4-turbo' -DarkMode -Force
        $config = Get-AiderConfig -ConfigFile $TestConfigPath

        $config.model | Should -Be 'gpt-4-turbo'
        $config.darkMode | Should -Be $true
    }

    It 'Stores API keys in config by default' {
        New-AiderConfig -ConfigFile $TestConfigPath -OpenAiApiKey 'test-key' -Force
        $config = Get-AiderConfig -ConfigFile $TestConfigPath -PlainText

        $config.openAiApiKey | Should -Be 'test-key'
    }
}

Describe 'Set-AiderConfig' {
    BeforeEach {
        Remove-Item -Path $TestConfigPath -ErrorAction SilentlyContinue
        Remove-Item -Path $TestEnvPath -ErrorAction SilentlyContinue
    }

    It 'Creates new configuration when none exists' {
        Set-AiderConfig -ConfigFile $TestConfigPath -Model 'gpt-4' -DarkMode -Force
        $config = Get-AiderConfig -ConfigFile $TestConfigPath

        $config.model | Should -Be 'gpt-4'
        $config.darkMode | Should -Be $true
    }

    It 'Updates existing configuration' {
        Set-AiderConfig -ConfigFile $TestConfigPath -Model 'gpt-4' -Force
        Set-AiderConfig -ConfigFile $TestConfigPath -DarkMode -Force

        $config = Get-AiderConfig -ConfigFile $TestConfigPath
        $config.model | Should -Be 'gpt-4'
        $config.darkMode | Should -Be $true
    }

    It 'Handles boolean parameters correctly' {
        Set-AiderConfig -ConfigFile $TestConfigPath -Git:$false -AutoCommits:$false -Force
        $config = Get-AiderConfig -ConfigFile $TestConfigPath

        $config.git | Should -Be $false
        $config.autoCommits | Should -Be $false
    }

    It 'Converts parameter names to YAML format' {
        Set-AiderConfig -ConfigFile $TestConfigPath -OpenAIApiBase 'custom-url' -Force
        $content = Get-Content -Path $TestConfigPath -Raw
        $content | Should -Match 'openai-api-base: custom-url'
    }
}
