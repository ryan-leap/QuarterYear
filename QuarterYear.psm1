function Test-MonthEnd {
<#
.SYNOPSIS
  Determines whether the date is the last day of the month
.PARAMETER Date
  Specifies a date and time.  Defaults to the current date.
.OUTPUTS
  System.Boolean
.NOTES
   Author: Ryan Leap
   Email: ryan.leap@gmail.com
#>
Param (
    [Parameter(Mandatory=$false)]
    [datetime] $Date = (Get-Date)
  )
  [datetime]::DaysInMonth($Date.Year, $Date.Month) -eq $Date.Day
}


function Get-QuarterYearDate {
<#
.SYNOPSIS
  Gets the last (or first) day of the quarter
.DESCRIPTION
  Gets a DateTime object that represents the ending (or beginning) of the quarter
  specified.  An alternate (fiscal) year-end date can be specified and a switch is
  available to limit results to business dates.
.PARAMETER Quarter
  Specifies the quarter
.PARAMETER YearEndDate
  Specifies when the year ends.  Defaults to the last day of the current calendar year.
  Use to specify a fiscal year end which does not coincide with the calendar year end
  or to specify past/future year end.
.PARAMETER FirstDay
  Gets the first date of the quarter (rather than the quarter end date)
.PARAMETER BusinessDay
  Exclude non-business days (weekends) and blackout dates from the results
.PARAMETER BusinessDayOfWeek
  Specifies the days of the week which are business days.  M-F is the default.
.PARAMETER BusinessBlackoutDate
  Specifies the dates of the year which should not be included in the results (like holidays)
.EXAMPLE
  Get-QuarterYearDate -Quarter 2
  Returns the end date of the second quarter for the current calendar year
.EXAMPLE
  1,2,3,4 | Get-QuarterYearDate
  Returns the end date of each quarter for the current calendar year
.EXAMPLE
  1,2,3,4 | Get-QuarterYearDate -FirstDay
  Returns the first day of each quarter for the current calendar year
.EXAMPLE
  1,2,3,4 | Get-QuarterYearDate -YearEndDate (Get-Date -Year 2020 -Month 6 -Day 30)
  Returns the end date of each quarter for the (fiscal) year specified
.EXAMPLE
  Get-QuarterYearDate -Quarter 1 -FirstDay -BusinessDay -BusinessBlackoutDate ((Get-Date -Month 1 -Day 1),(Get-Date -Month 12 -Day 25))
  Returns the first business day of the first quarter that doesn't fall on a holiday (business blackout date)
.OUTPUTS
  System.DateTime
.NOTES
   Author: Ryan Leap
   Email: ryan.leap@gmail.com
#>

  [CmdletBinding(DefaultParameterSetName='CalendarQuarter')]
  [OutputType([datetime])]
  Param (
    [ValidateSet(1,2,3,4)]
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [int] $Quarter,

    [Parameter(Mandatory=$false)]
    [datetime] $YearEndDate = (Get-Date -Month 12 -Day 31),

    [switch] $FirstDay,

    [Parameter(ParameterSetName='BusinessQuarter',Mandatory=$true)] 
    [switch] $BusinessDay,

    [Parameter(ParameterSetName='BusinessQuarter',Mandatory=$false)] 
    [ValidateSet('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')]
    [string[]] $BusinessDayOfWeek = @('Monday','Tuesday','Wednesday','Thursday','Friday'),

    [Parameter(ParameterSetName='BusinessQuarter',Mandatory=$false)]
    [datetime[]] $BusinessBlackoutDate

  )

  Begin {}

  Process {

    [hashtable] $dateParms = @{
      'Year'     = $YearEndDate.Year
      'Month'    = $YearEndDate.Month
      'Day'      = $YearEndDate.Day
      'Hour'     = if ($FirstDay) { 0 } else { 23 }
      'Minute'   = if ($FirstDay) { 0 } else { 59 }
      'Second'   = if ($FirstDay) { 0 } else { 59 }
    }
    [int] $monthsToSubtract = (12 - ($Quarter * 3))
    $quarterDate = (Get-Date @dateParms).AddMonths(-1 * $monthsToSubtract)

    # Using the .AddMonths() method is tricky:
    # (Get-Date -Month 1 -Day 31).AddMonths(1) = Feb 28th (last day of the month)
    # (Get-Date -Month 2 -Day 28).AddMonths(1) = Mar 28th (*not* the last day of the month)
    # As such, a special algorithm is needed to do the calendar math when a $YearEndDate
    # is supplied which is the last day of a month that does not have 31 days.
    if ((Test-MonthEnd -Date $YearEndDate) -and (31 -ne $YearEndDate.Day)) {
      $quarterDate = (Get-Date @dateParms).AddMonths(-1).AddDays(31 - $YearEndDate.Day).AddMonths(-1 * ($monthsToSubtract - 1))
    }
    if ($FirstDay) {
      if ((Test-MonthEnd -Date $quarterDate) -and (31 -ne $quarterDate.Day)) {
        $quarterDate = (Get-Date $quarterDate).AddMonths(-1).AddDays(31 - $quarterDate.Day + 1).AddMonths(-2)
      }
      else {
        $quarterDate = $quarterDate.AddMonths(-3).AddDays(1)
      }
    }
    if ($BusinessDay) {
      do {
        do {
          if ($quarterDate.DayOfWeek -notin $BusinessDayOfWeek) {
            if ($FirstDay) {
              $quarterDate = $quarterDate.AddDays(1)
            }
            else {
              $quarterDate = $quarterDate.AddDays(-1)
            }
          }
        } while ($quarterDate.DayOfWeek -notin $BusinessDayOfWeek)

        $dateModifiedForBlackout = $false
        foreach ($blackoutDate in $BusinessBlackoutDate) {
          if (($quarterDate.Year -eq $blackoutDate.Year) -and ($quarterDate.Month -eq $blackoutDate.Month) -and
              ($quarterDate.Day -eq $blackoutDate.Day)) {
            $dateModifiedForBlackout = $true
            if ($FirstDay) {
              $quarterDate = $quarterDate.AddDays(1)
            }
            else {
              $quarterDate = $quarterDate.AddDays(-1)
            }
          }
        }
      } until ($dateModifiedForBlackout -eq $false)
      # If the date was modified for a blackout date it may have fallen on a non-business
      # day or a subsequent blackout date.  Therefore the updated date needs to be evaluated
      # to ensure it too satifies the business conditions
    }
    $quarterDate
  }

  End {}

}

function Get-QuarterYear {
<#
.SYNOPSIS
  Gets the quarter of the date specified
.DESCRIPTION
  Returns a number representing the quarter of the specified date
.PARAMETER Date
  Specifies the date of interest.  Defaults to the current date.
.PARAMETER YearEndDate
  Specifies when the year ends.  Defaults to the last day of the current calendar year.
  Use to specify a fiscal year end which does not coincide with the calendar year end
  or to specify past/future year end.
.EXAMPLE
  Get-QuarterYear
  Returns the quarter of the current date for the current calendar year
.EXAMPLE
  Get-QuarterYear -YearEndDate (Get-Date -Month 6 -Day 30)
  Returns the quarter of the current date when the (fiscal) year ends June 30th
.OUTPUTS
  Int16
.NOTES
   Author: Ryan Leap
   Email: ryan.leap@gmail.com
#>
  [CmdletBinding()]
  [OutputType([int16])]
  Param (

    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [datetime] $Date = (Get-Date),

    [Parameter(Mandatory=$false)]
    [datetime] $YearEndDate = (Get-Date -Month 12 -Day 31)

  )

  Begin {}

  Process {

    for ($quarter = 1; $quarter -le 4; $quarter++) {
      if (($Date -ge (Get-QuarterYearDate -YearEndDate $YearEndDate -Quarter $quarter -FirstDay)) -and
          ($Date -le (Get-QuarterYearDate -YearEndDate $YearEndDate -Quarter $quarter))) {
        $quarter
        break
      }
    }

  }

  End {}

}

Export-ModuleMember -Function Get-QuarterYear
Export-ModuleMember -Function Get-QuarterYearDate
# Export-ModuleMember -Function Test-QuarterYearBegin (Takes a date)
# Export-ModuleMember -Function Test-QuarterYearEnd (Takes a date)