<#
.SYNOPSIS
    A simple greeting function to demonstrate basic Pester testing.

.DESCRIPTION
    This function takes a name and returns a greeting message.
    This is Level 1 - Basic function demonstrating simple assertions.

.PARAMETER Name
    The name to greet. Defaults to 'World' if not provided.

.EXAMPLE
    Get-Greeting -Name "Alice"
    Returns: "Hello, Alice!"

.EXAMPLE
    Get-Greeting
    Returns: "Hello, World!"
#>
function Get-Greeting {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string]$Name = 'World'
    )

    process {
        # Validate that name is not empty or whitespace
        if ([string]::IsNullOrWhiteSpace($Name)) {
            throw "Name cannot be empty or whitespace"
        }

        # Return the greeting message
        return "Hello, $Name!"
    }
}
