<# PowerShell as a client
    Duplicating terraform client interaction with api makes you understand what is needed
    and helps you while developing without the need to run terraform init every time
    https://www.terraform.io/docs/registry/api.html
#>

$currentContext = $psEditor.GetEditorContext()
$workingDir = Split-Path -Path $currentContext.CurrentFile.Path
Set-Location -Path $workingDir

# registry url
$baseUrl = 'http://registry.terraform.io'

# discovery process
Invoke-RestMethod -Uri $baseUrl/.well-known/terraform.json

# modules url
$disco = Invoke-RestMethod -Uri $baseUrl/.well-known/terraform.json
Invoke-RestMethod -Uri $baseUrl/$($disco.'modules.v1'.TrimEnd('/')) | Tee-Object -Variable modules

$modules.meta
$modules.modules | Format-Table

<# using a module to simplify the querying
 https://github.com/bgelens/TerraformRegistry
 https://www.powershellgallery.com/packages/TerraformRegistry
#>
Connect-TerraformRegistry
Get-TerraformModule -Provider azurerm -NameSpace azure

Get-TerraformModule -Provider azurerm -NameSpace azure -Name loadbalancer | Tee-Object -Variable lbmod
$lbmod | Get-TerraformModuleVersion
$lbmod | Get-TerraformModuleDownloadLink
