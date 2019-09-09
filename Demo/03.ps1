<# Develop Terraform Private Registry as Azure Functions using PowerShell 
    Project: https://github.com/bgelens/AzFuncTFRegistry
#>
$currentContext = $psEditor.GetEditorContext()
$workingDir = Split-Path -Path $currentContext.CurrentFile.Path
$moduleFolder = Join-Path -Path $workingDir -ChildPath 'vm-windows'
Set-Location -Path $workingDir

# prestaged the web app already, show in portal

<# walk through in vs code then show it in action
    * Talk about module folder
    * Talk about different triggers used (blob and http)
    * Talk about route constraints used
      https://docs.microsoft.com/en-us/aspnet/core/fundamentals/routing?view=aspnetcore-2.1#route-constraint-reference
#>

# connect using PowerShell
Connect-TerraformRegistry -Url https://psconfasia02.azurewebsites.net
Get-TerraformModule

# nothing there, let's publish a module, first check the module vm-windows
# next, pack the module as tar.gz
tar -czvf mymodulearchive.tar.gz -C $moduleFolder .

# upload to storage
$st = Get-AzStorageAccount -ResourceGroupName psconfasia02
Set-AzStorageBlobContent -Container modules -Context $st.Context -File mymodulearchive.tar.gz -Metadata @{
  description = 'Deploy a Windows VM and optionally add a Public IP and Extensions (OMS, IaaSAntiMalware, DiskEncryption)'
  owner = 'bgelens'
  namespace = 'bgtf'
  name = 'vm-windows'
  provider = 'azurerm'
  version = '1.0.0'
}

# check to see if module is imported
Get-TerraformModule

# ingest-modules did it's work, now see what the download uri looks like
Get-TerraformModule | Get-TerraformModuleDownloadLink

# this incremented the download count
Get-TerraformModule

# see if terraform is able to consume the real module
Set-Location ./tfproject
$env:TF_LOG = 'Trace'
terraform init
