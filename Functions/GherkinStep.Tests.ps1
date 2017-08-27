#You need import functions from Environment.ps1 before the first usage because
#the whole Pester module content is imported later
$Script:FunctionsRoot = Split-Path -Path $MyInvocation.MyCommand.Path

$Script:ModuleName = Join-Path -Path $FunctionsRoot -ChildPath 'Environment.ps1'

. $(Resolve-Path -Path $ModuleName) | Out-Null

if ($PSVersionTable.PSVersion.Major -le 2 -or ((GetPesterOS) -ne 'Windows')){ return }

Set-StrictMode -Version Latest

Describe 'Testing Gerkin Step' {
    It 'Generates a function named "GherkinStep" with mandatory name and test parameters' {
        $command = &(Get-Module Pester) { Get-Command GherkinStep -Module Pester }
        $command | Should Not Be $null

        $parameter = $command.Parameters['Name']
        $parameter | Should Not Be $null

        $parameter.ParameterType.Name | Should Be 'String'

        $attribute = $parameter.Attributes | Where-Object { $_.TypeId -eq [System.Management.Automation.ParameterAttribute] }
        $isMandatory = $null -ne $attribute -and $attribute.Mandatory

        $isMandatory | Should Be $true

        $parameter = $command.Parameters['Test']
        $parameter | Should Not Be $null

        $parameter.ParameterType.Name | Should Be 'ScriptBlock'

        $attribute = $parameter.Attributes | Where-Object { $_.TypeId -eq [System.Management.Automation.ParameterAttribute] }
        $isMandatory = $null -ne $attribute -and $attribute.Mandatory

        $isMandatory | Should Be $true
    }
    It 'Generates aliases Given, When, Then, And, But for GherkinStep' {
        $command = &(Get-Module Pester) { Get-Alias -Definition GherkinStep | Select -Expand Name }
        $command | Should Be "And", "But", "Given", "Then", "When"
    }
    It 'Populates the GherkinSteps module variable' {
        When "I Click" { }
        & ( Get-Module Pester ) { $GherkinSteps.Keys -eq "I Click" } | Should Be "I Click"
    }
}
