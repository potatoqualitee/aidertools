@{
    ModuleVersion = '0.1.0'
    GUID = 'dc50244b-e078-4ced-b629-44eb3809684f'
    Author = 'Chrissy LeMaire'
    Copyright = '(c) 2024. All rights reserved.'
    Description = 'PowerShell wrapper for aider AI pair programming tool'
    PowerShellVersion = '5.1'
    RequiredModules = @('powershell-yaml')
    FunctionsToExport = @(
        'Invoke-Aider',
        'Get-AiderConfig',
        'Set-AiderConfig',
        'New-AiderConfig'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('AI', 'genai', 'pair', 'aider')
            LicenseUri = 'https://opensource.org/licenses/MIT'
            ProjectUri = 'https://github.com/potatoqualitee/aidertools'
            ReleaseNotes = 'Initial release'
        }
    }
}
