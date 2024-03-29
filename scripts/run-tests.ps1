<#
    .SYNOPSIS
        .
    .DESCRIPTION
        Run all tests for a solution
    #>
     Param(
          [Parameter(Mandatory = $true)][string] $solutionPath # name of result file to save test results to
         ,[Parameter(Mandatory = $true)][string] $testFilesToExclude # testdlls to exclude
         ,[Parameter(Mandatory = $true)][string] $mstest # path to the mstest.exe, usually lays in "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\mstest.exe"
         ,[Parameter(Mandatory = $true)][string] $testSettingFilePath  # path to the testSettingFile, usually lays in ".\*Solution*\TestSettings1.testsettings"  
    )

# [string[]] $testFilesToExclude = @("Unit2Tests,Unit3Tests"); # testdlls to exclude
# [string] $solutionPath="D:\git-hooks-tests"; # name of result file to save test results to
# [string] $mstest = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\MSTest.exe"; # path to the mstest.exe
# [string] $testSettingFilePath = "D:\git-hooks-tests\TestSolution\TestSettings1.testsettings"

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$testsFiles = @();
[string[]] $unitTestsFiles=@();
[string] $outCome= "";
$resultsFile = 'testresults.txt';

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
    $array = $testFilesToExclude.split(",")
    if($array -ne $null -and $array.count -gt 0)
    {
        foreach($item in $array)
        {
            foreach($testFile in $global:unitTestsFiles)
            {
                if([string]$testFile -like "*$item*")
                {
                    $global:unitTestsFiles=$global:unitTestsFiles -ne $testFile;
                } 
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
        $temp += "/$unitTestFile "
    }  
    $cmd="'$mstestPath'$temp /detail:errormessage /nologo /resultsfile:$global:resultsFile /testsettings:$global:testSettingFilePath ";
    iex "& $cmd";
}

function DeleteTestResultFileIfExist () {
    $resultsFilePath= $solutionPath |  Get-ChildItem -Filter $global:resultsFile -recurse;

    if($resultsFilePath)
    {
        if(Test-Path $resultsFilePath.FullName)
        {
            Remove-Item $resultsFilePath.FullName;
        }
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

function Validate () 
{
    if([string]::IsNullOrEmpty($solutionPath))
    {
        echo "In parameter solutionPath: $solutionPath is null or empty"
    }

    if([string]::IsNullOrEmpty($mstest))
    {
        echo "In parameter mstest: $mstest is null or empty"
    }

    if([string]::IsNullOrEmpty($testSettingFilePath))
    {
        echo "In parameter testSettingFilePath: $testSettingFilePath is null or empty"
    }

    if([string]::IsNullOrEmpty($testFilesToExclude))
    {
        echo "In parameter testFilesToExclude: $testFilesToExclude is null or empty"
    }    
}

function ProcessFileChange()
{
    try 
    {
        Validate
        GetTestsDlls
        ExcludeNonUnitTests
        RunTests
        ParseTestResults

        if($Global:outCome -eq "Completed"){
            echo "Gandalf Approves, see you next time!"
            exit 0
        }
        else {
            echo "You Shall Not Pass!!!"
            exit 1
        }   
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
    }
}

ProcessFileChange