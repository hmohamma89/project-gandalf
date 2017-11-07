#!/bin/bash 


SOLUTIONPATH="D:\git-hooks-tests"
TESTFILESTOEXCLUDE="Unit2Tests"
MSTEST="C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\MSTest.exe"
CMD="c:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy RemoteSigned -File .\\scripts\\run-tests.ps1 -solutionPath "\""$SOLUTIONPATH"\"" -testFilesToExclude "\""$TESTFILESTOEXCLUDE"\"" -mstest "\""$MSTEST"\"""
protected_branch='master'
# Check if we actually have commits to push
commits=`git log @{u}..`
if [ -z "$commits" ]; then
    exit 0
fi

current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [[ $current_branch = $protected_branch ]]; then
    echo "Solutions path: $SOLUTIONPATH"
    echo "Test .dll Files to exclude: $TESTFILESTOEXCLUDE"
    echo "Mstest path: $MSTEST"
    echo "-----------------------------------------------"
    echo "cmd to run test: $CMD"
    echo "-----------------------------------------------"
	echo "Runing unit tests"
    # Command that runs your tests
    # $CMD
    c:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy RemoteSigned -File .\\scripts\\run-tests.ps1 -solutionPath "D:\git-hooks-tests" -testFilesToExclude "Unit2Tests" -mstest "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\MSTest.exe"
    RESULT=$?
    echo  "the result is: $RESULT"
    if [ $RESULT -ne 0 ]; then 
        echo "Your unit tests are failing please fix them before you push to your git repository"
        exit 1
    fi
fi
exit 0