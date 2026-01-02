<#
.SYNOPSIS
    Pester tests for the Calculator module.

.DESCRIPTION
    Level 2 Tests - Demonstrates:
    - TestCases for parameterized testing
    - Testing multiple scenarios with less code
    - Testing edge cases
    - Testing error handling
    - Using -ForEach for data-driven tests
#>

BeforeAll {
    # Dot-source the calculator functions
    . $PSScriptRoot/Calculator.ps1
}

Describe 'Calculator Functions' {
    
    Context 'Add-Numbers' {
        # TestCases allow you to run the same test with different inputs
        It 'Adds <X> and <Y> to get <Expected>' -TestCases @(
            @{ X = 2; Y = 3; Expected = 5 }
            @{ X = 0; Y = 0; Expected = 0 }
            @{ X = -5; Y = 5; Expected = 0 }
            @{ X = -3; Y = -7; Expected = -10 }
            @{ X = 100; Y = 200; Expected = 300 }
            @{ X = 1.5; Y = 2.5; Expected = 4.0 }
        ) {
            param($X, $Y, $Expected)
            
            $result = Add-Numbers -X $X -Y $Y
            $result | Should -Be $Expected
        }

        It 'Returns correct type' {
            $result = Add-Numbers -X 1 -Y 2
            $result | Should -BeOfType [double]
        }
    }

    Context 'Subtract-Numbers' {
        It 'Subtracts <Y> from <X> to get <Expected>' -TestCases @(
            @{ X = 10; Y = 3; Expected = 7 }
            @{ X = 0; Y = 0; Expected = 0 }
            @{ X = 5; Y = 10; Expected = -5 }
            @{ X = -5; Y = -3; Expected = -2 }
            @{ X = 100.5; Y = 50.25; Expected = 50.25 }
        ) {
            param($X, $Y, $Expected)
            
            $result = Subtract-Numbers -X $X -Y $Y
            $result | Should -Be $Expected
        }
    }

    Context 'Multiply-Numbers' {
        It 'Multiplies <X> and <Y> to get <Expected>' -TestCases @(
            @{ X = 2; Y = 3; Expected = 6 }
            @{ X = 0; Y = 5; Expected = 0 }
            @{ X = -2; Y = 4; Expected = -8 }
            @{ X = -3; Y = -3; Expected = 9 }
            @{ X = 2.5; Y = 4; Expected = 10.0 }
        ) {
            param($X, $Y, $Expected)
            
            $result = Multiply-Numbers -X $X -Y $Y
            $result | Should -Be $Expected
        }

        It 'Follows commutative property (order does not matter)' {
            $result1 = Multiply-Numbers -X 7 -Y 8
            $result2 = Multiply-Numbers -X 8 -Y 7
            $result1 | Should -Be $result2
        }
    }

    Context 'Divide-Numbers' {
        It 'Divides <X> by <Y> to get <Expected>' -TestCases @(
            @{ X = 10; Y = 2; Expected = 5 }
            @{ X = 15; Y = 3; Expected = 5 }
            @{ X = 100; Y = 4; Expected = 25 }
            @{ X = -20; Y = 4; Expected = -5 }
            @{ X = -20; Y = -4; Expected = 5 }
            @{ X = 7.5; Y = 2.5; Expected = 3.0 }
        ) {
            param($X, $Y, $Expected)
            
            $result = Divide-Numbers -X $X -Y $Y
            $result | Should -Be $Expected
        }

        It 'Throws error when dividing by zero' {
            { Divide-Numbers -X 10 -Y 0 } | Should -Throw -ExpectedMessage '*divide by zero*'
        }

        It 'Handles division resulting in decimals' {
            $result = Divide-Numbers -X 10 -Y 3
            $result | Should -BeGreaterThan 3.33
            $result | Should -BeLessThan 3.34
        }
    }

    Context 'Get-Power' {
        It 'Calculates <Base> to the power of <Exponent> to get <Expected>' -TestCases @(
            @{ Base = 2; Exponent = 3; Expected = 8 }
            @{ Base = 5; Exponent = 2; Expected = 25 }
            @{ Base = 10; Exponent = 0; Expected = 1 }
            @{ Base = 2; Exponent = -1; Expected = 0.5 }
            @{ Base = 9; Exponent = 0.5; Expected = 3 }  # Square root
        ) {
            param($Base, $Exponent, $Expected)
            
            $result = Get-Power -Base $Base -Exponent $Exponent
            $result | Should -Be $Expected
        }

        It 'Returns 1 when any number is raised to power 0' -TestCases @(
            @{ Base = 5 }
            @{ Base = 100 }
            @{ Base = -7 }
        ) {
            param($Base)
            
            $result = Get-Power -Base $Base -Exponent 0
            $result | Should -Be 1
        }
    }

    Context 'Integration Tests' {
        It 'Can chain multiple operations' {
            # (5 + 3) * 2 = 16
            $sum = Add-Numbers -X 5 -Y 3
            $result = Multiply-Numbers -X $sum -Y 2
            $result | Should -Be 16
        }

        It 'Calculates complex formula: (10 + 5) / 3' {
            $sum = Add-Numbers -X 10 -Y 5
            $result = Divide-Numbers -X $sum -Y 3
            $result | Should -Be 5
        }

        It 'Verifies order of operations matters' {
            # 2 * 3 + 4 = 10
            $product = Multiply-Numbers -X 2 -Y 3
            $result1 = Add-Numbers -X $product -Y 4
            
            # 2 * (3 + 4) = 14
            $sum = Add-Numbers -X 3 -Y 4
            $result2 = Multiply-Numbers -X 2 -Y $sum
            
            $result1 | Should -Not -Be $result2
            $result1 | Should -Be 10
            $result2 | Should -Be 14
        }
    }
}
