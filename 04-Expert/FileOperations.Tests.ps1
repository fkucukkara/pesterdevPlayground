<#
.SYNOPSIS
    Pester tests for FileOperations module.

.DESCRIPTION
    Level 4 Tests - Demonstrates:
    - BeforeAll/AfterAll for test suite setup/teardown
    - BeforeEach/AfterEach for test-level setup/teardown
    - Testing file system operations
    - Creating and cleaning up test files
    - Integration testing with real file I/O
    - Testing error conditions with files
#>

BeforeAll {
    # Dot-source the functions to test
    . $PSScriptRoot/FileOperations.ps1
    
    # Create a temporary directory for all tests
    $script:TestRoot = Join-Path -Path $TestDrive -ChildPath "ConfigTests"
    New-Item -Path $script:TestRoot -ItemType Directory -Force | Out-Null
    
    Write-Host "Test suite setup: Created test directory at $script:TestRoot"
}

AfterAll {
    # Clean up the test directory after all tests complete
    if (Test-Path -Path $script:TestRoot) {
        Remove-Item -Path $script:TestRoot -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Test suite teardown: Cleaned up test directory"
    }
}

Describe 'FileOperations Module' {
    
    Context 'New-ConfigurationFile' {
        BeforeEach {
            # Create a unique test file path for each test
            $script:TestConfigPath = Join-Path -Path $script:TestRoot -ChildPath "test-config-$(Get-Random).json"
        }

        AfterEach {
            # Clean up the test file after each test
            if (Test-Path -Path $script:TestConfigPath) {
                Remove-Item -Path $script:TestConfigPath -Force
            }
        }

        It 'Creates a configuration file successfully' {
            $config = @{
                Server = 'localhost'
                Port = 8080
                Enabled = $true
            }

            $result = New-ConfigurationFile -Path $script:TestConfigPath -Configuration $config
            
            $result | Should -Be $true
            Test-Path -Path $script:TestConfigPath | Should -Be $true
        }

        It 'Creates file with correct JSON content' {
            $config = @{
                Name = 'TestApp'
                Version = '1.0.0'
            }

            New-ConfigurationFile -Path $script:TestConfigPath -Configuration $config
            
            $content = Get-Content -Path $script:TestConfigPath -Raw
            $content | Should -Not -BeNullOrEmpty
            $content | Should -BeLike '*TestApp*'
            $content | Should -BeLike '*1.0.0*'
        }

        It 'Creates directory if it does not exist' {
            $deepPath = Join-Path -Path $script:TestRoot -ChildPath "nested\folder\config.json"
            $config = @{ Test = 'Value' }

            $result = New-ConfigurationFile -Path $deepPath -Configuration $config
            
            $result | Should -Be $true
            Test-Path -Path $deepPath | Should -Be $true
            
            # Cleanup
            Remove-Item -Path (Split-Path $deepPath -Parent) -Recurse -Force
        }

        It 'Handles complex nested configuration' {
            $config = @{
                Database = @{
                    Host = 'db.example.com'
                    Port = 5432
                    Credentials = @{
                        Username = 'admin'
                        PasswordHash = 'abc123'
                    }
                }
                Features = @('Feature1', 'Feature2', 'Feature3')
            }

            $result = New-ConfigurationFile -Path $script:TestConfigPath -Configuration $config
            
            $result | Should -Be $true
            $readConfig = Get-Content -Path $script:TestConfigPath -Raw | ConvertFrom-Json
            $readConfig.Database.Host | Should -Be 'db.example.com'
            $readConfig.Features.Count | Should -Be 3
        }
    }

    Context 'Get-ConfigurationFile' {
        BeforeAll {
            # Create a test configuration file used by all tests in this context
            $script:SharedConfigPath = Join-Path -Path $script:TestRoot -ChildPath "shared-config.json"
            $script:SharedConfig = @{
                AppName = 'TestApp'
                Version = '2.0.0'
                Settings = @{
                    Debug = $true
                    Timeout = 30
                }
            }
            New-ConfigurationFile -Path $script:SharedConfigPath -Configuration $script:SharedConfig
        }

        AfterAll {
            # Clean up the shared test file
            if (Test-Path -Path $script:SharedConfigPath) {
                Remove-Item -Path $script:SharedConfigPath -Force
            }
        }

        It 'Reads configuration file successfully' {
            $config = Get-ConfigurationFile -Path $script:SharedConfigPath
            
            $config | Should -Not -BeNullOrEmpty
            $config.AppName | Should -Be 'TestApp'
            $config.Version | Should -Be '2.0.0'
        }

        It 'Returns correct data types' {
            $config = Get-ConfigurationFile -Path $script:SharedConfigPath
            
            $config.Settings.Debug | Should -BeOfType [bool]
            # In PowerShell, JSON numbers may be parsed as long or int depending on value
            ($config.Settings.Timeout -is [int] -or $config.Settings.Timeout -is [long]) | Should -Be $true
        }

        It 'Throws error for non-existent file' {
            $nonExistentPath = Join-Path -Path $script:TestRoot -ChildPath "does-not-exist.json"
            
            { Get-ConfigurationFile -Path $nonExistentPath } | Should -Throw '*not found*'
        }

        It 'Throws error for invalid JSON file' {
            $invalidPath = Join-Path -Path $script:TestRoot -ChildPath "invalid.json"
            Set-Content -Path $invalidPath -Value "{ this is not valid json }"
            
            { Get-ConfigurationFile -Path $invalidPath } | Should -Throw
            
            # Cleanup
            Remove-Item -Path $invalidPath -Force
        }
    }

    Context 'Update-ConfigurationFile' {
        BeforeEach {
            # Create a fresh configuration file before each test
            $script:UpdateConfigPath = Join-Path -Path $script:TestRoot -ChildPath "update-config-$(Get-Random).json"
            $initialConfig = @{
                Setting1 = 'Value1'
                Setting2 = 'Value2'
                Setting3 = 'Value3'
            }
            New-ConfigurationFile -Path $script:UpdateConfigPath -Configuration $initialConfig
        }

        AfterEach {
            if (Test-Path -Path $script:UpdateConfigPath) {
                Remove-Item -Path $script:UpdateConfigPath -Force
            }
        }

        It 'Updates existing setting' {
            $updates = @{ Setting1 = 'NewValue1' }
            
            $result = Update-ConfigurationFile -Path $script:UpdateConfigPath -Updates $updates
            
            $result | Should -Be $true
            $config = Get-ConfigurationFile -Path $script:UpdateConfigPath
            $config.Setting1 | Should -Be 'NewValue1'
            $config.Setting2 | Should -Be 'Value2'  # Unchanged
        }

        It 'Adds new setting' {
            $updates = @{ Setting4 = 'Value4' }
            
            Update-ConfigurationFile -Path $script:UpdateConfigPath -Updates $updates
            
            $config = Get-ConfigurationFile -Path $script:UpdateConfigPath
            $config.Setting4 | Should -Be 'Value4'
            $config.Keys.Count | Should -Be 4
        }

        It 'Updates multiple settings at once' {
            $updates = @{
                Setting1 = 'Updated1'
                Setting2 = 'Updated2'
                Setting4 = 'NewSetting'
            }
            
            Update-ConfigurationFile -Path $script:UpdateConfigPath -Updates $updates
            
            $config = Get-ConfigurationFile -Path $script:UpdateConfigPath
            $config.Setting1 | Should -Be 'Updated1'
            $config.Setting2 | Should -Be 'Updated2'
            $config.Setting3 | Should -Be 'Value3'
            $config.Setting4 | Should -Be 'NewSetting'
        }
    }

    Context 'Remove-ConfigurationFile' {
        It 'Removes existing configuration file' {
            $removePath = Join-Path -Path $script:TestRoot -ChildPath "to-remove.json"
            New-ConfigurationFile -Path $removePath -Configuration @{ Test = 'Value' }
            
            Test-Path -Path $removePath | Should -Be $true
            
            $result = Remove-ConfigurationFile -Path $removePath
            
            $result | Should -Be $true
            Test-Path -Path $removePath | Should -Be $false
        }

        It 'Succeeds when file does not exist' {
            $nonExistentPath = Join-Path -Path $script:TestRoot -ChildPath "never-existed.json"
            
            $result = Remove-ConfigurationFile -Path $nonExistentPath
            
            $result | Should -Be $true
        }

        It 'Is idempotent (can be called multiple times)' {
            $removePath = Join-Path -Path $script:TestRoot -ChildPath "idempotent-test.json"
            New-ConfigurationFile -Path $removePath -Configuration @{ Test = 'Value' }
            
            Remove-ConfigurationFile -Path $removePath | Should -Be $true
            Remove-ConfigurationFile -Path $removePath | Should -Be $true
            Remove-ConfigurationFile -Path $removePath | Should -Be $true
        }
    }

    Context 'Backup-ConfigurationFile' {
        BeforeEach {
            $script:SourcePath = Join-Path -Path $script:TestRoot -ChildPath "source-$(Get-Random).json"
            $config = @{
                Important = 'Data'
                Version = '1.0'
            }
            New-ConfigurationFile -Path $script:SourcePath -Configuration $config
        }

        AfterEach {
            # Clean up source and any backup files
            if (Test-Path -Path $script:SourcePath) {
                Remove-Item -Path $script:SourcePath -Force
            }
            Get-ChildItem -Path $script:TestRoot -Filter "*.bak" | Remove-Item -Force
        }

        It 'Creates backup file with .bak extension' {
            $backupPath = Backup-ConfigurationFile -SourcePath $script:SourcePath
            
            $backupPath | Should -Be "$($script:SourcePath).bak"
            Test-Path -Path $backupPath | Should -Be $true
        }

        It 'Backup contains same content as source' {
            $backupPath = Backup-ConfigurationFile -SourcePath $script:SourcePath
            
            $sourceConfig = Get-ConfigurationFile -Path $script:SourcePath
            $backupConfig = Get-ConfigurationFile -Path $backupPath
            
            $backupConfig.Important | Should -Be $sourceConfig.Important
            $backupConfig.Version | Should -Be $sourceConfig.Version
        }

        It 'Creates backup at custom location' {
            $customBackupPath = Join-Path -Path $script:TestRoot -ChildPath "custom-backup.json"
            
            $backupPath = Backup-ConfigurationFile -SourcePath $script:SourcePath -BackupPath $customBackupPath
            
            $backupPath | Should -Be $customBackupPath
            Test-Path -Path $customBackupPath | Should -Be $true
        }

        It 'Overwrites existing backup' {
            # Create initial backup
            $backupPath = Backup-ConfigurationFile -SourcePath $script:SourcePath
            $firstBackupTime = (Get-Item $backupPath).LastWriteTime
            
            Start-Sleep -Milliseconds 100
            
            # Update source and backup again
            Update-ConfigurationFile -Path $script:SourcePath -Updates @{ Important = 'UpdatedData' }
            Backup-ConfigurationFile -SourcePath $script:SourcePath
            
            $secondBackupTime = (Get-Item $backupPath).LastWriteTime
            $secondBackupTime | Should -BeGreaterThan $firstBackupTime
            
            $backupConfig = Get-ConfigurationFile -Path $backupPath
            $backupConfig.Important | Should -Be 'UpdatedData'
        }

        It 'Throws error when source file does not exist' {
            $nonExistentSource = Join-Path -Path $script:TestRoot -ChildPath "does-not-exist.json"
            
            { Backup-ConfigurationFile -SourcePath $nonExistentSource } | Should -Throw '*not found*'
        }
    }

    Context 'Test-ConfigurationFile' {
        BeforeAll {
            $script:ValidConfigPath = Join-Path -Path $script:TestRoot -ChildPath "valid-config.json"
            $validConfig = @{
                Server = 'localhost'
                Port = 8080
                Database = 'mydb'
                Username = 'admin'
            }
            New-ConfigurationFile -Path $script:ValidConfigPath -Configuration $validConfig
        }

        AfterAll {
            if (Test-Path -Path $script:ValidConfigPath) {
                Remove-Item -Path $script:ValidConfigPath -Force
            }
        }

        It 'Validates configuration without required keys' {
            $result = Test-ConfigurationFile -Path $script:ValidConfigPath
            
            $result.IsValid | Should -Be $true
            $result.MissingKeys.Count | Should -Be 0
            $result.Errors.Count | Should -Be 0
        }

        It 'Validates configuration with all required keys present' {
            $requiredKeys = @('Server', 'Port')
            
            $result = Test-ConfigurationFile -Path $script:ValidConfigPath -RequiredKeys $requiredKeys
            
            $result.IsValid | Should -Be $true
            $result.MissingKeys.Count | Should -Be 0
        }

        It 'Detects missing required keys' {
            $requiredKeys = @('Server', 'Port', 'MissingKey1', 'MissingKey2')
            
            $result = Test-ConfigurationFile -Path $script:ValidConfigPath -RequiredKeys $requiredKeys
            
            $result.IsValid | Should -Be $false
            $result.MissingKeys.Count | Should -Be 2
            $result.MissingKeys | Should -Contain 'MissingKey1'
            $result.MissingKeys | Should -Contain 'MissingKey2'
        }

        It 'Reports error for non-existent file' {
            $nonExistentPath = Join-Path -Path $script:TestRoot -ChildPath "missing-file.json"
            
            $result = Test-ConfigurationFile -Path $nonExistentPath
            
            $result.IsValid | Should -Be $false
            $result.Errors | Should -Contain 'Configuration file not found'
        }
    }

    Context 'Integration Tests' {
        It 'Complete workflow: Create, Read, Update, Backup, Validate, Remove' {
            $workflowPath = Join-Path -Path $script:TestRoot -ChildPath "workflow-test.json"
            
            # Step 1: Create
            $initialConfig = @{
                AppName = 'WorkflowTest'
                Version = '1.0.0'
            }
            New-ConfigurationFile -Path $workflowPath -Configuration $initialConfig
            Test-Path -Path $workflowPath | Should -Be $true
            
            # Step 2: Read
            $config = Get-ConfigurationFile -Path $workflowPath
            $config.AppName | Should -Be 'WorkflowTest'
            
            # Step 3: Update
            Update-ConfigurationFile -Path $workflowPath -Updates @{ Version = '2.0.0' }
            $updatedConfig = Get-ConfigurationFile -Path $workflowPath
            $updatedConfig.Version | Should -Be '2.0.0'
            
            # Step 4: Backup
            $backupPath = Backup-ConfigurationFile -SourcePath $workflowPath
            Test-Path -Path $backupPath | Should -Be $true
            
            # Step 5: Validate
            $validation = Test-ConfigurationFile -Path $workflowPath -RequiredKeys @('AppName', 'Version')
            $validation.IsValid | Should -Be $true
            
            # Step 6: Remove
            Remove-ConfigurationFile -Path $workflowPath
            Test-Path -Path $workflowPath | Should -Be $false
            
            # Cleanup backup
            Remove-Item -Path $backupPath -Force
        }

        It 'Handles concurrent operations on different files' {
            $paths = 1..5 | ForEach-Object {
                Join-Path -Path $script:TestRoot -ChildPath "concurrent-$_.json"
            }
            
            # Create multiple files
            foreach ($path in $paths) {
                New-ConfigurationFile -Path $path -Configuration @{ ID = $path }
            }
            
            # Verify all were created
            foreach ($path in $paths) {
                Test-Path -Path $path | Should -Be $true
            }
            
            # Read and verify
            $configs = $paths | ForEach-Object { Get-ConfigurationFile -Path $_ }
            $configs.Count | Should -Be 5
            
            # Cleanup
            $paths | ForEach-Object { Remove-ConfigurationFile -Path $_ }
        }
    }
}
