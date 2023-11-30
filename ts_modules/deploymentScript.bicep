param location string
param AdminGroupName string
param DevGroupName string
param DbaGroupName string
param utcValue string = utcNow()

resource uaMsi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: 'WPC2023-ManagedIdentity-Identity'
  scope: resourceGroup('WPC2023-ManagedIdentity-RG')
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'WPC2023-DS'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uaMsi.id}': {}
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azPowerShellVersion: '9.7'
    arguments: '-AdminGroupName \\"${AdminGroupName}\\" -DevGroupName \\"${DevGroupName}\\" -DbaGroupName \\"${DbaGroupName}\\"'
    scriptContent: '''
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
      
      $AdminGroupId = (Get-AzAdGroup -DisplayName $AdminGroupName).id
      $DevGroupId = (Get-AzAdGroup -DisplayName $DevGroupName).id
      $DbaGroupId = (Get-AzAdGroup -DisplayName $DbaGroupName).id

      Write-Output $AdminGroupId
      Write-Output $DevGroupId
      Write-Output $DbaGroupId
      
      $DeploymentScriptOutputs  = @{}
      $DeploymentScriptOutputs["AdminGroupId"] = $AdminGroupId
      $DeploymentScriptOutputs["DevGroupId"] = $DevGroupId
      $DeploymentScriptOutputs["DbaGroupId"] = $DbaGroupId
  '''
  timeout: 'PT10M'
  cleanupPreference: 'onExpiration'
  retentionInterval: 'PT1H'
  }
}

output AdminGroupId string = deploymentScript.properties.outputs.AdminGroupId
output DevGroupId string = deploymentScript.properties.outputs.DevGroupId
output DbaGroupId string = deploymentScript.properties.outputs.DbaGroupId
