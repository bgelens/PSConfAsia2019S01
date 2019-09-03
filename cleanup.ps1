$functionApp1 = 'psconfasia01'
$functionApp2 = 'psconfasia02'

$currentContext = $psEditor.GetEditorContext()
$workingDir = Split-Path -Path $currentContext.CurrentFile.Path
Set-Location -Path $workingDir

Remove-AzResourceGroup -Name $functionApp1 -Force -AsJob
Remove-AzResourceGroup -Name $functionApp2 -Force -AsJob
Remove-Item ./Demo/tfproject/.terraform -Recurse -Force
Remove-Item ./Demo/tfproject/.terraformrc -Force
Remove-Item ./Demo/DemoApp -Recurse -Force
Remove-Item ./Demo/mymodulearchive.tar.gz -Force
