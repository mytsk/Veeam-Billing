
function Set-VBParameters {
    Param(
        [parameter(Mandatory = $false)][ValidateSet('ConfigFile', 'Automation', 'CurrentUser')][string] $AuthType       
    )
    
    
    $ModuleFilePath = ((Get-Module -Name 'Veeam-Billing').Path)
    [string]$Global:BaseDir = $ModuleFilePath.SubString(0, $ModuleFilePath.LastIndexOf('\Veeam-Billing.psd1'))
    [string]$Global:LogDir = "$Global:BaseDir\Logs"

    if ($AuthType -eq 'ConfigFile') {
        & $Global:BaseDir\settings\vbr.settings.ps1
        $global:AuthType = "ConfigFile"
      
    }
    if ($AuthType -eq 'Automation') {
        $global:AuthType = "Automation"
    }

    if ($AuthType -eq 'CurrentUser') { 
        $global:vbrcreds = Get-Credential -Message "Insert VBR Credentials"
        $global:AuthType = "CurrentUser"

    }

    if (!($global:AuthType)) {
        $global:AuthType = "ConfigFile"
    }

    Get-VBParameters
    
}