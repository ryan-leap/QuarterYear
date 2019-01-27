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
