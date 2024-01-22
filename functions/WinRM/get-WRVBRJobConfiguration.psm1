#
# 100% working
# Fetches job configuration
#

function get-WRVBRJobConfiguration {
    Param(
        [parameter(position = 0, Mandatory = $false)]
        $BackupServer
    )
    if (!$BackupServer) {
        $BackupServer = $Global:BackupServer
        # if(!$Global:BackupServer){write-host "No BackupServer defined, set it by using -BackupServer or set $global:BackupServer'"}
    }
    if ((Get-VBParameters -AuthType) -eq 'ConfigFile' -or (Get-VBParameters -AuthType) -eq 'CurrentUser') {
        $creds = $global:vbrcreds
    }

    if ((Get-VBParameters -AuthType) -eq 'Automation') {
        $credsFromDb = get-dbVBRCredentials -backupserver $BackupServer
        $securePass = ConvertTo-SecureString -String $credsFromDb.SecureString
        $creds = New-Object System.Management.Automation.PsCredential($credsFromDb.Username, $securePass)
    }

    $result = invoke-command -Credential $creds -ComputerName $BackupServer -ScriptBlock {
        add-pssnapin VeeamPSSnapin 
        #(Get-VBRJob | Select-Object Name, TypeToString | Sort-Object TypeToString)

        #(Get-VBRJob | Select-Object Name, TypeToString, SourceType, @{Name = "Encrption"; Expression = { if (!$_.UserCryptoKey) { "False" }else { "True" } }}, IsDeleted, Description , $_.options.GenerationPolicy.IsGfsActiveFullEnabled | Sort-Object TypeToString)

        (Get-VBRJob |
            Select-Object Name,
            TypeToString,
            SourceType,
            IsScheduleEnabled,
            SqlEnabled,
            IsDeleted,
            Description,
            @{Name = "EncryptionEnabled"; Expression = { if (!$_.UserCryptoKey) { "False" }else { "True" } } },
            @{Name = "ApplicationAwareEnabled"; Expression = { $_.VssOptions.Enabled } },
            @{Name = "NotificationSendEmailNotification2AdditionalAddresses"; Expression = { $_.options.NotificationOptions.SendEmailNotification2AdditionalAddresses } },
            @{Name = "NotificationEmailNotificationAdditionalAddresses"; Expression = { $_.options.NotificationOptions.EmailNotificationAdditionalAddresses } },
            @{Name = "NotificationEmailNotifyOnSuccess"; Expression = { $_.options.NotificationOptions.EmailNotifyOnSuccess } },
            @{Name = "NotificationEmailNotifyOnWarning"; Expression = { $_.options.NotificationOptions.EmailNotifyOnWarning } },
            @{Name = "NotificationEmailNotifyOnError"; Expression = { $_.options.NotificationOptions.EmailNotifyOnError } },
            @{Name = "NotificationEmailNotifyOnLastRetryOnly"; Expression = { $_.options.NotificationOptions.EmailNotifyOnLastRetryOnly } },

            <# maybe ommit below #>
            @{Name = "GenerationPolicyActualRetentionRestorePoints"; Expression = { $_.options.GenerationPolicy.ActualRetentionRestorePoints } } ,
            @{Name = "GenerationPolicyEnableDeletedVmDataRetention"; Expression = { $_.options.GenerationPolicy.EnableDeletedVmDataRetention } } ,
            @{Name = "GenerationPolicyDeletedVmsDataRetentionPeriodDays"; Expression = { $_.options.GenerationPolicy.DeletedVmsDataRetentionPeriodDays } } ,
            @{Name = "GenerationPolicyRecoveryPointObjectiveUnit"; Expression = { $_.options.GenerationPolicy.RecoveryPointObjectiveUnit } } ,
            @{Name = "GenerationPolicyRecoveryPointObjectiveValue"; Expression = { $_.options.GenerationPolicy.RecoveryPointObjectiveValue } } ,
            @{Name = "GenerationPolicyEnableCompactFull"; Expression = { $_.options.GenerationPolicy.EnableCompactFull } } ,
            @{Name = "GenerationPolicyEnableCompactFullLastTime"; Expression = { $_.options.GenerationPolicy.EnableCompactFullLastTime } } ,
            @{Name = "GenerationPolicyEnableRechek"; Expression = { $_.options.GenerationPolicy.EnableRechek } } ,
            @{Name = "GenerationPolicyRecheckScheduleKind"; Expression = { $_.options.GenerationPolicy.RecheckScheduleKind } } ,
            @{Name = "GFSRecentPoints"; Expression = { $_.options.GenerationPolicy.GFSRecentPoints } } ,
            @{Name = "GFSWeeklyBackups"; Expression = { $_.options.GenerationPolicy.GFSWeeklyBackups } } ,
            @{Name = "GFSWeeklyBackupsEnabled"; Expression = { $_.options.GenerationPolicy.GFSWeeklyBackupsEnabled } } ,
            @{Name = "GFSMonthlyBackups"; Expression = { $_.options.GenerationPolicy.GFSMonthlyBackups } } ,
            @{Name = "GFSMonthlyBackupsEnabled"; Expression = { $_.options.GenerationPolicy.GFSMonthlyBackupsEnabled } } ,
            @{Name = "GFSQuarterlyBackups"; Expression = { $_.options.GenerationPolicy.GFSQuarterlyBackups } } ,
            @{Name = "GFSQuarterlyBackupsEnabled"; Expression = { $_.options.GenerationPolicy.GFSQuarterlyBackupsEnabled } } ,
            @{Name = "GFSYearlyBackups"; Expression = { $_.options.GenerationPolicy.GFSYearlyBackups } } ,
            @{Name = "GFSYearlyBackupsEnabled"; Expression = { $_.options.GenerationPolicy.GFSYearlyBackupsEnabled } } ,
            @{Name = "GFSIsReadEntireRestorePoint"; Expression = { $_.options.GenerationPolicy.GFSIsReadEntireRestorePoint } } ,
            @{Name = "GFSIsGfsActiveFullEnabled"; Expression = { $_.options.GenerationPolicy.IsGfsActiveFullEnabled } } ,
            @{Name = "PreCommandEnabled"; Expression = { $_.options.JobScriptCommand.PreCommand.Enabled } } ,
            @{Name = "PreCommandCommandLine"; Expression = { $_.options.JobScriptCommand.PreCommand.CommandLine } } ,
            @{Name = "PostCommandEnabled"; Expression = { $_.options.JobScriptCommand.PostCommand.Enabled } } ,
            @{Name = "PostCommandCommandLine"; Expression = { $_.options.JobScriptCommand.PostCommand.CommandLine } })
    }
    return $result | Select-Object * -ExcludeProperty RunspaceId
    Remove-PSSession -Session $result
} #function get-WRVBRJobs