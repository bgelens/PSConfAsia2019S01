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

# see the commands that abstract the work for the function app
Import-Module ../FunctionApp/Modules/TFReg/TFReg.psd1 -Verbose -Force
$table = (Get-AzStorageTable -Context $st.Context -Name TFReg).CloudTable
Get-TFModule -Table $table

# create a new module entry
$tfentry = New-TFModuleObject -Namespace 'bg' -Name 'bla' -Provider 'azurerm'
$tfentry.Description = 'bla desc'
$tfentry.Owner = 'ben'
$tfentry.Version = '0.0.1'
$tfentry.Published_At = [datetime]::Now

New-TFModule -Table $table -TFModule $tfentry -Verbose

Get-TFModule -Table $table

# is it exposed now?
Get-TerraformModule

# remove the fake module
Get-TFModule -Table $table -Id $tfentry.Id | Remove-TFModule -Table $table

# see if terraform is able to consume the real module
Set-Location ./tfproject
$env:TF_LOG = 'Trace'
terraform init
