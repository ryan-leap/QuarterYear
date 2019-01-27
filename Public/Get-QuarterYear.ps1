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
