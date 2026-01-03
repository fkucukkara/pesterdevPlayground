<#
.SYNOPSIS
    DateTime parsing functions demonstrating robust date handling patterns.

.DESCRIPTION
    Level 4 (Expert) - Demonstrates safe DateTime parsing to address production date format issues.
    This module provides functions for:
    - Direct DateTime parsing with format validation
    - UTC DateTime parsing and conversion
    - DateTimeOffset parsing for timezone-aware operations

.NOTES
    Created to address production issues with direct string-to-DateTime parsing.
    These functions use explicit formats and validation to prevent parsing errors.
#>

<#
.SYNOPSIS
    Parses a date string using explicit format specification.

.DESCRIPTION
    Safely parses date strings by requiring an explicit format specification.
    This prevents ambiguous parsing issues common in production environments.

.PARAMETER DateString
    The date string to parse.

.PARAMETER Format
    The expected format of the date string (e.g., 'yyyy-MM-dd', 'MM/dd/yyyy').
    If not specified, defaults to ISO 8601 format 'yyyy-MM-ddTHH:mm:ss'.

.PARAMETER Culture
    Optional culture info for parsing. Defaults to InvariantCulture.

.EXAMPLE
    ConvertTo-DateTime -DateString "2026-01-03" -Format "yyyy-MM-dd"
    Returns: [DateTime] object for January 3, 2026

.EXAMPLE
    ConvertTo-DateTime -DateString "01/03/2026" -Format "MM/dd/yyyy"
    Returns: [DateTime] object for January 3, 2026

.EXAMPLE
    ConvertTo-DateTime -DateString "2026-01-03T14:30:00"
    Returns: [DateTime] object using default ISO 8601 format
#>
function ConvertTo-DateTime {
    [CmdletBinding()]
    [OutputType([DateTime])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DateString,

        [Parameter(Mandatory = $false)]
        [string]$Format = 'yyyy-MM-ddTHH:mm:ss',

        [Parameter(Mandatory = $false)]
        [System.Globalization.CultureInfo]$Culture = [System.Globalization.CultureInfo]::InvariantCulture
    )

    process {
        try {
            # Use ParseExact for strict format validation
            $parsedDate = [DateTime]::ParseExact(
                $DateString,
                $Format,
                $Culture,
                [System.Globalization.DateTimeStyles]::None
            )
            
            return $parsedDate
        }
        catch {
            throw "Failed to parse date string '$DateString' with format '$Format': $($_.Exception.Message)"
        }
    }
}

<#
.SYNOPSIS
    Parses a date string and converts it to UTC.

.DESCRIPTION
    Parses a date string with explicit format and converts it to UTC.
    Useful for standardizing timestamps across different time zones.

.PARAMETER DateString
    The date string to parse.

.PARAMETER Format
    The expected format of the date string.
    If not specified, defaults to ISO 8601 format 'yyyy-MM-ddTHH:mm:ss'.

.PARAMETER SourceKind
    Specifies whether the input date is Local, Utc, or Unspecified.
    Defaults to Local.

.PARAMETER Culture
    Optional culture info for parsing. Defaults to InvariantCulture.

.EXAMPLE
    ConvertTo-DateTimeUtc -DateString "2026-01-03 14:30:00" -Format "yyyy-MM-dd HH:mm:ss"
    Returns: [DateTime] in UTC

.EXAMPLE
    ConvertTo-DateTimeUtc -DateString "2026-01-03T14:30:00" -SourceKind Utc
    Returns: [DateTime] treating input as already UTC
#>
function ConvertTo-DateTimeUtc {
    [CmdletBinding()]
    [OutputType([DateTime])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DateString,

        [Parameter(Mandatory = $false)]
        [string]$Format = 'yyyy-MM-ddTHH:mm:ss',

        [Parameter(Mandatory = $false)]
        [ValidateSet('Local', 'Utc', 'Unspecified')]
        [string]$SourceKind = 'Local',

        [Parameter(Mandatory = $false)]
        [System.Globalization.CultureInfo]$Culture = [System.Globalization.CultureInfo]::InvariantCulture
    )

    process {
        try {
            # Parse the date string
            $parsedDate = [DateTime]::ParseExact(
                $DateString,
                $Format,
                $Culture,
                [System.Globalization.DateTimeStyles]::None
            )

            # Specify the kind of DateTime
            $dateTimeKind = [System.DateTimeKind]::$SourceKind
            $dateWithKind = [DateTime]::SpecifyKind($parsedDate, $dateTimeKind)

            # Convert to UTC
            if ($dateTimeKind -eq [System.DateTimeKind]::Local) {
                return $dateWithKind.ToUniversalTime()
            }
            elseif ($dateTimeKind -eq [System.DateTimeKind]::Utc) {
                return $dateWithKind
            }
            else {
                # Unspecified - treat as local and convert
                $localDate = [DateTime]::SpecifyKind($dateWithKind, [System.DateTimeKind]::Local)
                return $localDate.ToUniversalTime()
            }
        }
        catch {
            throw "Failed to convert date string '$DateString' to UTC with format '$Format': $($_.Exception.Message)"
        }
    }
}

<#
.SYNOPSIS
    Parses a date string with timezone offset into DateTimeOffset.

.DESCRIPTION
    Parses date strings that include timezone offset information.
    DateTimeOffset preserves the original offset while providing UTC conversion.
    Critical for scenarios requiring timezone awareness.

.PARAMETER DateString
    The date string with timezone offset to parse (e.g., "2026-01-03T14:30:00+05:00").

.PARAMETER Format
    The expected format of the date string including offset pattern.
    Defaults to ISO 8601 with offset: 'yyyy-MM-ddTHH:mm:sszzz'.

.PARAMETER Culture
    Optional culture info for parsing. Defaults to InvariantCulture.

.EXAMPLE
    ConvertTo-DateTimeOffsetUtc -DateString "2026-01-03T14:30:00+05:00"
    Returns: [DateTimeOffset] preserving the +05:00 offset

.EXAMPLE
    ConvertTo-DateTimeOffsetUtc -DateString "2026-01-03T14:30:00-08:00" -Format "yyyy-MM-ddTHH:mm:sszzz"
    Returns: [DateTimeOffset] with UTC conversion available

.EXAMPLE
    $dto = ConvertTo-DateTimeOffsetUtc -DateString "2026-01-03T14:30:00+00:00"
    $dto.UtcDateTime  # Gets the UTC time
    $dto.LocalDateTime  # Gets the local time
#>
function ConvertTo-DateTimeOffsetUtc {
    [CmdletBinding()]
    [OutputType([DateTimeOffset])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DateString,

        [Parameter(Mandatory = $false)]
        [string]$Format = 'yyyy-MM-ddTHH:mm:sszzz',

        [Parameter(Mandatory = $false)]
        [System.Globalization.CultureInfo]$Culture = [System.Globalization.CultureInfo]::InvariantCulture
    )

    process {
        try {
            # Parse with exact format including timezone offset
            $parsedOffset = [DateTimeOffset]::ParseExact(
                $DateString,
                $Format,
                $Culture,
                [System.Globalization.DateTimeStyles]::None
            )
            
            return $parsedOffset
        }
        catch {
            throw "Failed to parse DateTimeOffset string '$DateString' with format '$Format': $($_.Exception.Message)"
        }
    }
}

<#
.SYNOPSIS
    Validates if a string can be parsed as a date with the specified format.

.DESCRIPTION
    Tests whether a date string can be successfully parsed using the specified format.
    Returns true if valid, false otherwise. Does not throw exceptions.

.PARAMETER DateString
    The date string to validate.

.PARAMETER Format
    The expected format pattern.

.PARAMETER Culture
    Optional culture info for parsing. Defaults to InvariantCulture.

.EXAMPLE
    Test-DateTimeFormat -DateString "2026-01-03" -Format "yyyy-MM-dd"
    Returns: $true

.EXAMPLE
    Test-DateTimeFormat -DateString "invalid" -Format "yyyy-MM-dd"
    Returns: $false
#>
function Test-DateTimeFormat {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DateString,

        [Parameter(Mandatory = $true)]
        [string]$Format,

        [Parameter(Mandatory = $false)]
        [System.Globalization.CultureInfo]$Culture = [System.Globalization.CultureInfo]::InvariantCulture
    )

    process {
        try {
            $null = [DateTime]::ParseExact(
                $DateString,
                $Format,
                $Culture,
                [System.Globalization.DateTimeStyles]::None
            )
            return $true
        }
        catch {
            return $false
        }
    }
}

<#
.SYNOPSIS
    Converts a DateTime object to a standardized ISO 8601 string.

.DESCRIPTION
    Converts DateTime objects to ISO 8601 format strings.
    Useful for API responses, logging, and data storage.

.PARAMETER DateTime
    The DateTime object to convert.

.PARAMETER IncludeOffset
    If true and DateTime is DateTimeOffset, includes timezone offset.

.PARAMETER UseUtc
    If true, converts to UTC before formatting.

.EXAMPLE
    ConvertFrom-DateTime -DateTime (Get-Date) -UseUtc
    Returns: "2026-01-03T14:30:00Z"

.EXAMPLE
    ConvertFrom-DateTime -DateTime (Get-Date)
    Returns: "2026-01-03T14:30:00"
#>
function ConvertFrom-DateTime {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [DateTime]$DateTime,

        [Parameter(Mandatory = $false)]
        [switch]$UseUtc,

        [Parameter(Mandatory = $false)]
        [switch]$IncludeMilliseconds
    )

    process {
        $dateToFormat = if ($UseUtc) {
            $DateTime.ToUniversalTime()
        }
        else {
            $DateTime
        }

        if ($IncludeMilliseconds) {
            $format = if ($UseUtc) { 'yyyy-MM-ddTHH:mm:ss.fffZ' } else { 'yyyy-MM-ddTHH:mm:ss.fff' }
        }
        else {
            $format = if ($UseUtc) { 'yyyy-MM-ddTHH:mm:ssZ' } else { 'yyyy-MM-ddTHH:mm:ss' }
        }

        return $dateToFormat.ToString($format, [System.Globalization.CultureInfo]::InvariantCulture)
    }
}

<#
.SYNOPSIS
    Parses multiple common date formats with automatic format detection.

.DESCRIPTION
    Attempts to parse a date string using a list of common formats.
    Useful when the exact format is unknown but must be from a known set.

.PARAMETER DateString
    The date string to parse.

.PARAMETER Formats
    Array of format patterns to try. If not specified, uses common formats.

.PARAMETER Culture
    Optional culture info for parsing. Defaults to InvariantCulture.

.EXAMPLE
    ConvertTo-DateTimeFlexible -DateString "2026-01-03"
    Returns: [DateTime] by trying multiple common formats

.EXAMPLE
    ConvertTo-DateTimeFlexible -DateString "01/03/2026" -Formats @("MM/dd/yyyy", "dd/MM/yyyy")
    Returns: [DateTime] using the first matching format
#>
function ConvertTo-DateTimeFlexible {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DateString,

        [Parameter(Mandatory = $false)]
        [string[]]$Formats = @(
            'yyyy-MM-dd',
            'yyyy-MM-ddTHH:mm:ss',
            'yyyy-MM-ddTHH:mm:ssZ',
            'yyyy-MM-ddTHH:mm:sszzz',
            'MM/dd/yyyy',
            'dd/MM/yyyy',
            'yyyy/MM/dd',
            'MM-dd-yyyy',
            'dd-MM-yyyy',
            'yyyyMMdd',
            'yyyy-MM-dd HH:mm:ss'
        ),

        [Parameter(Mandatory = $false)]
        [System.Globalization.CultureInfo]$Culture = [System.Globalization.CultureInfo]::InvariantCulture
    )

    process {
        $lastError = $null
        
        foreach ($format in $Formats) {
            try {
                $parsedDate = [DateTime]::ParseExact(
                    $DateString,
                    $format,
                    $Culture,
                    [System.Globalization.DateTimeStyles]::None
                )
                
                return [PSCustomObject]@{
                    Success      = $true
                    DateTime     = $parsedDate
                    FormatUsed   = $format
                    ErrorMessage = $null
                }
            }
            catch {
                $lastError = $_.Exception.Message
                continue
            }
        }

        # If we reach here, none of the formats worked
        return [PSCustomObject]@{
            Success      = $false
            DateTime     = $null
            FormatUsed   = $null
            ErrorMessage = "Failed to parse '$DateString' with any of the $($Formats.Count) provided formats. Last error: $lastError"
        }
    }
}
