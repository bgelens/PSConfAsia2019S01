$functionApp1 = 'psconfasia01'
$functionApp2 = 'psconfasia02'
$currentContext = $psEditor.GetEditorContext()
$workingDir = Split-Path -Path $currentContext.CurrentFile.Path
$consumptionJson = Join-Path -Path $workingDir -ChildPath 'consumption.json'
$premiumJson = Join-Path -Path $workingDir -ChildPath 'premium.json'
$functionAppPath = Join-Path -Path $workingDir -ChildPath 'FunctionApp'

#region consumption
$rg = Get-AzResourceGroup -Name $functionApp1 -ErrorAction SilentlyContinue
if ($rg) {
    $rg | Remove-AzResourceGroup -Force
}

$rg = New-AzResourceGroup -Name $functionApp1 -Location westeurope

New-AzResourceGroupDeployment -TemplateFile $consumptionJson -ResourceGroupName $rg.ResourceGroupName -TemplateParameterObject @{functionAppName = $functionApp1}
#endregion

#region premium
$rg = Get-AzResourceGroup -Name $functionApp2 -ErrorAction SilentlyContinue
if ($rg) {
    $rg | Remove-AzResourceGroup -Force
}

$rg = New-AzResourceGroup -Name $functionApp2 -Location westeurope

$deploy = New-AzResourceGroupDeployment -TemplateFile $premiumJson -ResourceGroupName $rg.ResourceGroupName -TemplateParameterObject @{functionAppName = $functionApp2}

# configure web app
$webApp = Get-AzWebApp -Name $functionApp2 -ResourceGroupName $rg.ResourceGroupName

# copy current settings into new hashtable as all settings will be overwritten by the Set action
$newApplicationSettings = @{}

$webApp.SiteConfig.AppSettings | ForEach-Object -Process {
  $newApplicationSettings.Add($_.Name, $_.Value)
}

# add new setting
$newApplicationSettings.Add('TFRegTableName', 'TFReg')
$newApplicationSettings.Add('ModuleContainer', 'modules')

Set-AzWebApp -AppSettings $newApplicationSettings -Name $functionApp2 -ResourceGroupName $rg.ResourceGroupName

$stAccount = Get-AzStorageAccount -ResourceGroupName $rg.ResourceGroupName -Name $deploy.Outputs['storageAccountName'].Value
$stAccount | New-AzStorageTable -Name TFReg
$stAccount | New-AzStorageContainer -Permission Off -Name 'modules'

Set-Location -Path $functionAppPath

# configure app settings

func azure functionapp publish psconfasia02
#endregion