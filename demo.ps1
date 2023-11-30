# Environment preparation

$app1AdminGrpName= "WPC2023_App1_Admins"
$app1DevGrpName= "WPC2023_App1_Devs"
$app1DbaGrpName= "WPC2023_App1_Dbas"

$app2AdminGrpName= "WPC2023_App2_Admins"
$app2DevGrpName= "WPC2023_App2_Devs"
$app2DbaGrpName= "WPC2023_App2_Dbas"

$rgName = "WPC2023-TemplateSpec-RG"
$location = "italynorth"

$rg = Get-AzResourceGroup -Name $rgName -Location $location -ErrorAction SilentlyContinue
if (-not $rg) {
    New-AzResourceGroup -Name $rgName -Location $location
}

# Group creation section, execute it once
New-AzAdGroup -DisplayName $app1AdminGrpName `
    -MailNickname $app1AdminGrpName

New-AzAdGroup -DisplayName $app1DevGrpName `
    -MailNickname $app1DevGrpName

New-AzAdGroup -DisplayName $app1DbaGrpName `
    -MailNickname $app1DbaGrpName

New-AzAdGroup -DisplayName $app2AdminGrpName `
    -MailNickname $app2AdminGrpName

New-AzAdGroup -DisplayName $app2DevGrpName `
    -MailNickname $app2DevGrpName

New-AzAdGroup -DisplayName $app2DbaGrpName `
    -MailNickname $app2DbaGrpName



###########################################################
# DEMO 1: create a Template Spec
New-AzTemplateSpec -Name 'AppDeploy' `
    -ResourceGroupName $rg.ResourceGroupName `
    -version '1.0' `
    -Location $location `
    -TemplateFile .\ts_app_deploy.bicep

###########################################################
# DEMO 2: deploy an environment for App1 with deployment stack
$templateSpecId = (Get-AzTemplateSpec -Name 'AppDeploy' -ResourceGroupName $rg.ResourceGroupName).Versions[0].Id

New-AzSubscriptionDeploymentStack -Name 'App3-Environment-Stack' `
    -Location $location `
    -DeleteAll `
    -DenySettingsMode DenyDelete `
    -DenySettingsApplyToChildScopes `
    -TemplateSpecId $templateSpecId `
    -TemplateParameterObject @{ 
        'AppName' = 'WPC2023App3'
        'location' = $location
        'adminGrpName' = $app1AdminGrpName
        'devGrpName' = $app1DevGrpName
        'dbaGrpName' = $app1DbaGrpName
    }

###########################################################
# DEMO 3: create a new version of the template spec, and use it 
#         to deploy an environment for App2 with deployment stack

# Apply a change to the bicep file
New-AzTemplateSpec -Name 'AppDeploy' `
    -ResourceGroupName $rg.ResourceGroupName `
    -version '2.0' `
    -Location $location `
    -TemplateFile .\ts_app_deploy.bicep

$templateSpecId = (Get-AzTemplateSpec -Name 'AppDeploy' -ResourceGroupName $rg.ResourceGroupName).Versions[1].Id

New-AzSubscriptionDeploymentStack -Name 'App2-Environment-Stack' `
    -Location $location `
    -DeleteAll `
    -DenySettingsMode DenyDelete `
    -DenySettingsApplyToChildScopes `
    -TemplateSpecId $templateSpecId `
    -TemplateParameterObject @{ 
        'AppName' = 'WPC2023App2'
        'location' = $location
        'adminGrpName' = $app1AdminGrpName
        'devGrpName' = $app1DevGrpName
        'dbaGrpName' = $app1DbaGrpName
    }

###########################################################
# DEMO 4: Update App1 environment by using v2.0 of the template spec

$templateSpecId

Set-AzSubscriptionDeploymentStack -Name 'App1-Environment-Stack' `
    -Location $location `
    -DeleteAll `
    -DenySettingsMode DenyDelete `
    -DenySettingsApplyToChildScopes `
    -TemplateSpecId $templateSpecId `
    -TemplateParameterObject @{ 
        'AppName' = 'WPC2023App1'
        'location' = $location
        'adminGrpName' = $app1AdminGrpName
        'devGrpName' = $app1DevGrpName
        'dbaGrpName' = $app1DbaGrpName
    }


###########################################################
# DEMO 5: clean up

Remove-AzSubscriptionDeploymentStack -Name 'App1-Environment-Stack' `
    -DeleteAll

Remove-AzSubscriptionDeploymentStack -Name 'App2-Environment-Stack' `
    -DeleteAll


