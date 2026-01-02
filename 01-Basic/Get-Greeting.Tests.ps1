<#
.SYNOPSIS
    Pester tests for the Get-Greeting function.

.DESCRIPTION
    Level 1 Tests - Demonstrates:
    - BeforeAll block for setup
    - Basic It blocks with Should assertions
    - Testing default parameters
    - Testing with different inputs
    - Testing error conditions
#>

BeforeAll {
    # Dot-source the function to test
    # $PSScriptRoot provides the directory where this test file is located
    . $PSScriptRoot/Get-Greeting.ps1
}

Describe 'Get-Greeting' {
    # Context blocks help organize related tests
    Context 'When called with a name' {
        It 'Returns a greeting with the provided name' {
            $result = Get-Greeting -Name 'Alice'
            $result | Should -Be 'Hello, Alice!'
        }

        It 'Returns a greeting for different names' {
            $result = Get-Greeting -Name 'Bob'
            $result | Should -Be 'Hello, Bob!'
        }

        It 'Handles names with spaces' {
            $result = Get-Greeting -Name 'John Doe'
            $result | Should -Be 'Hello, John Doe!'
        }
    }

    Context 'When called without parameters' {
        It 'Returns a default greeting' {
            $result = Get-Greeting
            $result | Should -Be 'Hello, World!'
        }

        It 'Should contain "Hello"' {
            $result = Get-Greeting
            $result | Should -BeLike 'Hello*'
        }

        It 'Should match expected pattern' {
            $result = Get-Greeting
            $result | Should -Match '^Hello, \w+!$'
        }
    }

    Context 'When called with invalid input' {
        It 'Throws an error for empty string' {
            { Get-Greeting -Name '' } | Should -Throw -ExpectedMessage '*cannot be empty*'
        }

        It 'Throws an error for whitespace' {
            { Get-Greeting -Name '   ' } | Should -Throw
        }
    }

    Context 'Pipeline support' {
        It 'Accepts input from pipeline' {
            $result = 'Pipeline' | Get-Greeting
            $result | Should -Be 'Hello, Pipeline!'
        }

        It 'Processes multiple pipeline inputs' {
            $results = 'Alice', 'Bob' | Get-Greeting
            $results.Count | Should -Be 2
            $results[0] | Should -Be 'Hello, Alice!'
            $results[1] | Should -Be 'Hello, Bob!'
        }
    }
}
