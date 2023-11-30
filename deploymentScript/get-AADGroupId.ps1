[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $AdminGroupName,

    [Parameter(Mandatory = $true)]
    [string]
    $DevGroupName,

    [Parameter(Mandatory = $true)]
    [string]
    $DbaGroupName
)

$AdminGroupId = (Get-AzAdGroup -DisplayName $AdminGroupName).ObjectId
$DevGroupId = (Get-AzAdGroup -DisplayName $DevGroupName).ObjectId
$DbaGroupId = (Get-AzAdGroup -DisplayName $DbaGroupName).ObjectId

$DeploymentScriptOutputs  = @{}
$DeploymentScriptOutputs.Add("AdminGroupId", $AdminGroupId)
$DeploymentScriptOutputs.Add("DevGroupId", $DevGroupId)
$DeploymentScriptOutputs.Add("DbaGroupId", $DbaGroupId)
