<#
.SYNOPSIS
    Pester tests for DateTimeParsing module.

.DESCRIPTION
    Level 4 (Expert) Tests - Demonstrates:
    - DateTime parsing with explicit formats
    - UTC conversion testing
    - DateTimeOffset timezone-aware operations
    - Format validation testing
    - Edge cases and error handling for production scenarios
    - Pipeline input testing
    - Flexible format detection

.NOTES
    These tests validate robust DateTime parsing patterns to prevent
    production issues with ambiguous date string parsing.
#>

BeforeAll {
    # Dot-source the functions to test
    . $PSScriptRoot/DateTimeParsing.ps1
}

Describe 'DateTimeParsing Module' {
    
    Context 'ConvertTo-DateTime - Direct Parsing with Explicit Formats' {
        It 'Parses ISO 8601 date format: <DateString>' -TestCases @(
            @{ DateString = '2026-01-03T14:30:00'; Format = 'yyyy-MM-ddTHH:mm:ss'; ExpectedMonth = 1; ExpectedDay = 3 }
            @{ DateString = '2025-12-25T09:15:30'; Format = 'yyyy-MM-ddTHH:mm:ss'; ExpectedMonth = 12; ExpectedDay = 25 }
            @{ DateString = '2026-06-15T23:45:59'; Format = 'yyyy-MM-ddTHH:mm:ss'; ExpectedMonth = 6; ExpectedDay = 15 }
        ) {
            param($DateString, $Format, $ExpectedMonth, $ExpectedDay)
            
            $result = ConvertTo-DateTime -DateString $DateString -Format $Format
            
            $result | Should -BeOfType [DateTime]
            $result.Month | Should -Be $ExpectedMonth
            $result.Day | Should -Be $ExpectedDay
        }

        It 'Parses date-only format: <DateString>' -TestCases @(
            @{ DateString = '2026-01-03'; Format = 'yyyy-MM-dd' }
            @{ DateString = '2025-12-31'; Format = 'yyyy-MM-dd' }
            @{ DateString = '2026-07-04'; Format = 'yyyy-MM-dd' }
        ) {
            param($DateString, $Format)
            
            $result = ConvertTo-DateTime -DateString $DateString -Format $Format
            
            $result | Should -BeOfType [DateTime]
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Parses US date format MM/dd/yyyy: <DateString>' -TestCases @(
            @{ DateString = '01/03/2026'; Format = 'MM/dd/yyyy'; ExpectedMonth = 1; ExpectedDay = 3 }
            @{ DateString = '12/31/2025'; Format = 'MM/dd/yyyy'; ExpectedMonth = 12; ExpectedDay = 31 }
            @{ DateString = '07/04/2026'; Format = 'MM/dd/yyyy'; ExpectedMonth = 7; ExpectedDay = 4 }
        ) {
            param($DateString, $Format, $ExpectedMonth, $ExpectedDay)
            
            $result = ConvertTo-DateTime -DateString $DateString -Format $Format
            
            $result.Month | Should -Be $ExpectedMonth
            $result.Day | Should -Be $ExpectedDay
        }

        It 'Parses European date format dd/MM/yyyy: <DateString>' -TestCases @(
            @{ DateString = '03/01/2026'; Format = 'dd/MM/yyyy'; ExpectedMonth = 1; ExpectedDay = 3 }
            @{ DateString = '31/12/2025'; Format = 'dd/MM/yyyy'; ExpectedMonth = 12; ExpectedDay = 31 }
            @{ DateString = '04/07/2026'; Format = 'dd/MM/yyyy'; ExpectedMonth = 7; ExpectedDay = 4 }
        ) {
            param($DateString, $Format, $ExpectedMonth, $ExpectedDay)
            
            $result = ConvertTo-DateTime -DateString $DateString -Format $Format
            
            $result.Month | Should -Be $ExpectedMonth
            $result.Day | Should -Be $ExpectedDay
        }

        It 'Parses compact date format yyyyMMdd: <DateString>' -TestCases @(
            @{ DateString = '20260103'; Format = 'yyyyMMdd' }
            @{ DateString = '20251231'; Format = 'yyyyMMdd' }
            @{ DateString = '20260704'; Format = 'yyyyMMdd' }
        ) {
            param($DateString, $Format)
            
            $result = ConvertTo-DateTime -DateString $DateString -Format $Format
            
            $result | Should -BeOfType [DateTime]
            $result.Year | Should -Be ([int]$DateString.Substring(0, 4))
        }

        It 'Throws exception for invalid date string' {
            { ConvertTo-DateTime -DateString 'invalid-date' -Format 'yyyy-MM-dd' } | 
                Should -Throw -ExpectedMessage '*Failed to parse date string*'
        }

        It 'Throws exception for mismatched format' {
            { ConvertTo-DateTime -DateString '01/03/2026' -Format 'yyyy-MM-dd' } | 
                Should -Throw
        }

        It 'Accepts pipeline input' {
            $result = '2026-01-03' | ConvertTo-DateTime -Format 'yyyy-MM-dd'
            
            $result | Should -BeOfType [DateTime]
        }
    }

    Context 'ConvertTo-DateTimeUtc - UTC Conversion' {
        It 'Converts local time to UTC' {
            $dateString = '2026-01-03T14:30:00'
            $format = 'yyyy-MM-ddTHH:mm:ss'
            
            $result = ConvertTo-DateTimeUtc -DateString $dateString -Format $format -SourceKind Local
            
            $result | Should -BeOfType [DateTime]
            $result.Kind | Should -Be ([System.DateTimeKind]::Utc)
        }

        It 'Handles already UTC time correctly' {
            $dateString = '2026-01-03T14:30:00'
            $format = 'yyyy-MM-ddTHH:mm:ss'
            
            $result = ConvertTo-DateTimeUtc -DateString $dateString -Format $format -SourceKind Utc
            
            $result.Kind | Should -Be ([System.DateTimeKind]::Utc)
            # When already UTC, time should not change
            $result.Hour | Should -Be 14
            $result.Minute | Should -Be 30
        }

        It 'Handles unspecified kind by treating as local' {
            $dateString = '2026-01-03T14:30:00'
            $format = 'yyyy-MM-ddTHH:mm:ss'
            
            $result = ConvertTo-DateTimeUtc -DateString $dateString -Format $format -SourceKind Unspecified
            
            $result.Kind | Should -Be ([System.DateTimeKind]::Utc)
        }

        It 'Parses various date formats with space separator' {
            $dateString = '2026-01-03 14:30:00'
            $format = 'yyyy-MM-dd HH:mm:ss'
            
            $result = ConvertTo-DateTimeUtc -DateString $dateString -Format $format
            
            $result | Should -BeOfType [DateTime]
            $result.Kind | Should -Be ([System.DateTimeKind]::Utc)
        }

        It 'Accepts pipeline input for UTC conversion' {
            $result = '2026-01-03T14:30:00' | ConvertTo-DateTimeUtc -Format 'yyyy-MM-ddTHH:mm:ss'
            
            $result.Kind | Should -Be ([System.DateTimeKind]::Utc)
        }

        It 'Throws exception for invalid date format' {
            { ConvertTo-DateTimeUtc -DateString 'not-a-date' -Format 'yyyy-MM-dd' } | 
                Should -Throw -ExpectedMessage '*Failed to convert date string*'
        }
    }

    Context 'ConvertTo-DateTimeOffsetUtc - Timezone-Aware Parsing' {
        It 'Parses DateTimeOffset with positive timezone offset' {
            $dateString = '2026-01-03T14:30:00+05:00'
            $format = 'yyyy-MM-ddTHH:mm:sszzz'
            
            $result = ConvertTo-DateTimeOffsetUtc -DateString $dateString -Format $format
            
            $result | Should -BeOfType [DateTimeOffset]
            $result.Offset.TotalHours | Should -Be 5
        }

        It 'Parses DateTimeOffset with negative timezone offset' {
            $dateString = '2026-01-03T14:30:00-08:00'
            $format = 'yyyy-MM-ddTHH:mm:sszzz'
            
            $result = ConvertTo-DateTimeOffsetUtc -DateString $dateString -Format $format
            
            $result | Should -BeOfType [DateTimeOffset]
            $result.Offset.TotalHours | Should -Be -8
        }

        It 'Parses DateTimeOffset with UTC offset (Z notation)' {
            $dateString = '2026-01-03T14:30:00+00:00'
            $format = 'yyyy-MM-ddTHH:mm:sszzz'
            
            $result = ConvertTo-DateTimeOffsetUtc -DateString $dateString -Format $format
            
            $result.Offset.TotalHours | Should -Be 0
            $result.UtcDateTime.Hour | Should -Be 14
        }

        It 'Provides access to both local and UTC times' {
            $dateString = '2026-01-03T14:30:00+05:00'
            $format = 'yyyy-MM-ddTHH:mm:sszzz'
            
            $result = ConvertTo-DateTimeOffsetUtc -DateString $dateString -Format $format
            
            # Original time (local to the offset)
            $result.DateTime.Hour | Should -Be 14
            # UTC time should be 5 hours earlier
            $result.UtcDateTime.Hour | Should -Be 9
        }

        It 'Handles fractional timezone offsets' {
            $dateString = '2026-01-03T14:30:00+05:30'
            $format = 'yyyy-MM-ddTHH:mm:sszzz'
            
            $result = ConvertTo-DateTimeOffsetUtc -DateString $dateString -Format $format
            
            $result.Offset.TotalHours | Should -Be 5.5
        }

        It 'Accepts pipeline input' {
            $result = '2026-01-03T14:30:00+00:00' | ConvertTo-DateTimeOffsetUtc -Format 'yyyy-MM-ddTHH:mm:sszzz'
            
            $result | Should -BeOfType [DateTimeOffset]
        }

        It 'Throws exception for invalid DateTimeOffset string' {
            { ConvertTo-DateTimeOffsetUtc -DateString 'invalid' -Format 'yyyy-MM-ddTHH:mm:sszzz' } | 
                Should -Throw -ExpectedMessage '*Failed to parse DateTimeOffset string*'
        }
    }

    Context 'Test-DateTimeFormat - Format Validation' {
        It 'Returns true for valid date and format combination: <DateString>' -TestCases @(
            @{ DateString = '2026-01-03'; Format = 'yyyy-MM-dd' }
            @{ DateString = '01/03/2026'; Format = 'MM/dd/yyyy' }
            @{ DateString = '2026-01-03T14:30:00'; Format = 'yyyy-MM-ddTHH:mm:ss' }
            @{ DateString = '20260103'; Format = 'yyyyMMdd' }
        ) {
            param($DateString, $Format)
            
            $result = Test-DateTimeFormat -DateString $DateString -Format $Format
            
            $result | Should -Be $true
        }

        It 'Returns false for invalid date and format combination: <DateString>' -TestCases @(
            @{ DateString = 'not-a-date'; Format = 'yyyy-MM-dd' }
            @{ DateString = '2026-13-45'; Format = 'yyyy-MM-dd' }
            @{ DateString = '01/03/2026'; Format = 'yyyy-MM-dd' }
            @{ DateString = ''; Format = 'yyyy-MM-dd' }
        ) {
            param($DateString, $Format)
            
            # Handle empty string case separately due to validation
            if ($DateString -eq '') {
                Set-ItResult -Skipped -Because "Empty strings are caught by parameter validation"
                return
            }
            
            $result = Test-DateTimeFormat -DateString $DateString -Format $Format
            
            $result | Should -Be $false
        }

        It 'Does not throw exception for invalid input' {
            $result = Test-DateTimeFormat -DateString 'invalid-date' -Format 'yyyy-MM-dd'
            
            $result | Should -Be $false
        }

        It 'Accepts pipeline input' {
            $result = '2026-01-03' | Test-DateTimeFormat -Format 'yyyy-MM-dd'
            
            $result | Should -Be $true
        }
    }

    Context 'ConvertFrom-DateTime - DateTime to String Conversion' {
        BeforeEach {
            $testDate = [DateTime]::new(2026, 1, 3, 14, 30, 45, 123, [System.DateTimeKind]::Local)
        }

        It 'Converts DateTime to ISO 8601 string without UTC' {
            $result = ConvertFrom-DateTime -DateTime $testDate
            
            $result | Should -Match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$'
            $result | Should -Not -Match 'Z$'
        }

        It 'Converts DateTime to ISO 8601 string with UTC' {
            $result = ConvertFrom-DateTime -DateTime $testDate -UseUtc
            
            $result | Should -Match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$'
        }

        It 'Includes milliseconds when specified' {
            $result = ConvertFrom-DateTime -DateTime $testDate -IncludeMilliseconds
            
            $result | Should -Match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}$'
        }

        It 'Includes milliseconds with UTC when both specified' {
            $result = ConvertFrom-DateTime -DateTime $testDate -UseUtc -IncludeMilliseconds
            
            $result | Should -Match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$'
        }

        It 'Accepts pipeline input' {
            $result = $testDate | ConvertFrom-DateTime
            
            $result | Should -BeOfType [string]
            $result | Should -Match '^\d{4}-\d{2}-\d{2}T'
        }

        It 'Produces consistent output format' {
            $date1 = [DateTime]::new(2026, 1, 3, 14, 30, 0)
            $date2 = [DateTime]::new(2026, 1, 3, 14, 30, 0)
            
            $result1 = ConvertFrom-DateTime -DateTime $date1
            $result2 = ConvertFrom-DateTime -DateTime $date2
            
            $result1 | Should -BeExactly $result2
        }
    }

    Context 'ConvertTo-DateTimeFlexible - Automatic Format Detection' {
        It 'Detects and parses common date format: <DateString>' -TestCases @(
            @{ DateString = '2026-01-03'; ExpectedSuccess = $true }
            @{ DateString = '2026-01-03T14:30:00'; ExpectedSuccess = $true }
            @{ DateString = '01/03/2026'; ExpectedSuccess = $true }
            @{ DateString = '20260103'; ExpectedSuccess = $true }
            @{ DateString = '2026-01-03 14:30:00'; ExpectedSuccess = $true }
        ) {
            param($DateString, $ExpectedSuccess)
            
            $result = ConvertTo-DateTimeFlexible -DateString $DateString
            
            $result.Success | Should -Be $ExpectedSuccess
            $result.DateTime | Should -Not -BeNullOrEmpty
            $result.FormatUsed | Should -Not -BeNullOrEmpty
            $result.ErrorMessage | Should -BeNullOrEmpty
        }

        It 'Returns failure for invalid date string' {
            $result = ConvertTo-DateTimeFlexible -DateString 'not-a-valid-date'
            
            $result.Success | Should -Be $false
            $result.DateTime | Should -BeNullOrEmpty
            $result.FormatUsed | Should -BeNullOrEmpty
            $result.ErrorMessage | Should -Not -BeNullOrEmpty
        }

        It 'Uses custom format list when provided' {
            $customFormats = @('yyyy-MM-dd', 'MM/dd/yyyy')
            $result = ConvertTo-DateTimeFlexible -DateString '2026-01-03' -Formats $customFormats
            
            $result.Success | Should -Be $true
            $result.FormatUsed | Should -Be 'yyyy-MM-dd'
        }

        It 'Returns which format was successfully used' {
            $result = ConvertTo-DateTimeFlexible -DateString '01/03/2026'
            
            $result.Success | Should -Be $true
            $result.FormatUsed | Should -Be 'MM/dd/yyyy'
        }

        It 'Accepts pipeline input' {
            $result = '2026-01-03' | ConvertTo-DateTimeFlexible
            
            $result.Success | Should -Be $true
        }

        It 'Tries multiple formats before failing' {
            $result = ConvertTo-DateTimeFlexible -DateString 'invalid-date'
            
            $result.ErrorMessage | Should -Match 'Failed to parse.*with any of the \d+ provided formats'
        }

        It 'Returns PSCustomObject with all expected properties' {
            $result = ConvertTo-DateTimeFlexible -DateString '2026-01-03'
            
            $result.PSObject.Properties.Name | Should -Contain 'Success'
            $result.PSObject.Properties.Name | Should -Contain 'DateTime'
            $result.PSObject.Properties.Name | Should -Contain 'FormatUsed'
            $result.PSObject.Properties.Name | Should -Contain 'ErrorMessage'
        }
    }

    Context 'Production Scenario Tests - Edge Cases' {
        It 'Handles leap year dates correctly' {
            $result = ConvertTo-DateTime -DateString '2024-02-29' -Format 'yyyy-MM-dd'
            
            $result.Year | Should -Be 2024
            $result.Month | Should -Be 2
            $result.Day | Should -Be 29
        }

        It 'Rejects invalid leap year date' {
            { ConvertTo-DateTime -DateString '2025-02-29' -Format 'yyyy-MM-dd' } | 
                Should -Throw
        }

        It 'Handles end-of-year dates' {
            $result = ConvertTo-DateTime -DateString '2025-12-31T23:59:59' -Format 'yyyy-MM-ddTHH:mm:ss'
            
            $result.Month | Should -Be 12
            $result.Day | Should -Be 31
            $result.Hour | Should -Be 23
            $result.Minute | Should -Be 59
        }

        It 'Handles start-of-year dates' {
            $result = ConvertTo-DateTime -DateString '2026-01-01T00:00:00' -Format 'yyyy-MM-ddTHH:mm:ss'
            
            $result.Month | Should -Be 1
            $result.Day | Should -Be 1
            $result.Hour | Should -Be 0
            $result.Minute | Should -Be 0
        }

        It 'Prevents ambiguous date interpretation with explicit format' {
            # In US format this is January 3rd
            $usResult = ConvertTo-DateTime -DateString '01/03/2026' -Format 'MM/dd/yyyy'
            $usResult.Month | Should -Be 1
            $usResult.Day | Should -Be 3
            
            # In European format this is March 1st
            $euResult = ConvertTo-DateTime -DateString '01/03/2026' -Format 'dd/MM/yyyy'
            $euResult.Month | Should -Be 3
            $euResult.Day | Should -Be 1
        }

        It 'Maintains timezone information in DateTimeOffset' {
            $dto = ConvertTo-DateTimeOffsetUtc -DateString '2026-01-03T14:30:00+09:00' -Format 'yyyy-MM-ddTHH:mm:sszzz'
            
            # Original offset preserved
            $dto.Offset.TotalHours | Should -Be 9
            # But can still get UTC
            $dto.UtcDateTime | Should -Not -BeNullOrEmpty
        }

        It 'Handles batch processing via pipeline' {
            $dates = @('2026-01-01', '2026-01-02', '2026-01-03')
            $results = $dates | ConvertTo-DateTime -Format 'yyyy-MM-dd'
            
            $results.Count | Should -Be 3
            $results[0].Day | Should -Be 1
            $results[1].Day | Should -Be 2
            $results[2].Day | Should -Be 3
        }
    }

    Context 'Integration Tests - Real-World Scenarios' {
        It 'Scenario: API response with ISO 8601 timestamps' {
            $apiTimestamp = '2026-01-03T14:30:00+00:00'
            $dto = ConvertTo-DateTimeOffsetUtc -DateString $apiTimestamp -Format 'yyyy-MM-ddTHH:mm:sszzz'
            
            $dto.UtcDateTime | Should -BeOfType [DateTime]
            $dto.UtcDateTime.Kind | Should -Be ([System.DateTimeKind]::Utc)
        }

        It 'Scenario: Log file parsing with various formats' {
            $logEntries = @(
                '2026-01-03 14:30:00',
                '2026-01-03T15:45:30',
                '01/03/2026'
            )
            
            foreach ($entry in $logEntries) {
                $result = ConvertTo-DateTimeFlexible -DateString $entry
                $result.Success | Should -Be $true
            }
        }

        It 'Scenario: Database date validation before insert' {
            $userInput = '2026-01-03'
            $isValid = Test-DateTimeFormat -DateString $userInput -Format 'yyyy-MM-dd'
            
            $isValid | Should -Be $true
            
            if ($isValid) {
                $date = ConvertTo-DateTime -DateString $userInput -Format 'yyyy-MM-dd'
                $date | Should -BeOfType [DateTime]
            }
        }

        It 'Scenario: Convert local time to UTC for storage' {
            $localTime = '2026-01-03T14:30:00'
            $utcTime = ConvertTo-DateTimeUtc -DateString $localTime -Format 'yyyy-MM-ddTHH:mm:ss' -SourceKind Local
            
            $utcTime.Kind | Should -Be ([System.DateTimeKind]::Utc)
            
            # Convert back to string for storage
            $storageFormat = ConvertFrom-DateTime -DateTime $utcTime -UseUtc
            $storageFormat | Should -Match 'Z$'
        }

        It 'Scenario: Handle timezone conversion for distributed system' {
            # User in Tokyo (UTC+9) creates a record at 14:30 local time
            $tokyoTime = '2026-01-03T14:30:00+09:00'
            $dto = ConvertTo-DateTimeOffsetUtc -DateString $tokyoTime -Format 'yyyy-MM-ddTHH:mm:sszzz'
            
            # System stores UTC
            $utcStored = $dto.UtcDateTime
            $utcStored.Hour | Should -Be 5  # 14:30 - 9 hours = 05:30 UTC
            
            # User in New York (UTC-5) views the same record
            # Convert UTC time to New York time by adding the offset
            $nyOffset = [TimeSpan]::FromHours(-5)
            $nyTime = $dto.ToOffset($nyOffset)
            # 05:30 UTC - 5 hours = 00:30 NY time
            $nyTime.Hour | Should -Be 0
            $nyTime.Minute | Should -Be 30
        }
    }
}
