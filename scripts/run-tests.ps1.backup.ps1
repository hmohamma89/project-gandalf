# <#
#     .SYNOPSIS
#         .
#     .DESCRIPTION
#         Run all tests for a project
#     #>

#     Param([Parameter(Mandatory = $true)][string] $testFilesToExclude # testdlls to exclude
#          ,[Parameter(Mandatory = $true)][string] $testCategory # name of the test category, "path to the test dll"  
#          ,[Parameter(Mandatory = $true)][string] $mstest # path to the mstest.exe, usually lays in "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\mstest.exe" 
#     )

# cls
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

[string[]] $testFilesToExclude = @("Unit2Tests");
$testsFiles = @();
[string[]] $unitTestsFiles=@();
$testCategory= "githooks";
$resultsFile = 'testresults.txt';
$mstest = '"C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\mstest.exe"';

function GetTestsDlls()
{
     $global:testsFiles=(get-item (get-location)).parent.fullname |  Get-ChildItem -Filter *Tests.dll -recurse | ? {$_.fullname -match "bin"};  
     foreach ($testsFile in $global:testsFiles) {
         $tempString="testcontainer:"+$testsFile.FullName;
         $global:unitTestsFiles+=$tempString;
     }
}
function ExcludeNonUnitTests()
{
    foreach($testFileToExclude in $testFilesToExclude)
    {
        foreach($testFile in $global:unitTestsFiles)
        {
            if([string]$testFile -match $testFileToExclude){
                $global:unitTestsFiles=$global:unitTestsFiles -ne $testFile;
            }
        } 
    }   
}

function RunTests()
{
    $temp="";
    $fs = New-Object -ComObject Scripting.FileSystemObject;
    $f = $fs.GetFile($global:mstest);
    $mstestPath = $f.shortpath;
    foreach($unitTestFile in $global:unitTestsFiles)
    {
        $temp += $unitTestFile +"/category:'$Global:testCategory'";
    }  
    iex "& $mstestPath $temp";
}

function ParseTestResults()
{
$results = [xml](GC $resultsFile)
$outcome = $results.TestRun.ResultSummary.outcome
$fgColor = if($outcome -eq "Failed") { "Red" } else { "Green" }

$total = $results.TestRun.ResultSummary.Counters.total
$passed = $results.TestRun.ResultSummary.Counters.passed
$failed = $results.TestRun.ResultSummary.Counters.failed

$failedTests = $results.TestRun.Results.UnitTestResult | Where-Object { $_.outcome -eq "Failed" }

Write-Host Test Results: $outcome -ForegroundColor $fgColor -BackgroundColor "Black"
Write-Host Total tests: $total
Write-Host Passed: $passed
Write-Host Failed: $failed
Write-Host

$failedTests | % { Write-Host Failed test: $_.testName
  Write-Host $_.Output.ErrorInfo.Message
  Write-Host $_.Output.ErrorInfo.StackTrace }

Write-Host
}

function ProcessFileChange()
{
    GetTestsDlls
    ExcludeNonUnitTests
	#BuildSolution
	RunTests
	#ParseTestResults
}


ProcessFileChange