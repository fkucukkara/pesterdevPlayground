<#
.SYNOPSIS
    A simple calculator module demonstrating intermediate Pester testing.

.DESCRIPTION
    Level 2 - Demonstrates parameterized tests with TestCases.
    Provides basic arithmetic operations.

.NOTES
    This module showcases best practices for testing mathematical functions.
#>

<#
.SYNOPSIS
    Adds two numbers together.

.PARAMETER X
    The first number to add.

.PARAMETER Y
    The second number to add.

.EXAMPLE
    Add-Numbers -X 5 -Y 3
    Returns: 8
#>
function Add-Numbers {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [double]$X,

        [Parameter(Mandatory = $true)]
        [double]$Y
    )

    return $X + $Y
}

<#
.SYNOPSIS
    Subtracts the second number from the first.

.PARAMETER X
    The number to subtract from.

.PARAMETER Y
    The number to subtract.

.EXAMPLE
    Subtract-Numbers -X 10 -Y 3
    Returns: 7
#>
function Subtract-Numbers {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [double]$X,

        [Parameter(Mandatory = $true)]
        [double]$Y
    )

    return $X - $Y
}

<#
.SYNOPSIS
    Multiplies two numbers.

.PARAMETER X
    The first number to multiply.

.PARAMETER Y
    The second number to multiply.

.EXAMPLE
    Multiply-Numbers -X 4 -Y 5
    Returns: 20
#>
function Multiply-Numbers {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [double]$X,

        [Parameter(Mandatory = $true)]
        [double]$Y
    )

    return $X * $Y
}

<#
.SYNOPSIS
    Divides the first number by the second.

.PARAMETER X
    The dividend (number to be divided).

.PARAMETER Y
    The divisor (number to divide by).

.EXAMPLE
    Divide-Numbers -X 20 -Y 4
    Returns: 5

.NOTES
    Throws an error if attempting to divide by zero.
#>
function Divide-Numbers {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [double]$X,

        [Parameter(Mandatory = $true)]
        [double]$Y
    )

    if ($Y -eq 0) {
        throw "Cannot divide by zero"
    }

    return $X / $Y
}

<#
.SYNOPSIS
    Calculates the power of a number.

.PARAMETER Base
    The base number.

.PARAMETER Exponent
    The exponent to raise the base to.

.EXAMPLE
    Get-Power -Base 2 -Exponent 3
    Returns: 8
#>
function Get-Power {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [double]$Base,

        [Parameter(Mandatory = $true)]
        [double]$Exponent
    )

    return [Math]::Pow($Base, $Exponent)
}
