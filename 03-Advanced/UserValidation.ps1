<#
.SYNOPSIS
    User validation functions demonstrating advanced Pester testing with mocks.

.DESCRIPTION
    Level 3 - Demonstrates mocking external dependencies and advanced testing patterns.
    This module validates users and checks their status against an external API.

.NOTES
    This showcases how to test code that depends on external services.
#>

<#
.SYNOPSIS
    Validates a user email address format.

.PARAMETER Email
    The email address to validate.

.EXAMPLE
    Test-EmailFormat -Email "user@example.com"
    Returns: $true
#>
function Test-EmailFormat {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Email
    )

    # Simple email validation pattern
    $emailPattern = '^[\w\.-]+@[\w\.-]+\.\w+$'
    return $Email -match $emailPattern
}

<#
.SYNOPSIS
    Checks if a user exists in the external system (simulated).

.PARAMETER UserId
    The user ID to check.

.EXAMPLE
    Get-UserFromAPI -UserId 123
    Returns: User object if exists

.NOTES
    In real-world scenarios, this would make an HTTP call to an API.
    We'll mock this in tests to avoid external dependencies.
#>
function Get-UserFromAPI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$UserId
    )

    # Simulating an API call
    Write-Verbose "Fetching user $UserId from API..."
    
    # In reality, this would be something like:
    # Invoke-RestMethod -Uri "https://api.example.com/users/$UserId"
    
    # For demonstration, we'll simulate a response
    if ($UserId -le 0) {
        return $null
    }

    return @{
        Id = $UserId
        Name = "User$UserId"
        Email = "user$UserId@example.com"
        IsActive = $true
    }
}

<#
.SYNOPSIS
    Validates a user's status and information.

.PARAMETER UserId
    The user ID to validate.

.PARAMETER Email
    The email address to validate.

.EXAMPLE
    Test-UserValidation -UserId 123 -Email "user@example.com"
    Returns: Validation result object

.NOTES
    This function combines email validation with API checks.
#>
function Test-UserValidation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$UserId,

        [Parameter(Mandatory = $true)]
        [string]$Email
    )

    $result = @{
        UserId = $UserId
        Email = $Email
        IsValid = $false
        Errors = @()
    }

    # Validate email format
    if (-not (Test-EmailFormat -Email $Email)) {
        $result.Errors += "Invalid email format"
        return $result
    }

    # Check if user exists in system
    try {
        $user = Get-UserFromAPI -UserId $UserId
        
        if ($null -eq $user) {
            $result.Errors += "User not found"
            return $result
        }

        if (-not $user.IsActive) {
            $result.Errors += "User is not active"
            return $result
        }

        # All validations passed
        $result.IsValid = $true
        return $result
    }
    catch {
        $result.Errors += "Error accessing user API: $($_.Exception.Message)"
        return $result
    }
}

<#
.SYNOPSIS
    Sends a notification to a user (simulated).

.PARAMETER UserId
    The user ID to notify.

.PARAMETER Message
    The notification message.

.EXAMPLE
    Send-UserNotification -UserId 123 -Message "Welcome!"
    Returns: $true if successful

.NOTES
    In real scenarios, this might send an email or push notification.
    We'll mock this in tests.
#>
function Send-UserNotification {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$UserId,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Verbose "Sending notification to user $UserId - $Message"
    
    # Simulate sending notification
    # In reality: Send-MailMessage or Invoke-RestMethod
    
    return $true
}

<#
.SYNOPSIS
    Processes user registration with validation and notification.

.PARAMETER UserId
    The user ID for registration.

.PARAMETER Email
    The user's email address.

.EXAMPLE
    Register-User -UserId 123 -Email "user@example.com"
    Returns: Registration result

.NOTES
    This is a composite function that uses multiple dependencies.
#>
function Register-User {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$UserId,

        [Parameter(Mandatory = $true)]
        [string]$Email
    )

    # Validate the user
    $validation = Test-UserValidation -UserId $UserId -Email $Email

    if (-not $validation.IsValid) {
        Write-Warning "User validation failed: $($validation.Errors -join ', ')"
        return @{
            Success = $false
            Errors = $validation.Errors
        }
    }

    # Send welcome notification
    try {
        $notificationSent = Send-UserNotification -UserId $UserId -Message "Welcome to our platform!"
        
        return @{
            Success = $true
            UserId = $UserId
            Email = $Email
            NotificationSent = $notificationSent
        }
    }
    catch {
        return @{
            Success = $false
            Errors = @("Registration succeeded but notification failed: $($_.Exception.Message)")
        }
    }
}
