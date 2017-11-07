<#
    .SYNOPSIS
        .
    .DESCRIPTION
        Run all tests for a project
    #>
    Param(
          [Parameter(Mandatory = $true)][string] $solutionPath # name of result file to save test results to
         ,[Parameter(Mandatory = $true)][string] $testFilesToExclude # testdlls to exclude
         ,[Parameter(Mandatory = $true)][string] $mstest # path to the mstest.exe, usually lays in "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\mstest.exe" 
    )
echo $solutionPath
echo $testFilesToExclude
echo $mstest
cls
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$testsFiles = @();
[string[]] $unitTestsFiles=@();

# [string[]] $testFilesToExclude = @("Unit2Tests"); # testdlls to exclude
# [string] $solutionPath="D:\git-hooks-tests"; # name of result file to save test results to
$resultsFile = 'testresults.txt';
# [string] $mstest = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\MSTest.exe"; # path to the mstest.exe
[string] $outCome= "";

function GetTestsDlls()
{
     $global:testsFiles= $solutionPath |  Get-ChildItem -Filter *Tests.dll -recurse | ? {$_.fullname -match "bin"};  
     foreach ($testsFile in $global:testsFiles) 
     {
         $x=$testsFile.FullName;
         $tempString="testcontainer:'$x'";
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
    DeleteTestResultFileIfExist
    $temp='';
    $fs = New-Object -ComObject Scripting.FileSystemObject;
    $f = $fs.GetFile($mstest);
    $mstestPath = $f.shortpath;
    foreach($unitTestFile in $global:unitTestsFiles)
    {
        #$temp += $unitTestFile +" /category:'$Global:testCategory' /detail:errormessage /resultsfile:$global:resultsFile";
        $temp += $unitTestFile+" /detail:errormessage /resultsfile:$global:resultsFile";
    }  
    $cmd="'$mstestPath'/$temp";
    iex "& $cmd";
}

function DeleteTestResultFileIfExist () {
    $resultsFilePath= $solutionPath |  Get-ChildItem -Filter $global:resultsFile -recurse;
    if(Test-Path $resultsFilePath.FullName){
        Remove-Item $resultsFilePath.FullName;
    }
}
function ParseTestResults()
{
    $results = [xml](GC $resultsFile)
    $global:outCome = $results.TestRun.ResultSummary.outcome
    $fgColor = if($outCome -eq "Failed") { "Red" } else { "Green" }

    $total = $results.TestRun.ResultSummary.Counters.total
    $passed = $results.TestRun.ResultSummary.Counters.passed
    $failed = $results.TestRun.ResultSummary.Counters.failed

    $failedTests = $results.TestRun.Results.UnitTestResult | Where-Object { $_.outcome -eq "Failed" }

    Write-Host Test Results: $outCome -ForegroundColor $fgColor -BackgroundColor "Black"
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
    try 
    {
        GetTestsDlls
        ExcludeNonUnitTests
        RunTests
        ParseTestResults    
    }
    catch
    {
        write-host Caught an exception: -ForegroundColor Red
        write-host Exception Type: $($_.Exception.GetType().FullName) -ForegroundColor Red
        write-host Exception Message: $($_.Exception.Message) -ForegroundColor Red
        exit 1
    }
    finally
    {
        write-host Finally block reached
        if($Global:outCome -eq "Failed"){
            write-host exit1
            exit 1
        }
        else {
            write-host exit0
            exit 0
        }
    }
}

ProcessFileChange