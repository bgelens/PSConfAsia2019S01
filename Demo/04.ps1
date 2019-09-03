<# if time, let's enable authentication support
    https://www.terraform.io/docs/cloud/registry/using.html#configuration
#>
$currentContext = $psEditor.GetEditorContext()
$workingDir = Split-Path -Path $currentContext.CurrentFile.Path
Set-Location -Path $workingDir

$webApp = Get-AzWebApp -Name 'psconfasia02' -ResourceGroupName 'psconfasia02'
$newApplicationSettings = @{}

$webApp.SiteConfig.AppSettings | ForEach-Object -Process {
  $newApplicationSettings.Add($_.Name, $_.Value)
}

# add new setting
$newApplicationSettings.Add('authenticationKeys', 'dd38c0be-fa3b-45f6-97b3-cfdf4a9a6a33')

Set-AzWebApp -AppSettings $newApplicationSettings -Name 'psconfasia02' -ResourceGroupName 'psconfasia02'

# let's see if we can still see the modules
Get-TerraformModule

# need to add bearer token
Connect-TerraformRegistry -Url https://psconfasia02.azurewebsites.net -BearerToken 'dd38c0be-fa3b-45f6-97b3-cfdf4a9a6a33'
Get-TerraformModule

# now let's check terrafrom itself
Set-Location ./tfproject
Remove-Item ./.terraform -Recurse -Force
terraform init

# let's fix this
'credentials "psconfasia02.azurewebsites.net" {
    token = "dd38c0be-fa3b-45f6-97b3-cfdf4a9a6a33"
}' | Out-File ./.terraformrc
$env:TF_CLI_CONFIG_FILE = (Resolve-Path -Path ./.terraformrc)

terraform init
