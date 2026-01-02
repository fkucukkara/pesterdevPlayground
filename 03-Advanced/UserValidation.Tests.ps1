<#
.SYNOPSIS
    Pester tests for UserValidation module.

.DESCRIPTION
    Level 3 Tests - Demonstrates:
    - Mocking functions to isolate tests
    - Mock assertions (verifying mocks were called)
    - Testing functions with external dependencies
    - Advanced Context usage for different scenarios
    - BeforeEach for test setup
#>

BeforeAll {
    # Dot-source the functions to test
    . $PSScriptRoot/UserValidation.ps1
}

Describe 'UserValidation Module' {
    
    Context 'Test-EmailFormat' {
        It 'Validates correct email: <Email>' -TestCases @(
            @{ Email = 'user@example.com' }
            @{ Email = 'test.user@domain.co.uk' }
            @{ Email = 'user123@test-domain.com' }
            @{ Email = 'first.last@company.org' }
        ) {
            param($Email)
            
            $result = Test-EmailFormat -Email $Email
            $result | Should -Be $true
        }

        It 'Rejects invalid email: <Email>' -TestCases @(
            @{ Email = 'notanemail' }
            @{ Email = '@example.com' }
            @{ Email = 'user@' }
            @{ Email = 'user @example.com' }
        ) {
            param($Email)
            
            $result = Test-EmailFormat -Email $Email
            $result | Should -Be $false
        }
    }

    Context 'Get-UserFromAPI' {
        It 'Returns user object for valid user ID' {
            $result = Get-UserFromAPI -UserId 123
            
            $result | Should -Not -BeNullOrEmpty
            $result.Id | Should -Be 123
            $result.Name | Should -Be 'User123'
            $result.Email | Should -Match '@example.com'
        }

        It 'Returns null for invalid user ID' {
            $result = Get-UserFromAPI -UserId -1
            $result | Should -BeNullOrEmpty
        }

        It 'Returns active user by default' {
            $result = Get-UserFromAPI -UserId 100
            $result.IsActive | Should -Be $true
        }
    }

    Context 'Test-UserValidation - Without Mocks' {
        # These tests use the real Get-UserFromAPI function
        
        It 'Returns valid result for correct user and email' {
            $result = Test-UserValidation -UserId 50 -Email 'test@example.com'
            
            $result.IsValid | Should -Be $true
            $result.Errors.Count | Should -Be 0
        }

        It 'Returns invalid for bad email format' {
            $result = Test-UserValidation -UserId 50 -Email 'bademail'
            
            $result.IsValid | Should -Be $false
            $result.Errors | Should -Contain 'Invalid email format'
        }

        It 'Returns invalid for non-existent user' {
            $result = Test-UserValidation -UserId -1 -Email 'test@example.com'
            
            $result.IsValid | Should -Be $false
            $result.Errors | Should -Contain 'User not found'
        }
    }

    Context 'Test-UserValidation - With Mocks' {
        # These tests mock Get-UserFromAPI to control the behavior
        
        BeforeEach {
            # This runs before each test in this context
            # We'll set up default mocks that can be overridden per test
        }

        It 'Handles API returning null user' {
            # Mock the API call to return null
            Mock Get-UserFromAPI { return $null }
            
            $result = Test-UserValidation -UserId 999 -Email 'test@example.com'
            
            $result.IsValid | Should -Be $false
            $result.Errors | Should -Contain 'User not found'
            
            # Verify the mock was called with correct parameters
            Should -Invoke Get-UserFromAPI -Exactly 1 -ParameterFilter { $UserId -eq 999 }
        }

        It 'Handles inactive user from API' {
            # Mock the API to return an inactive user
            Mock Get-UserFromAPI {
                return @{
                    Id = 123
                    Name = 'InactiveUser'
                    Email = 'inactive@example.com'
                    IsActive = $false
                }
            }
            
            $result = Test-UserValidation -UserId 123 -Email 'test@example.com'
            
            $result.IsValid | Should -Be $false
            $result.Errors | Should -Contain 'User is not active'
        }

        It 'Handles API throwing exception' {
            # Mock the API to throw an error
            Mock Get-UserFromAPI { throw "API connection failed" }
            
            $result = Test-UserValidation -UserId 123 -Email 'test@example.com'
            
            $result.IsValid | Should -Be $false
            $result.Errors | Should -BeLike '*Error accessing user API*'
        }

        It 'Successfully validates when all conditions are met' {
            # Mock the API to return a valid active user
            Mock Get-UserFromAPI {
                return @{
                    Id = 456
                    Name = 'ValidUser'
                    Email = 'valid@example.com'
                    IsActive = $true
                }
            }
            
            $result = Test-UserValidation -UserId 456 -Email 'valid@example.com'
            
            $result.IsValid | Should -Be $true
            $result.Errors.Count | Should -Be 0
            
            # Verify the mock was called
            Should -Invoke Get-UserFromAPI -Times 1
        }
    }

    Context 'Send-UserNotification' {
        It 'Returns true on successful notification' {
            $result = Send-UserNotification -UserId 123 -Message 'Test message'
            $result | Should -Be $true
        }

        It 'Accepts various message types' -TestCases @(
            @{ Message = 'Short' }
            @{ Message = 'A longer message with multiple words' }
            @{ Message = 'Message with special chars: !@#$%' }
        ) {
            param($Message)
            
            $result = Send-UserNotification -UserId 1 -Message $Message
            $result | Should -Be $true
        }
    }

    Context 'Register-User - Integration with Mocks' {
        # This tests the complete registration flow with controlled dependencies
        
        BeforeEach {
            # Setup default mocks for each test
            Mock Get-UserFromAPI {
                return @{
                    Id = $UserId
                    Name = "User$UserId"
                    Email = "user@example.com"
                    IsActive = $true
                }
            }
            
            Mock Send-UserNotification { return $true }
        }

        It 'Successfully registers valid user' {
            $result = Register-User -UserId 100 -Email 'newuser@example.com'
            
            $result.Success | Should -Be $true
            $result.UserId | Should -Be 100
            $result.Email | Should -Be 'newuser@example.com'
            $result.NotificationSent | Should -Be $true
            
            # Verify all dependencies were called
            Should -Invoke Get-UserFromAPI -Times 1
            Should -Invoke Send-UserNotification -Times 1
        }

        It 'Fails registration for invalid email' {
            $result = Register-User -UserId 100 -Email 'invalid-email'
            
            $result.Success | Should -Be $false
            $result.Errors | Should -Contain 'Invalid email format'
            
            # Notification should not be sent if validation fails
            Should -Invoke Send-UserNotification -Times 0
        }

        It 'Fails registration when user not found' {
            # Override the default mock for this test
            Mock Get-UserFromAPI { return $null }
            
            $result = Register-User -UserId 999 -Email 'test@example.com'
            
            $result.Success | Should -Be $false
            $result.Errors | Should -Contain 'User not found'
            
            # Notification should not be sent
            Should -Invoke Send-UserNotification -Times 0
        }

        It 'Handles notification failure gracefully' {
            # Override notification mock to throw error
            Mock Send-UserNotification { throw "Email service unavailable" }
            
            $result = Register-User -UserId 100 -Email 'test@example.com'
            
            $result.Success | Should -Be $false
            $result.Errors[0] | Should -BeLike '*notification failed*'
        }

        It 'Calls API before sending notification' {
            # Using script scope to track call order
            $script:callOrder = @()
            
            Mock Get-UserFromAPI {
                $script:callOrder += 'API'
                return @{ Id = 1; Name = 'User'; Email = 'user@example.com'; IsActive = $true }
            }
            
            Mock Send-UserNotification {
                $script:callOrder += 'Notification'
                return $true
            }
            
            Register-User -UserId 1 -Email 'test@example.com'
            
            # Verify order of operations
            $script:callOrder[0] | Should -Be 'API'
            $script:callOrder[1] | Should -Be 'Notification'
        }
    }
}
