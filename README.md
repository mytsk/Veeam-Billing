# Veeam-Billing

Powershell module to fetch data from Veeam servers through WinRM protocol and store them in a MSSQL database.

### Why? 

Because Veeam PowerShell plugin lacks multi version support.

## Pre-reqs
1) PowerShell module SqlServer 
2) Veeam PowerShell modules on Backup Servers
3) WinRM Access to Backup Servers



## Installation & Usage
1. git clone 
2. Import-Module .\Veeam-Billing.psd1 -force


### Functions and Features
      
#### WinRM VBR Functions
- get-WRVBRBackups
- get-WRVBRBackupSessionStatistics
- get-WRVBRBackupSessionStatsPastMonth
- get-WRVBRJobConfiguration
- get-WRVBRJobStatistics
- get-WRVBRLicenseEdition
- get-WRVBRLicenseUsage
- get-WRVBRServerVersion

#### Databases functions
- get-dbVBRServers 
- Import-dbVBRBackups
- Import-dbVBRBackupSessionStatistics
- Import-dbVBRBackupSessionStatsPastMonth
- Import-dbVBRJobConfiguration
- Import-dbVBRJobStatistics
- Import-dbVBRLicenseUsage
- Update-dbVBRLicenseEdition
- Update-dbVBRServerVersion
