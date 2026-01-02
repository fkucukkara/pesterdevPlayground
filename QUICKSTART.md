# Quick Start Guide

Get up and running with this Pester tutorial in 5 minutes!

## 1️⃣ Install Pester

```powershell
# Open PowerShell as Administrator
Install-Module -Name Pester -Force -SkipPublisherCheck

# Verify installation
Import-Module Pester -PassThru
```

Expected output:
```
ModuleType Version    Name
---------- -------    ----
Script     5.x.x      Pester
```

## 2️⃣ Navigate to the Repository

```powershell
cd c:\Users\Fatih_Kucukkara\source\github\pesterdevPlayground
```

## 3️⃣ Run Your First Test

```powershell
# Run the basic greeting test
Invoke-Pester -Path .\01-Basic\Get-Greeting.Tests.ps1 -Output Detailed
```

You should see output like:
```
Starting discovery in 1 files.
Discovery finished in 45ms.

Running tests from '.\01-Basic\Get-Greeting.Tests.ps1'
Describing Get-Greeting
 Context When called with a name
   [+] Returns a greeting with the provided name 12ms (10ms|2ms)
   [+] Returns a greeting for different names 8ms (6ms|2ms)
   [+] Handles names with spaces 7ms (5ms|2ms)
 Context When called without parameters
   [+] Returns a default greeting 6ms (4ms|2ms)
   [+] Should contain "Hello" 5ms (3ms|2ms)
   [+] Should match expected pattern 5ms (3ms|2ms)
 Context When called with invalid input
   [+] Throws an error for empty string 8ms (6ms|2ms)
   [+] Throws an error for whitespace 7ms (5ms|2ms)
 Context Pipeline support
   [+] Accepts input from pipeline 6ms (4ms|2ms)
   [+] Processes multiple pipeline inputs 8ms (6ms|2ms)

Tests completed in 145ms
Tests Passed: 10, Failed: 0, Skipped: 0 NotRun: 0
```

## 4️⃣ Try Running All Tests

```powershell
# Run all tests in the repository
Invoke-Pester -Output Detailed
```

## 5️⃣ Explore a Function

Open any `.ps1` file to see the function implementation:

```powershell
# View the greeting function
Get-Content .\01-Basic\Get-Greeting.ps1

# View its tests
Get-Content .\01-Basic\Get-Greeting.Tests.ps1
```

## 6️⃣ Next Steps

Work through the levels in order:

1. **Level 1** - `01-Basic\` - Learn basic assertions
2. **Level 2** - `02-Intermediate\` - Learn parameterized tests
3. **Level 3** - `03-Advanced\` - Learn mocking
4. **Level 4** - `04-Expert\` - Learn integration tests

## 🎯 Quick Reference

### Run tests for a specific level:
```powershell
Invoke-Pester -Path .\01-Basic\ -Output Detailed
Invoke-Pester -Path .\02-Intermediate\ -Output Detailed
Invoke-Pester -Path .\03-Advanced\ -Output Detailed
Invoke-Pester -Path .\04-Expert\ -Output Detailed
```

### Run a single test file:
```powershell
Invoke-Pester -Path .\02-Intermediate\Calculator.Tests.ps1 -Output Detailed
```

### Common Pester Switches:
- `-Output Detailed` - Show all test results
- `-Output Normal` - Show summary only
- `-PassThru` - Return test results as object

## 💡 Tips

- **Read the comments** in test files - they explain concepts
- **Experiment** - Change assertions and see tests fail
- **Look at patterns** - Notice how complexity increases per level
- **Check README.md** - Contains full documentation

## ❓ Troubleshooting

### "Cannot find Pester module"
```powershell
Install-Module -Name Pester -Force -SkipPublisherCheck
```

### "Pester version conflict"
```powershell
# Uninstall old versions
Get-Module Pester -ListAvailable | Where-Object Version -lt 5.0 | Uninstall-Module

# Install latest
Install-Module -Name Pester -Force -SkipPublisherCheck
```

### "Execution policy error"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

**You're ready to learn Pester!** 🚀

Start with `01-Basic\Get-Greeting.Tests.ps1` and work your way up!
