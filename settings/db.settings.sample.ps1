### VARIABLES ###
$dbServer = "LOCALHOST\SQLEXPRESS"
$dbDatabase = "ConsumptionDB"
$dbUsername = 'sql_user'
$dbPassword = 'sqlP@$$w0rd'


### EXEC ###
$global:dbServer = $dbServer
$global:dbDatabase = $dbDatabase
$global:dbUsername = $dbUsername
$Password = ConvertTo-SecureString -AsPlainText $dbPassword -Force
$global:creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $dbUsername, $Password