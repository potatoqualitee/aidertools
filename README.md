# AiderTools

PowerShell module for managing and interacting with the [Aider AI](https://aider.chat) coding assistant. This module provides cmdlets for configuring and using Aider within PowerShell environments.

## Features

- Configure Aider settings through PowerShell
- Manage `.aider.conf.yml` configuration files
- Execute Aider commands with PowerShell parameters
- Automated environment setup and configuration

## Installation

```powershell
# Install from PowerShell Gallery (when published)
Install-Module -Name AiderTools -Scope CurrentUser

# Or clone and import manually
git clone https://github.com/username/aidertools.git
Import-Module ./aidertools/aidertools.psd1
```

## Usage

### Create New Configuration

```powershell
# Create default configuration
New-AiderConfig

# Create with custom settings
New-AiderConfig -Model gpt-4o-mini -EditMode simple
```

### Get Current Configuration

```powershell
Get-AiderConfig
```

### Update Configuration

```powershell
Set-AiderConfig -Model gpt-4 -EditMode auto
```

### Convert Settings to YAML

```powershell
ConvertTo-AiderYaml -Model gpt-4 -EditMode simple
```

### Run Aider

```powershell
Invoke-Aider -Path "path/to/project"
```

## Testing

The module includes integration tests using Pester. To run the tests:

```powershell
# Install Pester if not already installed
Install-Module -Name Pester -Force

# Run tests
Invoke-Pester ./tests
```

Tests are automatically run on push and pull request through GitHub Actions.
