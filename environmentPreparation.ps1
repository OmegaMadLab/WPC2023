$location = "ItalyNorth"

New-AzResourceGroup -Name "WPC2023-ManagedIdentity-RG" `
    -Location $location

$msi = New-AzUserAssignedIdentity -ResourceGroupName "WPC2023-ManagedIdentity-RG" `
            -Name "WPC2023-ManagedIdentity-Identity" `
            -Location $location

Install-Module -Name Microsoft.Graph

Connect-MgGraph -Scopes "RoleManagement.ReadWrite.Directory"

$sp = Get-MgServicePrincipal -Filter "displayName eq '$($msi.Name)'"

$roledefinition = Get-MgRoleManagementDirectoryRoleDefinition -Filter "DisplayName eq 'Directory Readers'"

New-MgRoleManagementDirectoryRoleAssignment -DirectoryScopeId '/' `
    -RoleDefinitionId $roledefinition.Id `
    -PrincipalId $sp.Id


$tsRgName = "WPC2023-TemplateSpec-RG"
New-AzResourceGroup -Name $tsRgName `
    -Location $location

New-AzTemplateSpec -Name "database" `
    -ResourceGroupName $tsRgName `
    -Version "1.0" `
    -Location $location `
    -TemplateFile .\ts_modules\database.bicep `
    -DisplayName "Simple database"

New-AzTemplateSpec -Name "network" `
    -ResourceGroupName $tsRgName `
    -Version "1.0" `
    -Location $location `
    -TemplateFile .\ts_modules\network.bicep `
    -DisplayName "Virtual network and private DNS zone"

New-AzTemplateSpec -Name "webapp" `
    -ResourceGroupName $tsRgName `
    -Version "1.0" `
    -Location $location `
    -TemplateFile .\ts_modules\webapp.bicep `
    -DisplayName "Simple web application"

New-AzTemplateSpec -Name "role_assignment" `
    -ResourceGroupName $tsRgName `
    -Version "1.0" `
    -Location $location `
    -TemplateFile .\ts_modules\role_assignment.bicep `
    -DisplayName "Role assignment"

New-AzTemplateSpec -Name "getEntraIdInfo" `
    -ResourceGroupName $tsRgName `
    -Version "1.0" `
    -Location $location `
    -TemplateFile .\ts_modules\deploymentScript.bicep `
    -DisplayName "getEntraIdInfo"

New-AzTemplateSpec -Name "data_layer" `
    -ResourceGroupName $tsRgName `
    -Version "1.0" `
    -Location $location `
    -TemplateFile .\ts_modules\data_layer.bicep `
    -DisplayName "App data layer"

New-AzTemplateSpec -Name "frontend_layer" `
    -ResourceGroupName $tsRgName `
    -Version "1.0" `
    -Location $location `
    -TemplateFile .\ts_modules\frontend_layer.bicep `
    -DisplayName "App frontend layer"

New-AzTemplateSpec -Name "shared_layer" `
    -ResourceGroupName $tsRgName `
    -Version "1.0" `
    -Location $location `
    -TemplateFile .\ts_modules\shared_layer.bicep `
    -DisplayName "App shared layer"