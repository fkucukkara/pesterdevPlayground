# Pester Testing Playground

Welcome to the **Pester Testing Playground**! This repository provides a comprehensive, hands-on introduction to [Pester](https://pester.dev/), the testing and mocking framework for PowerShell. Whether you're new to testing or looking to improve your skills, this repo takes you from basic to expert-level testing patterns.

## 📚 Table of Contents

- [What is Pester?](#what-is-pester)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Learning Path](#learning-path)
- [Running Tests](#running-tests)
- [Best Practices](#best-practices)
- [Additional Resources](#additional-resources)

## 🎯 What is Pester?

Pester is a **testing and mocking framework** for PowerShell that enables you to:
- Write **unit tests** and **integration tests** for your PowerShell code
- **Mock** external dependencies to isolate code under test
- Generate **code coverage** reports
- Integrate tests into **CI/CD pipelines**
- Validate configurations and deployments

Pester follows a simple file naming convention (`*.Tests.ps1`) and uses an intuitive DSL with keywords like `Describe`, `Context`, `It`, `Should`, and `Mock`.

## 📁 Repository Structure

The repository is organized into progressive learning levels:

```
pesterdevPlayground/
│
├── 01-Basic/                          # Level 1: Fundamentals
│   ├── Get-Greeting.ps1               # Simple string function
│   └── Get-Greeting.Tests.ps1         # Basic assertions and contexts
│
├── 02-Intermediate/                   # Level 2: Parameterized Testing
│   ├── Calculator.ps1                 # Arithmetic operations
│   └── Calculator.Tests.ps1           # TestCases and data-driven tests
│
├── 03-Advanced/                       # Level 3: Mocking & Dependencies
│   ├── UserValidation.ps1             # Functions with external calls
│   └── UserValidation.Tests.ps1       # Mocking and mock assertions
│
├── 04-Expert/                         # Level 4: Integration & File I/O
│   ├── FileOperations.ps1             # Configuration file management
│   └── FileOperations.Tests.ps1       # Setup/teardown and integration tests
│
└── README.md                          # This file
```

## 🚀 Getting Started

### Prerequisites

- **PowerShell 5.1** or **PowerShell 7+**
- **Pester 5.x** (recommended)

### Installing Pester

If you don't have Pester installed, run:

```powershell
# Install Pester (requires admin/elevated privileges)
Install-Module -Name Pester -Force -SkipPublisherCheck

# Verify installation
Import-Module Pester -PassThru
```

You should see output similar to:

```
ModuleType Version    Name
---------- -------    ----
Script     5.x.x      Pester
```

### Cloning the Repository

```powershell
git clone https://github.com/yourusername/pesterdevPlayground.git
cd pesterdevPlayground
```

## 📖 Learning Path

Follow these levels in order to progressively build your Pester skills:

### **Level 1: Basic Testing** (`01-Basic/`)

**Concepts Covered:**
- `BeforeAll` block for setup
- `Describe` and `Context` for organizing tests
- `It` blocks for individual test cases
- Basic `Should` assertions (`-Be`, `-BeLike`, `-Match`)
- Testing default parameters and error conditions
- Pipeline support testing

**What You'll Learn:**
- How to structure a basic test file
- Dot-sourcing functions to test
- Writing clear, descriptive test cases
- Testing both happy paths and error scenarios

**Run Tests:**
```powershell
Invoke-Pester -Path .\01-Basic\Get-Greeting.Tests.ps1 -Output Detailed
```

---

### **Level 2: Intermediate Testing** (`02-Intermediate/`)

**Concepts Covered:**
- **TestCases** for parameterized testing
- Data-driven tests with multiple inputs
- Testing mathematical operations
- Edge case validation
- Integration tests combining multiple functions

**What You'll Learn:**
- How to reduce test duplication with TestCases
- Testing multiple scenarios efficiently
- Organizing related test cases
- Validating complex calculations

**Run Tests:**
```powershell
Invoke-Pester -Path .\02-Intermediate\Calculator.Tests.ps1 -Output Detailed
```

---

### **Level 3: Advanced Testing** (`03-Advanced/`)

**Concepts Covered:**
- **Mocking** functions and external dependencies
- **Mock assertions** with `Should -Invoke`
- Parameter filters for precise mock verification
- `BeforeEach` for per-test setup
- Testing code with external API calls
- Verifying call order and behavior

**What You'll Learn:**
- How to isolate code from external dependencies
- Mocking strategies for unit testing
- Verifying function interactions
- Testing error handling without hitting real APIs

**Run Tests:**
```powershell
Invoke-Pester -Path .\03-Advanced\UserValidation.Tests.ps1 -Output Detailed
```

---

### **Level 4: Expert Testing** (`04-Expert/`)

**Concepts Covered:**
- **BeforeAll/AfterAll** for test suite setup/teardown
- **BeforeEach/AfterEach** for test-level cleanup
- Testing file system operations
- Using `$TestDrive` for temporary test files
- Integration testing with real I/O
- Idempotency testing
- Complete workflow testing

**What You'll Learn:**
- How to safely test file operations
- Proper test isolation and cleanup
- Integration test patterns
- Testing concurrent operations
- End-to-end workflow validation

**Run Tests:**
```powershell
Invoke-Pester -Path .\04-Expert\FileOperations.Tests.ps1 -Output Detailed
```

## ▶️ Running Tests

### Run All Tests

To run all tests in the repository:

```powershell
Invoke-Pester -Output Detailed
```

### Run Tests for a Specific Level

```powershell
# Basic tests
Invoke-Pester -Path .\01-Basic\ -Output Detailed

# Intermediate tests
Invoke-Pester -Path .\02-Intermediate\ -Output Detailed

# Advanced tests
Invoke-Pester -Path .\03-Advanced\ -Output Detailed

# Expert tests
Invoke-Pester -Path .\04-Expert\ -Output Detailed
```

### Run a Specific Test File

```powershell
Invoke-Pester -Path .\02-Intermediate\Calculator.Tests.ps1 -Output Detailed
```

### Run Tests with Code Coverage

```powershell
$config = New-PesterConfiguration
$config.Run.Path = '.\02-Intermediate\'
$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.Path = '.\02-Intermediate\Calculator.ps1'
$config.Output.Verbosity = 'Detailed'

Invoke-Pester -Configuration $config
```

### Common Pester Commands

```powershell
# Run with minimal output (only failed tests)
Invoke-Pester

# Run with detailed output (all tests)
Invoke-Pester -Output Detailed

# Run specific tests by name
Invoke-Pester -FullNameFilter "*adds*"

# Run tests and stop on first failure
Invoke-Pester -Stop

# Generate test results in NUnit format (for CI/CD)
$config = New-PesterConfiguration
$config.TestResult.Enabled = $true
$config.TestResult.OutputPath = 'TestResults.xml'
Invoke-Pester -Configuration $config
```

## ✅ Best Practices

Based on the Pester documentation and examples in this repo:

### 1. **File Organization**
- Place test files next to the code they test
- Use the `*.Tests.ps1` naming convention
- Keep functions in separate `.ps1` files
- Use dot-sourcing in `BeforeAll` to import functions

### 2. **Test Structure**
- Use `Describe` for the function or module being tested
- Use `Context` to group related scenarios
- Use `It` for individual test cases
- Keep test names descriptive and readable

### 3. **Setup and Teardown**
- Use `BeforeAll` for expensive setup (runs once per block)
- Use `BeforeEach` for per-test setup
- Use `AfterAll` and `AfterEach` for cleanup
- Leverage `$TestDrive` for temporary file testing

### 4. **Assertions**
- Use specific assertions (`-Be`, `-BeExactly`, `-BeLike`, `-Match`)
- Test both positive and negative cases
- Use `Should -Throw` for error testing
- Use parameter filters for precise expectations

### 5. **Mocking**
- Mock external dependencies to isolate code
- Use `Should -Invoke` to verify mock calls
- Use parameter filters to verify correct arguments
- Test both with and without mocks when appropriate

### 6. **TestCases**
- Use `-TestCases` to reduce duplication
- Provide descriptive test names with placeholders
- Include edge cases and boundary conditions
- Keep test data close to the test

### 7. **Code Coverage**
- Aim for high coverage, but focus on meaningful tests
- Don't just test for coverage percentage
- Cover error paths and edge cases
- Review coverage reports to find gaps

## 📚 Additional Resources

### Official Documentation
- [Pester Documentation](https://pester.dev/docs/quick-start)
- [Pester GitHub Repository](https://github.com/pester/Pester)
- [PowerShell Gallery](https://www.powershellgallery.com/packages/Pester)

### Learning Resources
- [Pester Book](https://leanpub.com/pesterbook)
- [PowerShell Testing with Pester](https://www.pluralsight.com/courses/powershell-testing-pester)
- [Pester Gitter Chat](https://gitter.im/pester/Pester)

### Community
- [PowerShell.org Forums](https://forums.powershell.org/c/pester/)
- [PowerShell Discord - #testing](https://discord.gg/powershell)
- [Stack Overflow - Pester Tag](https://stackoverflow.com/questions/tagged/pester)

## 🤝 Contributing

This is a learning repository! Feel free to:
- Add more examples
- Improve existing tests
- Fix bugs or typos
- Add documentation
- Share your experiences

## 📄 License

This project is provided as-is for educational purposes. Feel free to use, modify, and share!

## 🎓 Next Steps

After completing all four levels:

1. **Practice** - Write tests for your own PowerShell scripts
2. **Integrate** - Add Pester to your CI/CD pipeline
3. **Explore** - Learn about code coverage and test-driven development (TDD)
4. **Share** - Help others learn Pester!

---

**Happy Testing!** 🎉

If you found this helpful, consider starring the repository and sharing it with others learning PowerShell testing.
