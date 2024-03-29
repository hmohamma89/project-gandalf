#!/bin/bash 

# Parameters to call the powershell script with
SOLUTIONPATH="D:\git-hooks-tests" # required:true type:string, name of result file to save test results to
TESTFILESTOEXCLUDE="Unit2Tests,Unit3Tests" # required:true type:string("comma seperated"), testdlls to exclude
MSTEST="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\MSTest.exe"  # required:true type:string, path to the mstest.exe, usually lays in "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\mstest.exe"
TESTSETTINGFILEPATH="D:\git-hooks-tests\TestSolution\TestSettings1.testsettings" #required:true type:string, path to the testSettingFile, usually lays in ".\*Solution*\TestSettings1.testsettings"  

protected_branch='master'
# Check if we actually have commits to push
commits=`git log @{u}..`
if [ -z "$commits" ]; then
    exit 0
fi

current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [[ $current_branch = $protected_branch ]]; then
    echo "-----------------------------------------------"
    echo "Solutions path: $SOLUTIONPATH"
    echo "Test .dll Files to exclude: $TESTFILESTOEXCLUDE"
    echo "Mstest path: $MSTEST"
    echo "TestSettingFile path: $TESTSETTINGFILEPATH"
    echo "-----------------------------------------------"
	echo "Running unit tests"
    # Command that runs your tests
    c:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy RemoteSigned -File .\\scripts\\run-tests.ps1 -solutionPath "$SOLUTIONPATH" -testFilesToExclude "$TESTFILESTOEXCLUDE" -mstest "$MSTEST" -testSettingFilePath "$TESTSETTINGFILEPATH"
    RESULT=$?
    if [ $RESULT -ne 0 ]; then 
        echo "Your unit tests are failing please fix them before you push to remote"
        exit 1
    fi
fi
exit 0