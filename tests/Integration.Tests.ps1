BeforeAll {
    $ModulePath = Split-Path -Parent $PSScriptRoot
    Import-Module $ModulePath -Force
}

Describe 'AiderTools Integration Tests' {
    BeforeAll {
        $TestConfigPath = "TestDrive:\.aider.conf.yml"
        $OriginalLocation = Get-Location
        Set-Location $TestDrive
    }

    AfterAll {
        Set-Location $OriginalLocation
    }

    Context 'Configuration Management' {
        It 'Creates and validates new configuration' {
            $result = New-AiderConfig
            $result | Should -BeTrue
            Test-Path '.aider.conf.yml' | Should -BeTrue
        }

        It 'Gets configuration after creation' {
            $config = Get-AiderConfig
            $config | Should -Not -BeNull
            $config.model | Should -Be 'gpt-4'
        }

        It 'Sets and updates configuration' {
            Set-AiderConfig -Model 'gpt-3.5-turbo'
            $config = Get-AiderConfig
            $config.model | Should -Be 'gpt-3.5-turbo'
        }

        It 'Converts configuration to YAML format' {
            $yaml = ConvertTo-AiderYaml -Model 'gpt-4' -EditMode 'simple'
            $yaml | Should -Not -BeNullOrEmpty
            $yaml | Should -BeLike '*model: gpt-4*'
            $yaml | Should -BeLike '*edit_mode: simple*'
        }
    }

    Context 'Environment Setup' {
        It 'Updates .gitignore correctly' {
            '.aider*' | Out-File '.gitignore'
            $content = Get-Content '.gitignore'
            $content | Should -Contain '.aider*'
        }
    }
}
