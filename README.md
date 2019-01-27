# QuarterYear

QuarteYear is a PowerShell module which makes quarterly (calendar/fiscal year) calculations

## Installing
#### Download from GitHub repository

* Download the repository from https://github.com/ryan-leap/QuarterYear
* Unblock the zip file ((on Windows)- Right Click -> Properties -> [ ] Unblock)
* Extract the QuarterYear folder to a module path (e.g. $home\Documents\WindowsPowerShell\Modules)

## Usage
```powershell
# Import the module
Import-Module -Name QuarterYear

# Get the available commands
Get-Command -Module QuarterYear

# Get help
Get-Help QuarterYear
```

## Examples
```powershell
# Returns the quarter of the current date for the current calendar year
Get-QuarterYear

# Returns the quarter of the current date when the (fiscal) year ends June 30th
Get-QuarterYear -YearEndDate (Get-Date -Month 6 -Day 30)

# Returns the end date of the second quarter for the current calendar year
Get-QuarterYearDate -Quarter 2

# Uses the pipeline to return the end date of each quarter for the current calendar year
1,2,3,4 | Get-QuarterYearDate

# Returns the first day of each quarter for the current calendar year
1,2,3,4 | Get-QuarterYearDate -FirstDay

# Returns the end date of each quarter for the (fiscal) year specified
1,2,3,4 | Get-QuarterYearDate -YearEndDate (Get-Date -Year 2020 -Month 6 -Day 30)

# Returns the first business day of the first quarter that doesn't fall on a holiday (business blackout date)
Get-QuarterYearDate -Quarter 1 -FirstDay -BusinessDay -BusinessBlackoutDate ((Get-Date -Month 1 -Day 1),(Get-Date -Month 12 -Day 25))
```

## Authors

* **Ryan Leap** - *Initial work*

## License

This project is licensed under the MIT License see [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Followed .psm1 template created by Mike Robbins here: https://github.com/mikefrobbins/Plaster
