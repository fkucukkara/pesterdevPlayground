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

.EXAMPLE
    "Alice","Bob","Charlie" | Get-Greeting
    Returns: "Hello, Alice!", "Hello, Bob!", "Hello, Charlie!"
    Note: Without 'process' block, only "Hello, Charlie!" would be returned!
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

<#
DEMONSTRATION: Why 'process' block matters for pipeline input

Without process block (BAD for pipeline):
    function Greet-Bad {
        param([Parameter(ValueFromPipeline=$true)][string]$Name)
        return "Hi, $Name!"
    }
    "A","B","C" | Greet-Bad
    # Result: "Hi, C!"  (only last value!)

With process block (GOOD for pipeline):
    function Greet-Good {
        param([Parameter(ValueFromPipeline=$true)][string]$Name)
        process { return "Hi, $Name!" }
    }
    "A","B","C" | Greet-Good
    # Result: "Hi, A!", "Hi, B!", "Hi, C!"  (all values!)
#>
