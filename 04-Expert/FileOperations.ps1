<#
.SYNOPSIS
    File operations module demonstrating expert-level Pester testing.

.DESCRIPTION
    Level 4 - Demonstrates testing with file I/O, setup/teardown, and integration tests.
    This module provides functions for managing configuration files.

.NOTES
    Showcases testing patterns for file system operations.
#>

<#
.SYNOPSIS
    Creates a configuration file with provided settings.

.PARAMETER Path
    The path where the configuration file should be created.

.PARAMETER Configuration
    A hashtable containing configuration key-value pairs.

.EXAMPLE
    New-ConfigurationFile -Path "C:\config.json" -Configuration @{ Setting1 = "Value1" }
    Creates a JSON configuration file

.NOTES
    Configuration is saved in JSON format.
#>
function New-ConfigurationFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [hashtable]$Configuration
    )

    try {
        # Ensure the directory exists
        $directory = Split-Path -Path $Path -Parent
        if ($directory -and -not (Test-Path -Path $directory)) {
            New-Item -Path $directory -ItemType Directory -Force | Out-Null
        }

        # Convert to JSON and save
        $json = $Configuration | ConvertTo-Json -Depth 10
        Set-Content -Path $Path -Value $json -Encoding UTF8
        
        Write-Verbose "Configuration file created at: $Path"
        return $true
    }
    catch {
        Write-Error "Failed to create configuration file: $($_.Exception.Message)"
        return $false
    }
}

<#
.SYNOPSIS
    Reads a configuration file and returns its contents.

.PARAMETER Path
    The path to the configuration file.

.EXAMPLE
    Get-ConfigurationFile -Path "C:\config.json"
    Returns: Hashtable with configuration

.NOTES
    Expects JSON format configuration files.
#>
function Get-ConfigurationFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -Path $Path)) {
        throw "Configuration file not found: $Path"
    }

    try {
        $content = Get-Content -Path $Path -Raw -Encoding UTF8
        $config = $content | ConvertFrom-Json -AsHashtable
        
        Write-Verbose "Configuration loaded from: $Path"
        return $config
    }
    catch {
        throw "Failed to read configuration file: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Updates specific settings in a configuration file.

.PARAMETER Path
    The path to the configuration file.

.PARAMETER Updates
    A hashtable containing settings to update.

.EXAMPLE
    Update-ConfigurationFile -Path "C:\config.json" -Updates @{ Setting1 = "NewValue" }
    Updates Setting1 in the configuration file

.NOTES
    Merges updates with existing configuration.
#>
function Update-ConfigurationFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [hashtable]$Updates
    )

    # Read existing configuration
    $config = Get-ConfigurationFile -Path $Path

    # Merge updates
    foreach ($key in $Updates.Keys) {
        $config[$key] = $Updates[$key]
    }

    # Save updated configuration
    $result = New-ConfigurationFile -Path $Path -Configuration $config
    
    if ($result) {
        Write-Verbose "Configuration file updated: $Path"
    }
    
    return $result
}

<#
.SYNOPSIS
    Removes a configuration file.

.PARAMETER Path
    The path to the configuration file to remove.

.EXAMPLE
    Remove-ConfigurationFile -Path "C:\config.json"
    Removes the configuration file

.NOTES
    Silently succeeds if file doesn't exist.
#>
function Remove-ConfigurationFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path -Path $Path) {
        try {
            Remove-Item -Path $Path -Force
            Write-Verbose "Configuration file removed: $Path"
            return $true
        }
        catch {
            Write-Error "Failed to remove configuration file: $($_.Exception.Message)"
            return $false
        }
    }
    else {
        Write-Verbose "Configuration file not found: $Path"
        return $true
    }
}

<#
.SYNOPSIS
    Backs up a configuration file to a specified location.

.PARAMETER SourcePath
    The path to the configuration file to backup.

.PARAMETER BackupPath
    The destination path for the backup. If not specified, creates .bak file.

.EXAMPLE
    Backup-ConfigurationFile -SourcePath "C:\config.json"
    Creates C:\config.json.bak

.NOTES
    Overwrites existing backup if it exists.
#>
function Backup-ConfigurationFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $false)]
        [string]$BackupPath
    )

    if (-not (Test-Path -Path $SourcePath)) {
        throw "Source configuration file not found: $SourcePath"
    }

    # Generate backup path if not provided
    if (-not $BackupPath) {
        $BackupPath = "$SourcePath.bak"
    }

    try {
        Copy-Item -Path $SourcePath -Destination $BackupPath -Force
        Write-Verbose "Configuration backed up to: $BackupPath"
        return $BackupPath
    }
    catch {
        throw "Failed to backup configuration file: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Validates a configuration file against a schema.

.PARAMETER Path
    The path to the configuration file.

.PARAMETER RequiredKeys
    Array of required configuration keys.

.EXAMPLE
    Test-ConfigurationFile -Path "C:\config.json" -RequiredKeys @('Server', 'Port')
    Validates that configuration contains Server and Port keys

.NOTES
    Returns validation result object.
#>
function Test-ConfigurationFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string[]]$RequiredKeys = @()
    )

    $result = @{
        IsValid = $false
        MissingKeys = @()
        Errors = @()
    }

    # Check if file exists
    if (-not (Test-Path -Path $Path)) {
        $result.Errors += "Configuration file not found"
        return $result
    }

    try {
        # Try to read the configuration
        $config = Get-ConfigurationFile -Path $Path

        # Check for required keys
        foreach ($key in $RequiredKeys) {
            if (-not $config.ContainsKey($key)) {
                $result.MissingKeys += $key
            }
        }

        # Set validity
        $result.IsValid = ($result.MissingKeys.Count -eq 0)
        
        return $result
    }
    catch {
        $result.Errors += $_.Exception.Message
        return $result
    }
}
