<# Azure Functions Introduction
    Create your first PowerShell function in Azure (preview)
    https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-powershell
#>

$currentContext = $psEditor.GetEditorContext()
$workingDir = Split-Path -Path $currentContext.CurrentFile.Path
Set-Location -Path $workingDir

# prereqs, Azure Function Core Tools https://github.com/Azure/azure-functions-core-tools and dotnet core 2.2
Get-Command -Name func
func --version

Get-Command -Name dotnet
dotnet --version

# start developing
New-Item -ItemType Directory -Path ./DemoApp -Force | Set-Location

# help?
func

# create project
func init --worker-runtime powershell

# look at files, disable managedDependency

# create http function
func new --template httptrigger --name demo

# look at files, make anonymous

# run function app locally
func start

# in another windows run:
Invoke-RestMethod http://localhost:7071/api/demo
Invoke-RestMethod http://localhost:7071/api/demo?name=PSConfAsia
Invoke-RestMethod http://localhost:7071/api/demo -Method Post -ContentType 'application/json' -Body (
    @{
        Name = 'PSConfAsia'
    } | ConvertTo-Json
)

# publish to pre-created azure function app, remove wait-debugger first!
Get-AzWebApp -ResourceGroupName psconfasia01
func azure functionapp publish psconfasia01

# interact with published function app
Invoke-RestMethod -Uri https://psconfasia01.azurewebsites.net/api/demo?name=PSConfASIA!
